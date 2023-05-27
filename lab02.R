# Vamos utilizar dados do pacote {dados}
# install.packages("dados")

library(dados)

# esquisse: um construtor de ggplot2 --------------------------------------

library(ggplot2)

# Addins -> ggplot2 builder
# gráfico gerado com esquisse
# lembrem de copiar o código

# install.packages("esquisse")

ggplot(dados::diamante) +
  aes(x = quilate, y = preco, colour = corte) +
  geom_point(shape = "diamond", size = 2.05) +
  scale_color_brewer(palette = "Set2", direction = 1) +
  labs(color = "Corte") +
  ggthemes::theme_fivethirtyeight() +
  theme(legend.position = "top")

# extensões do ggplot2 ====================================================

## gghighlight: destacar pontos -------------------------------------------

# install.packages("gghighlight")
library(gghighlight)

dados_starwars |>
  ggplot() +
  aes(x = massa, y = altura) +
  geom_point() +
  gghighlight(massa > 1000, label_key = nome)

dados_starwars |>
  ggplot() +
  aes(x = massa, y = altura) +
  geom_point() +
  gghighlight(altura > 225, label_key = nome)

## ggrepel: posicionar textos ---------------------------------------------

# install.packages("ggrepel")
library(ggrepel)

dados_starwars |>
  ggplot() +
  aes(x = massa, y = altura) +
  geom_point() +
  geom_label_repel(aes(label = nome))

## patchwork: juntar gráficos ---------------------------------------------

# install.packages("patchwork")
library(patchwork)

p1 <- pixar_filmes |>
  ggplot() +
  geom_line(aes(data_lancamento, duracao))

p2 <- pixar_filmes |>
  ggplot() +
  geom_bar(aes(x = classificacao_indicativa))

p3 <- pixar_bilheteria |>
  dplyr::mutate(
    orcamento_alto_baixo = orcamento > 175e6
  ) |>
  ggplot() +
  aes(
    bilheteria_eua_canada, bilheteria_mundial,
    colour = orcamento_alto_baixo
  ) +
  geom_point()

p4 <- pixar_bilheteria |>
  dplyr::mutate(
    orcamento_alto_baixo = orcamento > 175e6
  ) |>
  ggplot() +
  aes(x = bilheteria_mundial, fill = orcamento_alto_baixo) +
  geom_histogram()

p1 + p2
p1 / (p2 + p3)

wrap_plots(p1, p2)

p1 + p2 + p3
(p1 + p2 + p3 + p4) +
  plot_layout()

## gganimate: fazendo GIFs ------------------------------------------------

# install.packages("gganimate")
library(gganimate)

dados_gapminder

dplyr::glimpse(dados_gapminder)

dados_gapminder |>
  ggplot() +
  aes(
    expectativa_de_vida,
    log10(pib_per_capita),
    size = log10(populacao),
    colour = continente
  ) +
  facet_wrap(vars(ano)) +
  geom_point()

anim <- dados_gapminder |>
  ggplot() +
  aes(
    expectativa_de_vida,
    log10(pib_per_capita),
    size = log10(populacao),
    colour = continente
  ) +
  geom_point() +
  transition_time(ano) +
  labs(
    title = "Ano: {frame_time}",
    x = "Expectativa de vida",
    y = "log10(pib per capita)"
  )

animate(
  anim,
  nframes = 40,
  width = 800,
  height = 400,
  start_pause = 10,
  end_pause = 10,
  renderer = gifski_renderer("resultado.gif")
)

# htmlwidgets -------------------------------------------------------------


## plotly: a mágica do ggplotly -------------------------------------------

# install.packages("plotly")
library(plotly)

starwars_sem_jabba <- dados_starwars |>
  dplyr::filter(massa < 1000)

grafico_com_ggplot <- starwars_sem_jabba |>
  ggplot() +
  geom_point(aes(x = massa, y = altura, color = genero)) +
  theme_light()

grafico_com_ggplot

ggplotly(grafico_com_ggplot)

# sem ggplot2
starwars_sem_jabba |>
  plot_ly(
    mode = "markers",
    type = "scatter",
    x = ~ massa,
    y = ~ altura,
    color = ~ genero
  )


## highcharter: gráfico lindo, mas tem problemas de licença ---------------

# install.packages("highcharter")
library(highcharter)

starwars_sem_jabba |>
  hchart(type = "scatter", mapping = hcaes(
    x = massa,
    y = altura,
    group = genero
  ))

## echarts4r: gráfico legal, documentação ruim ----------------------------

# install.packages("echarts4r")
library(echarts4r)

starwars_sem_jabba |>
  group_by(genero) |>
  e_charts(x = massa) |>
  e_scatter(serie = altura, symbol_size = 15)

# mapas -------------------------------------------------------------------

# install.packages("abjData")
library(abjData)

dados_pnud <- abjData::pnud_min |>
  dplyr::filter(uf_sigla == "MG", ano == 2010)

dados_geobr <- geobr::read_municipality("MG")

## mapas com ggplot2 ------------------------------------------------------

dados_pnud_tudo <- abjData::pnud_min |>
  dplyr::filter(uf_sigla == "MG")

dados_com_pnud_tudo <- dados_geobr |>
  dplyr::mutate(code_muni = as.character(code_muni)) |>
  dplyr::inner_join(
    dados_pnud_tudo,
    dplyr::join_by(code_muni == muni_id)
  )

dados_com_pnud_tudo |>
  mutate(ano = as.numeric(ano)) |>
  ggplot(aes(fill = idhm)) +
  geom_sf(
    color = "black",
    linewidth = 0.1
  ) +
  scale_fill_viridis_c(option = 2) +
  facet_wrap(vars(ano))

## leaflet ----------------------------------------------------------------

# install.packages("leaflet")
library(leaflet)

dados_pnud |>
  leaflet() |>
  addProviderTiles("Esri.WorldImagery") |>
  # addTiles(
  #   urlTemplate = "https://{s}.tile.thunderforest.com/spinal-map/{z}/{x}/{y}.png"
  # ) |>
  addMarkers(
    lng = ~ lon,
    lat = ~ lat,
    popup = ~ paste("<b>Nome</b>:", muni_nm),
    clusterOptions = markerClusterOptions()
  )


# grafico campo -----------------------------------------------------------

## ESSE CÓDIGO ESTÁ HORRIVEL. MELHORAR

todas_posicoes <- match |>
  tidyr::unite(home_player_x, dplyr::matches("home.*x[0-9]"), remove = TRUE) |>
  tidyr::unite(away_player_x, dplyr::matches("away.*x[0-9]"), remove = TRUE) |>
  tidyr::unite(home_player_y, dplyr::matches("home.*y[0-9]"), remove = TRUE) |>
  tidyr::unite(away_player_y, dplyr::matches("away.*y[0-9]"), remove = TRUE) |>
  dplyr::rename_with(
    \(x) stringr::str_replace(x, "player_", "player_id"),
    dplyr::matches("_player_[0-9]+")
  ) |>
  tidyr::unite(away_player_id, dplyr::matches("away.*id[0-9]"), remove = TRUE) |>
  tidyr::unite(home_player_id, dplyr::matches("home.*id[0-9]"), remove = TRUE) |>
  tidyr::pivot_longer(c(
    home_player_x, away_player_x, home_player_y, away_player_y,
    away_player_id, home_player_id
  )) |>
  dplyr::select(match_api_id, name, value) |>
  tidyr::separate_rows(value, sep = "_", convert = TRUE) |>
  dplyr::group_by(match_api_id, name) |>
  dplyr::mutate(position_id = seq_len(dplyr::n())) |>
  dplyr::ungroup()

todas_posicoes_wide <- todas_posicoes |>
  tidyr::separate(name, c("home_away", "player", "type"), sep = "_") |>
  dplyr::select(-player) |>
  tidyr::pivot_wider(names_from = type, values_from = value) |>
  dplyr::mutate(
    y = dplyr::if_else(home_away == "home", y, max(y, na.rm = TRUE) - y + 2),
    x = dplyr::if_else(home_away == "home", x, max(x, na.rm = TRUE) - x + 1)
  )

library(emojifont)

testLabels <- fontawesome(c('fa-android'))
todas_posicoes_wide |>
  dplyr::mutate(lab = testLabels) |>
  dplyr::filter(!is.na(x)) |>
  dplyr::filter(match_api_id %in% sample(unique(match_api_id), 9)) |>
  ggplot2::ggplot() +
  ggplot2::aes(x, y, colour = home_away) +
  ggplot2::geom_text(ggplot2::aes(label = lab), size = 5, family='fontawesome-webfont') +
  # emojifont::geom_fontawesome("fa-github", color='black') +
  ggplot2::facet_wrap(~match_api_id) +
  ggplot2::theme_minimal() +
  ggplot2::scale_x_continuous(breaks = c(3.5, 6.5)) +
  ggplot2::scale_y_continuous(breaks = c(2, 4, 6, 8, 10) +.5) +
  ggplot2::geom_hline(yintercept = 6.5, colour = "white", linetype = 1) +
  ggplot2::scale_color_viridis_d(begin = .6, end = .8, option = 1) +
  ggplot2::theme(
    # plot.background = ggplot2::element_rect(fill = "darkgreen"),
    panel.background = ggplot2::element_rect(fill = "darkgreen"),
    axis.text = ggplot2::element_blank(),
    panel.grid.minor = ggplot2::element_blank(),
    panel.grid.major = ggplot2::element_line(linetype = "dashed"),
    panel.border = ggplot2::element_rect(fill = "transparent", color = "white"),
    legend.position = "bottom"
  ) +
  ggplot2::labs(x = "", y = "") +
  ggplot2::coord_fixed(ratio = 1)

