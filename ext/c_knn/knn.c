/*
*  class/src/class.c by W. N. Venables and B. D. Ripley  Copyright (C) 1994-2002
*
*  This program is free software; you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation; either version 2 or 3 of the License
*  (at your option).
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  A copy of the GNU General Public License is available at
*  http://www.r-project.org/Licenses/
*
*/

#include <ruby.h>
#include <math.h>
#include <float.h>
// remove later:
#include <stdio.h>

#define EPS 1e-4		/* relative test of equality of distances */
#define MAX_TIES 1000
/* Not worth doing this dynamically -- limits k + # ties + fence, in fact */

/* Definitions for Ruby */
VALUE FeatureSelection = Qnil;
VALUE Classifier = Qnil;
VALUE CKNearest = Qnil;

/*
KNearest::KNNClassifier#leaveoneout

params:
  rb_k: number of neighbors
  ~~rb_l: minimum vote for definite decision, otherwise ‘doubt’ (0 by default)~~
  ~~rb_train_rows: number of training rows~~
  ~~rb_test_rows: number of test rows (when using cv, pass same value as rb_train_rows)~~
  ~~rb_attributes: number of columns (input attributes)~~
  rb_train: training dataset (only input attributes)
  rb_class: class column (as factor?)
  ~~rb_test: test dataset~~
  ~~res~~
  ~~pr~~
  ~~rb_votes: number of classes + 1 (?)~~
  ~~rb_nclass: number of classes~~
  ~~rb_cv: using cross-validation? (leaveoneout)~~
  ~~rb_use_all: controls handling of ties. If true, all distances equal to
          the ‘k’th largest are included. If false, a random selection
          of distances equal to the ‘k’th is chosen to use exactly ‘k’
          neighbours.~~
  rb_features: bit array of selected features
  rb_random: Random object
*/

double * instances = NULL;
int * class_col = NULL;
int * which_numeric = NULL;
int ncol, nrow, class_count, num_neighbors;
double FLOAT_MAX;
VALUE rb_random;

VALUE method_c_knn_leaveoneout(VALUE self, VALUE rb_features) {
  rb_features = rb_funcall(rb_features, rb_intern("to_a"), 0);
  int correct_guesses;
  double fitness;


  /* The following is code based on the "class" package from R */
  /***************************************************************
   VR_knn input parameters:
     Sint *kin, Sint *lin, Sint *pntr, Sint *pnte, Sint *p,
     double *train, Sint *class, double *test, Sint *res, double *pr,
     Sint *votes, Sint *nc, Sint *cv, Sint *use_all
  ***************************************************************/
  int   i, index, j, k, k1, kinit = num_neighbors, kn, l = 0, mm, npat, ntie, extras;
  int   pos[MAX_TIES], nclass[MAX_TIES];
  int   j1, j2, needed, t;
  double dist, tmp, nndist[MAX_TIES];

  // Prediction results
  int * res = (int*) malloc(sizeof(int) * nrow);
  int * votes = (int*) malloc(sizeof(int) * class_count);

  /*
  Use a 'fence' in the (k+1)st position to avoid special cases.
  Simple insertion sort will suffice since k will be small.
  */

  for (npat = 0; npat < nrow; npat++) {
    kn = kinit;

    for (k = 0; k < kn; k++)
      nndist[k] = 0.99 * FLOAT_MAX;

    for (j = 0; j < nrow; j++) {
      if (j == npat) // Skip own instance for leave-one-out cross_validation
        continue;

      dist = 0.0;

      for (k = 0; k < ncol; k++) {
        // Skip unselected features
        if (NUM2INT(rb_ary_entry(rb_features, k))) {
          // Distinguish numeric attributes from nominal
          tmp = instances[npat * ncol + k] - instances[j * ncol + k];

          if (which_numeric[k]) {
            dist += tmp * tmp;
          } else if (tmp < EPS && tmp > -EPS) { // Nominal feature
            // Add 1 if values are different
            dist += 1;
          }
        }
      }

      /* Use 'fuzz' since distance computed could depend on order of coordinates */
      if (dist <= nndist[kinit - 1] * (1 + EPS))
        for (k = 0; k <= kn; k++)
          if (dist < nndist[k]) {
            for (k1 = kn; k1 > k; k1--) {
              nndist[k1] = nndist[k1 - 1];
              pos[k1] = pos[k1 - 1];
            }
            nndist[k] = dist;
            pos[k] = j;
            /* Keep an extra distance if the largest current one ties with current kth */
            if (nndist[kn] <= nndist[kinit - 1])
              if (++kn == MAX_TIES - 1)
                return rb_float_new(-2.0); // Too many ties. Fail
            break;
          }

      nndist[kn] = 0.99 * FLOAT_MAX;
    }

    for (j = 0; j < class_count; j++)
      votes[j] = 0;

    // use_all is true always so unneeded code has been removed
    for (j = 0; j < kinit; j++){
      votes[class_col[pos[j]]]++;
    }
    extras = 0;

    for (j = kinit; j < kn; j++) {
      if (nndist[j] > nndist[kinit - 1] * (1 + EPS))
        break;

      extras++;
      votes[class_col[pos[j]]]++;
    }

    /* Use reservoir sampling to choose amongst the tied votes */
    ntie = 1;

    mm = votes[0];
    index = 0;

    for (i = 1; i < class_count; i++)
      if (votes[i] > mm) {
        ntie = 1;
        index = i;
        mm = votes[i];
      } else if (votes[i] == mm && votes[i] >= l) {
        if (++ntie * NUM2DBL(rb_funcall(rb_random, rb_intern("rand"), 0)) < 1.0)
          index = i;
      }

    res[npat] = index;
    //pr[npat] = (double) mm / (kinit + extras);
  }
  /* end of "class" code */

  free(votes);

  correct_guesses = 0;

  for (npat = 0; npat < nrow; npat++) {
    // Count correct guesses
    correct_guesses += res[npat] == class_col[npat];
  }

  free(res);

  fitness = (double)(correct_guesses) / (double)(nrow);

  return rb_float_new(fitness);
}

VALUE method_c_knn_initialize(VALUE self, VALUE rb_k, VALUE rb_dataset, VALUE rb_random_par) {
  VALUE data = rb_funcall(rb_dataset, rb_intern("instances"), 0);
  VALUE rb_class = rb_funcall(rb_dataset, rb_intern("classes"), 0);
  VALUE rb_numeric = rb_funcall(rb_dataset, rb_intern("numeric_attrs"), 0);

  // Define global variables
  num_neighbors = NUM2INT(rb_k);
  nrow = RARRAY_LEN(data);
  ncol = RARRAY_LEN(rb_ary_entry(data, 0));
  class_count = rb_funcall(rb_dataset, rb_intern("class_count"), 0);
  FLOAT_MAX = NUM2DBL(rb_intern("Float::MAX"));
  rb_random = rb_random_par;

  instances = (double*) malloc(sizeof(double) * nrow * ncol);

  int i, j;
  for (i = 0; i < nrow; i++) {
    for (j = 0; j < ncol; j++) {
      instances[i * ncol + j] = NUM2DBL(rb_ary_entry(rb_ary_entry(data, i), j));
    }
  }

  class_col = (int*) malloc(sizeof(int) * nrow);

  for (i = 0; i < nrow; i++) {
    class_col[i] = NUM2INT(rb_ary_entry(rb_class, i));
  }

  which_numeric = (int*) malloc(sizeof(int) * ncol);

  for (j = 0; j < ncol; j++) {
    which_numeric[j] = NUM2INT(rb_ary_entry(rb_numeric, j));
  }

  return self;
}

void Init_c_knn(void) {
  FeatureSelection = rb_const_get(rb_cObject, rb_intern("FeatureSelection"));
  Classifier = rb_const_get(FeatureSelection, rb_intern("Classifier"));
  CKNearest = rb_const_get(FeatureSelection, rb_intern("CKNearest"));
  rb_define_method(CKNearest, "initialize", method_c_knn_initialize, 3);
  rb_define_method(CKNearest, "fitness_for", method_c_knn_leaveoneout, 1);
}
