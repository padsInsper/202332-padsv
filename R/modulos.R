home_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      box(
        title = "Título",
        status = "info",
        maximizable = TRUE,
        closable = FALSE,
        solidHeader = TRUE,
        "Mensagem inicial",
        width = 9,
        plotly::plotlyOutput(ns("grafico"))
      ),
      box(
        width = 3,
        status = "secondary"
      )
    )
  )
}

home_server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      output$grafico <- plotly::renderPlotly({

        p <- ggplot2::ggplot(dados::pinguins) +
          ggplot2::aes(massa_corporal) +
          ggplot2::geom_histogram()

        plotly::ggplotly(p)

      })
    }
  )
}

plot_ui <- function(id) {
  ns <- NS(id)
  tagList(

    fluidRow(
      box(
        title = "Título",
        status = "info",
        maximizable = TRUE,
        closable = FALSE,
        solidHeader = TRUE,
        "Mensagem inicial",
        width = 9,
        plotly::plotlyOutput(ns("grafico"))
      ),
      box(
        width = 3,
        status = "secondary"
      )
    )

  )
}

plot_server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      output$grafico <- plotly::renderPlotly({

        p <- ggplot2::ggplot(dados::pinguins) +
          ggplot2::aes(massa_corporal) +
          ggplot2::geom_density()

        plotly::ggplotly(p)

      })
    }
  )
}
