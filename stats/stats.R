#!/usr/bin/env Rscript
library(xtable)

#############################################################
# Preparación de datos
files <- dir("csv", full.names = T)
results <- lapply(files, read.csv)
datasets <- c(
  "arrhythmia",
  "movement_libras",
  "wdbc"
)
d_names <- c("Arrhythmia", "Movement Libras", "WDBC")
heuristics <- c(
  "BasicMultistart",
  "BasicTabuSearch",
  "FirstDescent",
  "GenerationalGenetic",
  "Grasp",
  "IterativeLocalSearch",
  "MaximumDescent",
  "NoSelection",
  "SeqBackwardSelection",
  "SeqForwardSelection",
  "SimAnnealing",
  "StationaryGenetic",
  "TabuSearch"
)
h_order <- c(8, 10, 9, 3, 7, 11, 2, 13, 1, 5, 6, 4, 12)
practicas <- list(
  c(8, 10, 9, 3, 7, 11, 2, 13),
  c(8, 10, 9, 1, 5, 6),
  c(8, 10, 9, 4, 12)
)
ordered_heuristics <- heuristics[h_order]
l <- length(heuristics)

result_names <- lapply(1:length(results), function(i) list(dataset = datasets[ceiling(i/8)], heuristic = heuristics[((i - 1) %% 8) + 1]))
row_names <- c("Partición 1-1", "Partición 1-2", "Partición 2-1", "Partición 2-2", "Partición 3-1", "Partición 3-2", "Partición 4-1", "Partición 4-2", "Partición 5-1", "Partición 5-2", "Media")
col_names <- c("%train", "%test", "%red", "time")
col_names <- as.vector(sapply(c("wdbc", "libras", "arr"), function(d) paste(d, col_names)))

measures <- c("training", "test", "reduction", "time")

for (r in 1:length(results)) {
  results[[r]] <- results[[r]][-1]
  results[[r]][c(1, 2, 3)] <- 100 * results[[r]][c(1, 2, 3)]
}

#############################################################
# Tablas
for (h in 1:length(heuristics)) {
  join <- data.frame(wdbc = results[[2*l + h_order[h]]], libras = results[[l + h_order[h]]], arrhythmia = results[[h_order[h]]])
  join <- rbind(join, sapply(join, mean))
  rownames(join) <- row_names
  names(join) <- col_names
  sink(paste0("latex/", ordered_heuristics[h], ".tex"))
  print(xtable(
    join,
    caption = ordered_heuristics[h],
    label = ordered_heuristics[h]
    ), table.placement = "h!", size = "\\scriptsize")
  sink(NULL)
}

#############################################################
# Resultados globales
two_decs <- function(x) format(round(x, 2), nsmall=2)
means <- t(data.frame(lapply(1:length(heuristics), function(h) {
  join <- data.frame(wdbc = results[[2*l + h_order[h]]], libras = results[[l + h_order[h]]], arrhythmia = results[[h_order[h]]])
  paste(two_decs(sapply(join, mean)), "$\\pm$", two_decs(sapply(join, sd)))
})))
rownames(means) <- ordered_heuristics
colnames(means) <- col_names
sink("latex/global.tex")
print(xtable(
  means,
  caption = "Resultados globales en el problema de Selección de Características",
  label = "global"
  ), table.placement = "h!", size = "\\tiny", sanitize.text.function = function(x) x, sanitize.colnames.function = NULL)
sink(NULL)

#############################################################
# Boxplots
for (m in measures) {
  for (d in 1:length(datasets)) {
    initial <- l * (d-1)
    for (p in 1:length(practicas)) {
      lists <- lapply(results[initial + practicas[[p]]], function(r) r[[m]])
      png(paste0("img/boxplot_", m, "_", datasets[d], "_p", p, ".png"), width = 1300, height = 400)
      boxplot(lists, names = heuristics[practicas[[p]]])
      title(datasets[d], sub = m)
      dev.off()
    }
  }
}
