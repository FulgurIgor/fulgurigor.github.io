#!/usr/bin/env Rscript

library(dplyr)
library(ggplot2)
library(stringr)
library(plotly)
library(htmlwidgets)
library(hues)

Sys.setenv(TZ='Europe/Moscow')

temp <- tempfile()
download.file("https://github.com/oripio/premiya-runeta-data/blob/master/data.csv.zip?raw=true", temp)
data <- read.csv(unz(temp, "data.csv"), sep=";", header=T)
unlink(temp)

csvfull <- data %>%
  filter(timestamp > 0) %>%
  filter(nomimation == 1) %>%
  select(name, timestamp, votes) %>%
  filter(votes > 100) %>%
  mutate(name = str_sub(name, start = 1, end = 30)) %>%
  mutate(timestamp = as.POSIXct(timestamp, origin="1970-01-01"))
csv <- csvfull %>%
  group_by(name) %>%
  mutate(lagv = lag(votes) == votes) %>%
  mutate(leadv = lead(votes) == votes) %>%
  mutate(tmp = lagv & leadv) %>%
  mutate(tmp = ifelse(is.na(tmp), F, tmp)) %>%
  filter(tmp == F) %>%
  select(name, timestamp, votes)
csvspeed <- csvfull %>%
  group_by(name) %>%
  mutate(votes = votes - lag(votes)) %>%
  mutate(lagv = lag(votes) == votes) %>%
  mutate(leadv = lead(votes) == votes) %>%
  mutate(tmp = lagv & leadv) %>%
  mutate(tmp = ifelse(is.na(tmp), F, tmp)) %>%
  filter(tmp == F) %>%
  filter(!is.na(votes)) %>%
  select(name, timestamp, votes)

votesAtLastMoment <- csvfull %>%
  group_by(name) %>%
  filter(timestamp == max(timestamp)) %>%
  select(name, votes)

valm5 <- votesAtLastMoment %>% group_by(name) %>%
  summarise(votes = max(votes)) %>%
  top_n(5) %>%
  select(name) %>% unlist()
csv5 <- csv %>%
  filter(name %in% c(valm))
csvspeed5 <- csvspeed %>%
  filter(name %in% c(valm))

updatemenus <- list(
  list(
    active = 0,
    type = "buttons",
    direction = "right",
    xanchor = 'center',
    yanchor = "top",
    pad = list('r'= 0, 't'= 10, 'b' = 10),
    x = 0.6,
    y = 1.37,
    buttons = list(
      list(method = "restyle",
           args = list("visible", list(F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,T,T,T,T,T,F,F,F,F,F)),
           label = 'Число голосов (top-5)'),
      list(method = "restyle",
           args = list("visible", list(F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,T,T,T,T,T)),
           label = 'Добавлено голосов (top-5)'),
      list(method = "restyle",
           args = list("visible", list(T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F )),
           label = 'Число голосов (все)'),
      list(method = "restyle",
           args = list("visible", list(F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,F,F,F,F,F,F,F,F,F,F)),
           label = 'Добавлено голосов (все)'
           )
    )
  )
)

PP <- plot_ly() %>%
  add_trace(data=csv, x = ~timestamp, y = ~votes, 
        color = ~name, colors = "Dark2",
        type = "scatter", mode = 'lines',visible=F) %>%
  add_trace(data=csvspeed, x = ~timestamp, y = ~votes, 
            color = ~name, colors = "Dark2",
            type = "scatter", mode = 'lines', visible=F) %>%
  add_trace(data=csv5, x = ~timestamp, y = ~votes, 
            color = ~name, colors = "Dark2",
            type = "scatter", mode = 'lines',visible=T) %>%
  add_trace(data=csvspeed5, x = ~timestamp, y = ~votes, 
            color = ~name, colors = "Dark2",
            type = "scatter", mode = 'lines', visible=F) %>%
  layout(xaxis = list(title = 'Время, MSK'),
         yaxis = list(title = 'Число голосов'),
         title = "Число голосов",
    updatemenus = updatemenus)
  
saveWidget(PP, file = '/home/ger/Proj/premia/fulgurigor.github.io/index.html', selfcontained=T, title="Премия Рунета 2018")
saveWidget(PP, file = '/home/ger/Proj/premia/fulgurigor.github.io/separated.html', selfcontained=F, title="Премия Рунета 2018")

