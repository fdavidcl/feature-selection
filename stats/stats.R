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
  "Memetic(1, 0.1)",
  "Memetic(1, 0.1mej)",
  "Memetic(1, 1)",
  "Memetic(10, 0.1)",
  "Memetic(10, 0.1mej)",
  "Memetic(10, 1)",
  "NoSelection",
  "SBS",
  "SFS",
  "SimAnnealing",
  "StationaryGenetic",
  "TabuSearch"
)
h_order <- c(14, 16, 15, 3, 7, 17, 2, 19, 1, 5, 6, 4, 18, 11, 13, 12, 8, 10, 9)
practicas <- list(
  c(14, 16, 15, 3, 7, 17, 2, 19),
  c(14, 16, 15, 1, 5, 6),
  c(14, 16, 15, 4, 18),
  c(14, 16, 4, 11, 13, 12, 8, 10, 9)
)
ordered_heuristics <- heuristics[h_order]
l <- length(heuristics)

result_names <- lapply(1:length(results), function(i) list(dataset = datasets[ceiling(i/8)], heuristic = heuristics[((i - 1) %% 8) + 1]))
row_names <- c("P. 1-1", "P. 1-2", "P. 2-1", "P. 2-2", "P. 3-1", "P. 3-2", "P. 4-1", "P. 4-2", "P. 5-1", "P. 5-2", "Media", "Rango")
col_names <- c("%train", "%test", "%red", "time")
col_names <- as.vector(sapply(c("wdbc", "libras", "arr"), function(d) paste(d, col_names)))

measures <- c("training", "test", "reduction", "time")

for (r in 1:length(results)) {
  results[[r]] <- results[[r]][-1]
  results[[r]][c(1, 2, 3)] <- 100 * results[[r]][c(1, 2, 3)]
}

two_decs <- function(x) format(round(x, 2), nsmall=2)
#############################################################
# Tablas
for (h in 1:length(heuristics)) {
  join1 <- data.frame(wdbc = results[[2*l + h_order[h]]], libras = results[[l + h_order[h]]], arrhythmia = results[[h_order[h]]])
  join <- rbind(join1, sapply(join1, mean))
  join <- two_decs(join)
  join <- rbind(join, sapply(join1, function(col) paste0(two_decs(min(col)), "-", two_decs(max(col)))))
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
