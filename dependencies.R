# install missing packages
required_packages = c("data.table", "DT", "ggridges", "ggplot2", "plotly", "rintrojs", "shiny", "shinyBS", "shinycssloaders",
                      "shinydashboard", "shinyjs", "shinyWidgets", "tidyverse", "htmlwidgets")
new.packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]

if (length(new.packages)) {
  install.packages(new.packages)
}

rm(new.packages)

library(data.table)
library(DT)
library(ggridges)
library(ggplot2)
library(plotly)
library(rintrojs)
library(shiny)
library(shinyBS)
library(shinycssloaders)
library(shinydashboard)
library(shinyjs)
library(shinyWidgets)
library(tidyverse)
library(htmlwidgets)
library(xlsx)
