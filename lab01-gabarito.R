library(tidyverse)
match_min <- readr::read_rds("data-raw/rds/match_min.rds")
## Transformação

cores <- c("#C4161C", "#009491")

sumario <- match_min |>
  select(country_id, country_name, home_team_goal, away_team_goal) |>
  filter(country_id %in% c(21518, 1729, 4769, 7809, 10257)) |>
  mutate(total_goals = home_team_goal + away_team_goal) |>
  # group_by(country_name) |>
  summarise(
    media = mean(total_goals),
    desvio_padrao = sd(total_goals),
    mediana = median(total_goals),
    .by = c(country_name)
  ) |>
  arrange(desc(media))

## Gráfico de barras

### exploratorio

sumario |>
  ggplot(aes(x = media, y = country_name)) +
  geom_col()

### otimizado

sumario |>
  mutate(
    cor_diferente = country_name == "Germany",
    country_name = case_match(
      country_name,
      "Germany" ~ "Alemanha",
      "Spain" ~ "Espanha",
      "England" ~ "Inglaterra",
      "Italy" ~ "Itália",
      "France" ~ "França"
    ),
    country_name = fct_reorder(country_name, media)
  ) |>
  ggplot() +
  aes(x = media, y = country_name, fill = cor_diferente) +
  geom_col(show.legend = FALSE) +
  theme_minimal(16) +
  scale_fill_manual(values = cores) +
  labs(
    x = "Média de gols",
    y = "País",
    title = "O campeonato alemão tem mais gols",
    subtitle = "Jogos das ligas nacionais entre 2008 e 2016",
    caption = "Fonte: European Soccer Database"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = .5),
    plot.subtitle = element_text(hjust = .5),
    plot.caption = element_text(face = "italic")
  )

#---

## Pivotagem
team <- read_rds("data-raw/rds/team.rds")
team_attributes <- read_rds("data-raw/rds/team_attributes.rds")

times <- c(243, 11, 21, 73, 47)

team_filter <- team |>
  filter(team_fifa_api_id %in% times) |>
  select(-id)

sumario <- team_attributes |>
  inner_join(
    team_filter,
    join_by(team_api_id, team_fifa_api_id)
  ) |>
  select(-ends_with("class")) |>
  mutate(year = year(ymd_hms(date))) |>
  pivot_longer(c(build_up_play_speed:defence_team_width)) |>
  separate_wider_delim(
    name, delim = "_",
    names = c("type", "metric"),
    too_many = "merge"
  ) |>
  summarise(
    value = mean(value, na.rm = TRUE),
    .by = c(year, type, team_short_name, team_long_name)
  )

### Gráfico exploratório
sumario |>
  ggplot(aes(x = year, y = value, colour = type)) +
  geom_line() +
  facet_wrap(~team_long_name)

### Gráfico otimizado
sumario |>
  mutate(type = case_match(
    type,
    "build" ~ "Construção",
    "chance" ~ "Criação de chances",
    "defence" ~ "Defesa"
  )) |>
  ggplot(aes(x = year, y = value, colour = type)) +
  geom_smooth(
    aes(group = team_long_name, colour = NULL),
    colour = "transparent",
    fill = "#C4161C",
    alpha = .1
  ) +
  geom_line(linewidth = 1.2) +
  geom_point() +
  facet_wrap(~team_long_name) +
  labs(
    title = "Milan é o time mais balanceado",
    subtitle = "Comparação de 5 times europeus",
    caption = "Fonte: European Soccer Database",
    x = "Ano",
    y = "Estatística",
    colour = "Categoria"
  ) +
  scale_colour_manual(values = c("#C4161C", "#3CBFAE", "#BCBEC0")) +
  theme_minimal(14) +
  theme(
    legend.position = c(.8, .3),
    strip.background = element_rect(fill = "gray90", color = "transparent"),
    panel.grid.minor.x = element_blank(),
    plot.title = element_text(face = "bold"),
    plot.caption = element_text(face = "italic")
  )
