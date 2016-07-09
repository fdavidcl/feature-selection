# feature-selection

A Ruby gem for feature selection using several well-known metaheuristics. Developed for the [Metaheuristics course](http://sci2s.ugr.es/graduateCourses/Metaheuristicas) at the Universidad de Granada.

## Usage

~~~sh
bin/setup # will even install Ruby 2.3 if needed
bin/config
# Modify config.yml and bin/start to your liking
bin/start
~~~

Results will be saved in individual files inside directory `out/`. You can use the R script at `stats/stats.R` to process them.

## Dependencies

* Ruby (>= 2.2) with gem *bundler*
* R (>= 3) is required to process the results
* Pandoc is required to generate the documentation

## Documentation

The documentation is generated via `rake doc`. It's only available in Spanish.
