library(tidyverse)


# leitura -----------------------------------------------------------------

match_min <- read_rds("data-raw/rds/match_min.rds")
team <- read_rds("data-raw/rds/team.rds")
team_attributes <- read_rds("data-raw/rds/team_attributes.rds")

glimpse(match_min)


# exercício 1.1. ----------------------------------------------------------

sumario <- match_min |>
  select(country_id, country_name, home_team_goal, away_team_goal)
# ...

# exercício 1.2. ----------------------------------------------------------

sumario |>
  ggplot() +
  # ... +
  geom_col()

# exercício 1.3. ----------------------------------------------------------

# barras otimizado


# exercício 2.1. ----------------------------------------------------------


# exercício 2.2. ----------------------------------------------------------


# exercício 2.3. ----------------------------------------------------------
