#!/usr/bin/env Rscript

library(dplyr)
library(ggplot2)
library(stringr)
library(plotly)
library(htmlwidgets)

temp <- tempfile()
download.file("https://github.com/oripio/premiya-runeta-data/blob/master/data.csv.zip?raw=true", temp)
data <- read.csv(unz(temp, "data.csv"), sep=";", header=T)
unlink(temp)

csv <- data %>%
  filter(timestamp > 0) %>%
  filter(nomimation == 1) %>%
  select(name, timestamp, votes) %>%
  filter(votes > 100) %>%
  mutate(name = str_sub(name, start = 1, end = 30)) %>%
  mutate(timestamp = as.POSIXct(timestamp, origin="1970-01-01"))

P <- ggplot(csv, aes(x=timestamp, y=votes, color=name)) +
  geom_line() +
  theme_bw() +
  labs(x = "Время, EST", y = "Число голосов", color = "Имя участника") +
  scale_y_continuous(breaks = seq(0,50000, 1000)) +
  scale_x_datetime(labels = function(x) strftime(x, "%d/%m %H:%M"), date_breaks = "2 hour") +
  theme(axis.text.x=element_text(angle=60, hjust=1))

PP <- ggplotly(P)
saveWidget(PP, file = '/home/ger/Proj/premia/fulgurigor.github.io/index.html', selfcontained=T, title="Премия Рунета 2018")
saveWidget(PP, file = '/home/ger/Proj/premia/fulgurigor.github.io/separated.html', selfcontained=F, title="Премия Рунета 2018")