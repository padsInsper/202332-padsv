library(shiny)

ui <- bs4Dash::dashboardPage(
  dark = NULL,

  controlbar = bs4Dash::dashboardControlbar(
    skin = "light",
    # shiny::column(12, filtros),
    disable = TRUE
  ),

  header = bs4Dash::dashboardHeader(
    title = "Meu Dashboard",
    skin = "light",
    status = "white",
    controlbarIcon = icon("table-cells")
  ),

  sidebar = bs4Dash::dashboardSidebar(
    skin = "light",
    status = "primary",
    title = "Titulo",
    border = TRUE,
    collapsed = FALSE,
    minified = TRUE,
    bs4Dash::bs4SidebarMenu(
      bs4Dash::bs4SidebarMenuItem(
        "Home",
        tabName = "home",
        icon = icon("home")
      ),
      bs4Dash::bs4SidebarMenuItem(
        "Análises",
        tabName = "plot",
        icon = icon("chart-simple")
      )
    )
  ),

  body = bs4Dash::dashboardBody(
    bs4Dash::bs4TabItems(
      bs4Dash::bs4TabItem("home"),
      bs4Dash::bs4TabItem("plot")
    )
  ),

  footer = bs4Dash::dashboardFooter(
    left = shiny::a(
      href = "https://insper.edu.br",
      target = "_blank", "Insper"
    ),
    right = paste(
      format(Sys.Date(), "%Y"),
      "desenvolvido com \u2764\ufe0f pelo Insper",
      sep = " | "
    )
  )
)

server <- function(input, output, session) {


}


shiny::shinyApp(ui, server)
