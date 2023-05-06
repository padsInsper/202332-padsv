
# Fonte: https://www.kaggle.com/datasets/hugomathien/soccer?resource=download
# salvar em data-raw/soccer-database.sqlite
con <- RSQLite::dbConnect(
  RSQLite::SQLite(),
  "data-raw/soccer-database.sqlite"
)

tabelas_nm <- RSQLite::dbListTables(con)

tabelas <- purrr::map(
  tabelas_nm,
  \(x) tibble::as_tibble(janitor::clean_names(RSQLite::dbReadTable(con, x)))
) |>
  purrr::set_names(tolower(tabelas_nm)) |>
  purrr::discard_at("sqlite_sequence")

fs::dir_create("data-raw/rds/")
fs::dir_create("data-raw/parquet/")

purrr::iwalk(tabelas, \(x, y) {
  readr::write_rds(x, paste0("data-raw/rds/", y, ".rds"))
  arrow::write_parquet(x, paste0("data-raw/parquet/", y, ".parquet"))
})

match_min <- match |>
  dplyr::inner_join(country, dplyr::join_by(country_id == id)) |>
  dplyr::select(id:away_team_goal, country_name = name) |>
  dplyr::relocate(country_name, .before = country_id)

readr::write_rds(match_min, "data-raw/rds/match_min.rds")
arrow::write_parquet(match_min, "data-raw/parquet/match_min.parquet")
