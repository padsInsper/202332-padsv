library(shiny)
library(bs4Dash)

dados::pinguins

tema <- fresh::create_theme(
  fresh::bs4dash_status(
    info = "#FF0000",
    secondary = "#FF00DD"
  )
)

ui <- dashboardPage(
  controlbar = dashboardControlbar(
    skin = "light",
    selectInput("sexo", "Sexo", c("macho", "fêmea"))
  ),
  header = dashboardHeader(
    # title = shiny::a("link", href = "https://google.com")
    title = "Dashboard",
    skin = "light"
  ),
  sidebar = dashboardSidebar(
    collapsed = FALSE,
    bs4SidebarMenu(
      bs4SidebarMenuItem(
        "Home",
        tabName = "home",
        icon = icon("linux")
      ),
      bs4SidebarMenuItem(
        "Plots",
        tabName = "plot",
        icon = icon("chart-simple")
      )
    )
  ),
  body = dashboardBody(
    fresh::use_theme(tema),
    bs4TabItems(
      bs4TabItem(
        tabName = "home",
        home_ui("page1")
      ),
      bs4TabItem(
        tabName = "plot",
        plot_ui("page2")
      )
    )
  ),
  footer = dashboardFooter(
    left = "Msg da esquerda",
    right = "Feito com <3 pelo pads Insper"
  )
)

server <- function(input, output, session) {
  home_server("page1")
  plot_server("page2")
}


shinyApp(ui, server)
