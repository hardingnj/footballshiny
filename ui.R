library(shiny)

# Define UI for miles per gallon application
shinyUI(pageWithSidebar(

  # Application title
  headerPanel("Predictability in European football 1891-2013"),

  # Sidebar with controls to select the variable to plot against mpg
  # and to specify whether outliers should be included
  sidebarPanel(
    sliderInput("range", "Years:", format = "#", min = 1891, max = 2012, value = c(1960,2012)),
    checkboxInput("smooth", "Fit Loess smoothing curve", TRUE),
    helpText(""),
    helpText("Choose the leagues to be included in the plot:"),
    checkboxInput("england", "England", TRUE),
    checkboxInput("scotland", "Scotland", TRUE),
    checkboxInput("france", "France", FALSE),
    checkboxInput("germany", "Germany", FALSE),
    checkboxInput("italy", "Italy", FALSE),
    checkboxInput("spain", "Spain", FALSE)
  ),

  # Show the caption and show the plot
  mainPanel(
    h3(textOutput("caption")),
    textOutput("predictabilityDesc"),
    plotOutput("lineplot"),
    textOutput("churnDesc"),
    plotOutput("churn")
  )
))

