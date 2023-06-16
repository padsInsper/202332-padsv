library(tidyverse)
match_min <- readr::read_rds("data-raw/rds/match_min.rds")
team <- read_rds("data-raw/rds/team.rds")
team_attributes <- read_rds("data-raw/rds/team_attributes.rds")


# exercício 1 -------------------------------------------------------------


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

p_ex1 <- sumario |>
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
    plot.caption = element_text(face = "italic"),
    legend.position = "none"
  )

readr::write_rds(p_ex1, "data-raw/lab02_ex1.rds")


# exercício 2 -------------------------------------------------------------

sumario <- match_min |>
  inner_join(
    select(team, team_api_id, home_team_long_name = team_long_name),
    join_by(home_team_api_id == team_api_id)
  ) |>
  inner_join(
    select(team, team_api_id, away_team_long_name = team_long_name),
    join_by(away_team_api_id == team_api_id)
  ) |>
  filter(country_name == "Spain") |>
  select(
    season, date, home_team_goal, away_team_goal,
    home_team_long_name, away_team_long_name
  ) |>
  unite(home_team, home_team_long_name, home_team_goal, sep = "_") |>
  unite(away_team, away_team_long_name, away_team_goal, sep = "_") |>
  pivot_longer(
    c(home_team, away_team)
  ) |>
  separate(value, c("team", "goals"), "_", convert = TRUE) |>
  group_by(season, team) |>
  summarise(goals = sum(goals), .groups = "drop") |>
  mutate(
    season = as.numeric(str_extract(season, "[0-9]+")),
    team = fct_reorder(team, goals, mean)
  ) |>
  # apenas times que participaram de todos os campeonatos
  group_by(team) |>
  filter(n() == 8) |>
  ungroup()

anim <- sumario |>
  ggplot(aes(goals, team)) +
  geom_col(size = 2) +
  gghighlight::gghighlight(
    team %in% c("FC Barcelona", "Real Madrid CF"),
    calculate_per_facet = TRUE,
    use_direct_label = FALSE
  ) +
  transition_time(season) +
  theme_minimal(16) +
  labs(
    x = "Total Goals",
    y = "Team",
    title = "Goals in La Liga",
    subtitle = "Season {round(frame_time)}/{round(frame_time)+1}"
  )

anim |>
  animate(
    height = 4, width = 6, units = "in", res = 300,
    renderer = gifski_renderer("slides/img/animate.gif")
  )
