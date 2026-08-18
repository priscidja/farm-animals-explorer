library(shiny)
library(bslib)
library(tidyverse)
library(plotly)

# 1. Define genome composition data
composition_df <- tibble(
  category = c("Transposons / Repeats", "Introns", "Intergenic DNA", "Protein-Coding Exons"),
  pct = c(45.0, 34.0, 19.5, 1.5)
)

# 2. Build the interactive Plotly Donut Chart matching your app's palette
p_pie <- plot_ly(
  composition_df, 
  labels = ~category, 
  values = ~pct, 
  type = "pie",
  hole = 0.6,
  marker = list(colors = c("#8c7284", "#bfa8b6", "#d1c2ca", "#cb7a98")),
  textinfo = "label+percent",
  hoverinfo = "text",
  text = ~paste0("<b>", category, "</b><br>", pct, "% of overall genome")
) %>%
  layout(
    title = list(
      text = "<b>Genome Architecture Breakdown</b><br><sup>Less than 2% of livestock DNA codes directly for proteins</sup>",
      font = list(size = 15, color = "#5c3e4f")
    ),
    showlegend = TRUE,
    legend = list(orientation = "h", x = 0.1, y = -0.1)
  ) %>% 
  config(displayModeBar = FALSE)

# 3. Explicit call to display in Positron's Viewer/Plots panel:
p_pie

shiny::runApp()


