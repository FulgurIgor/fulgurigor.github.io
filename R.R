#!/usr/bin/env Rscript

library(dplyr)
library(ggplot2)
library(stringr)
library(plotly)
library(htmlwidgets)

temp <- tempfile()
download.file("https://github.com/oripio/premiya-runeta-data/blob/master/data.csv.zip?raw=true",temp)
data <- read.csv(unz(temp, "data.csv"), sep=";", header=T)
unlink(temp)

csv <- data %>%
  filter(nomimation == 1) %>%
  select(name, timestamp, votes) %>%
  filter(votes > 100) %>%
  mutate(name = str_sub(name, start = 1, end = 30)) %>%
  mutate(timestamp = as.POSIXct(timestamp/10000000000, origin="1970-01-01"))

P <- ggplot(csv, aes(x=timestamp, y=votes, color=name)) +
  geom_line() +
  theme_bw() +
  labs(x = "Время, EST", y = "Число голосов", color = "Имя участника")

PP <- ggplotly(P)
saveWidget(PP, file = '/home/ger/Proj/premia/fulgurigor.github.io/index.html')