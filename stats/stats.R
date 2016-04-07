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
  join <- data.frame(wdbc = results[[16 + h_order[h]]], libras = results[[8 + h_order[h]]], arrhythmia = results[[h_order[h]]])
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
  join <- data.frame(wdbc = results[[16 + h_order[h]]], libras = results[[8 + h_order[h]]], arrhythmia = results[[h_order[h]]])
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
    initial <- length(heuristics) * (d-1)
    lists <- lapply(results[initial + h_order], function(r) r[[m]])
    png(paste0("img/boxplot_", m, "_", datasets[d], ".png"), width = 1300, height = 400)
    boxplot(lists, names = ordered_heuristics)
    title(datasets[d], sub = m)
    dev.off()
  }
}
