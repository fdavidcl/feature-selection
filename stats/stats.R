#!/usr/bin/env Rscript
library(xtable)

files <- dir("csv", full.names = T)
results <- lapply(files, read.csv)
datasets <- c(
  "arrhythmia",
  "movement_libras",
  "wdbc"
)
d_names <- c("Arrhythmia", "Movement Libras", "WDBC")
heuristics <- c(
  "BasicTabuSearch",
  "FirstDescent",
  "MaximumDescent",
  "NoSelection",
  "SeqBackwardSelection",
  "SeqForwardSelection",
  "SimAnnealing",
  "TabuSearch"
)
h_order <- c(4, 6, 5, 2, 3, 7, 1, 8)
ordered_heuristics <- heuristics[h_order]
result_names <- lapply(1:length(results), function(i) list(dataset = datasets[ceiling(i/8)], heuristic = heuristics[((i - 1) %% 8) + 1]))

measures <- c("training", "test", "reduction", "time")

for (r in 1:length(result_names)) {
  sink(paste0("latex/", result_names[[r]]$dataset, "_", result_names[[r]]$heuristic, ".tex"))
  print(xtable(
    results[[r]][-1],
    caption = paste(result_names[[r]]$heuristic, "sobre el dataset", d_names[ceiling(r/8)])
  ), table.placement = "h!")
  sink(NULL)
}

for (m in measures) {
  for (d in 1:length(datasets)) {
    initial <- length(heuristics) * (d-1)
    lists <- lapply(results[initial + h_order], function(r) r[[m]])
    png(paste0("img/boxplot_", m, "_", datasets[d], ".png"), width = 1300, height = 400)
    boxplot(lists, names = ordered_heuristics)
    title(datasets[d], sub = m)
    dev.off()
  }
}
