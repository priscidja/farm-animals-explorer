build_story_plot_text <- function(lang = "en") {
  labels <- list(
    en = list(
      karyotype_title = "The karyotype paradox",
      karyotype_subtitle = "A similar amount of DNA can be packaged into very different chromosome counts.",
      genome_size_panel = "Genome size (Gb)",
      chromosome_panel = "Diploid chromosome count (2n)",
      genome_size_axis = "Genome size (Gb)",
      chromosome_axis = "Chromosome count (2n)",
      species_axis = "Species",
      chromosome_story_title = "Chromosome length comparison",
      chromosome_story_subtitle = "Pigs package similar DNA into fewer and often larger chromosomes.",
      chromosome_index = "Chromosome index",
      chromosome_length = "Length (Mb)",
      composition_title = "What is inside a livestock genome?",
      composition_subtitle = "Less than 2% of the genome directly codes for proteins.",
      composition_share = "Share of genome",
      divergence_title = "Phylogeny of the four livestock groups",
      divergence_subtitle = "Sheep and goats cluster more closely, while pigs branch earlier within Artiodactyla.",
      divergence_axis = "Relative divergence distance"
    ),
    es = list(
      karyotype_title = "La paradoja del cariotipo",
      karyotype_subtitle = "Una cantidad similar de ADN puede empaquetarse en conteos cromosomicos muy distintos.",
      genome_size_panel = "Tamano del genoma (Gb)",
      chromosome_panel = "Numero diploide de cromosomas (2n)",
      genome_size_axis = "Tamano del genoma (Gb)",
      chromosome_axis = "Conteo cromosomico (2n)",
      species_axis = "Especie",
      chromosome_story_title = "Comparacion del tamano cromosomico",
      chromosome_story_subtitle = "Los cerdos empaquetan una cantidad similar de ADN en menos cromosomas y a menudo mas grandes.",
      chromosome_index = "Indice cromosomico",
      chromosome_length = "Longitud (Mb)",
      composition_title = "Que hay dentro del genoma ganadero?",
      composition_subtitle = "Menos del 2% del genoma codifica directamente proteinas.",
      composition_share = "Proporcion del genoma",
      divergence_title = "Filogenia de los cuatro grupos ganaderos",
      divergence_subtitle = "Ovejas y cabras estan mas proximas, mientras que los cerdos se separan antes dentro de Artiodactyla.",
      divergence_axis = "Distancia relativa de divergencia"
    ),
    pt = list(
      karyotype_title = "O paradoxo do cariotipo",
      karyotype_subtitle = "Uma quantidade semelhante de DNA pode ser organizada em contagens cromossomicas bem diferentes.",
      genome_size_panel = "Tamanho do genoma (Gb)",
      chromosome_panel = "Numero diploide de cromossomos (2n)",
      genome_size_axis = "Tamanho do genoma (Gb)",
      chromosome_axis = "Contagem cromossomica (2n)",
      species_axis = "Especie",
      chromosome_story_title = "Comparacao do tamanho dos cromossomos",
      chromosome_story_subtitle = "Os porcos organizam uma quantidade semelhante de DNA em menos cromossomos e frequentemente maiores.",
      chromosome_index = "Indice do cromossomo",
      chromosome_length = "Comprimento (Mb)",
      composition_title = "O que existe dentro do genoma dos animais?",
      composition_subtitle = "Menos de 2% do genoma codifica proteinas diretamente.",
      composition_share = "Proporcao do genoma",
      divergence_title = "Filogenia dos quatro grupos de animais",
      divergence_subtitle = "Ovelhas e cabras formam o agrupamento mais proximo, enquanto os porcos se separam antes dentro de Artiodactyla.",
      divergence_axis = "Distancia relativa de divergencia"
    )
  )

  labels[[lang]] %||% labels$en
}

story_plot_title <- function(text) {
  list(
    text = as.character(text %||% ""),
    font = list(size = 15, color = "#824C71")
  )
}

story_axis_title <- function(text) {
  list(
    text = as.character(text %||% ""),
    font = list(size = 12, color = "#824C71")
  )
}

story_species_palette <- function(species_palette) {
  defaults <- c(
    cattle = "#CFF6F8",
    sheep = "#DDE4FF",
    goat = "#F1DAFF",
    pig = "#FFD8F1"
  )

  merged <- defaults
  overlapping <- intersect(names(defaults), names(species_palette))
  merged[overlapping] <- unname(species_palette[overlapping])
  merged
}

story_species_order <- c("cattle", "sheep", "goat", "pig")

story_chromosome_counts <- c(
  cattle = 60,
  sheep = 54,
  goat = 60,
  pig = 38
)

story_species_labels <- function(lang = "en") {
  labels <- list(
    en = c(
      cattle = "Cattle",
      sheep = "Sheep",
      goat = "Goat",
      pig = "Pig"
    ),
    es = c(
      cattle = "Bovino",
      sheep = "Oveja",
      goat = "Cabra",
      pig = "Cerdo"
    ),
    pt = c(
      cattle = "Bovino",
      sheep = "Ovelha",
      goat = "Cabra",
      pig = "Porco"
    )
  )

  labels[[lang]] %||% labels$en
}

story_chromosome_lengths <- data.frame(
  species_id = c(
    rep("cattle", 29),
    rep("sheep", 26),
    rep("goat", 29),
    rep("pig", 18)
  ),
  chromosome_index = c(1:29, 1:26, 1:29, 1:18),
  length_mb = c(
    158.53, 136.23, 121.01, 120.00, 120.09, 117.81, 110.68, 113.32, 105.45, 103.31,
    106.98, 87.22, 83.47, 82.40, 85.01, 81.01, 73.17, 65.82, 63.45, 71.97,
    69.86, 60.77, 52.50, 62.32, 42.35, 51.99, 45.61, 45.94, 51.10,
    278.62, 250.20, 226.09, 121.58, 108.22, 118.47, 101.27, 91.79, 95.18, 86.46,
    62.55, 80.40, 83.51, 66.52, 82.54, 71.90, 73.17, 67.98, 60.56, 51.45,
    47.51, 51.51, 62.44, 42.63, 44.86, 45.05,
    157.40, 136.51, 120.04, 120.73, 119.02, 117.64, 108.43, 112.67, 91.57, 101.09,
    106.23, 87.28, 83.03, 94.67, 81.90, 79.37, 71.14, 67.28, 62.52, 71.78,
    69.43, 60.28, 48.87, 62.31, 42.86, 51.42, 44.71, 44.67, 51.33,
    284.94, 160.33, 138.90, 132.28, 109.54, 171.39, 130.78, 138.97, 141.18, 80.15,
    80.49, 61.59, 209.49, 146.05, 140.59, 80.04, 64.11, 56.78
  ),
  stringsAsFactors = FALSE
)

story_genome_composition <- data.frame(
  category = c(
    "Transposons / repetitive DNA",
    "Introns",
    "Intergenic DNA",
    "Protein-coding exons"
  ),
  percentage = c(45.0, 34.0, 19.5, 1.5),
  fill = c("#824C71", "#B8B8D1", "#E3E8FF", "#CCFFFF"),
  stringsAsFactors = FALSE
)

story_phylogeny_data <- data.frame(
  ancestor = c(
    "Artiodactyla",
    "Ruminantia",
    "Ruminantia",
    "Bovidae",
    "Bovidae",
    "Caprinae",
    "Caprinae"
  ),
  descendant = c(
    "Sus scrofa",
    "Bos taurus",
    "Bovidae",
    "Caprinae",
    "Bos taurus",
    "Ovis aries",
    "Capra hircus"
  ),
  x_start = c(0.00, 0.12, 0.12, 0.18, 0.18, 0.24, 0.24),
  x_end = c(0.19, 0.07, 0.18, 0.24, 0.07, 0.03, 0.03),
  y_start = c(4, 3, 3, 2, 2, 1.5, 1.5),
  y_end = c(1, 3, 2, 1.5, 3, 2, 1),
  stringsAsFactors = FALSE
)

story_phylogeny_tips <- data.frame(
  label = c("Sus scrofa", "Bos taurus", "Ovis aries", "Capra hircus"),
  x = c(0.19, 0.07, 0.03, 0.03),
  y = c(4, 3, 2, 1),
  species_id = c("pig", "cattle", "sheep", "goat"),
  stringsAsFactors = FALSE
)

build_karyotype_paradox_plot <- function(genome_data, species_palette, lang = "en") {
  labels <- build_story_plot_text(lang)
  palette <- story_species_palette(species_palette)

  summary_df <- aggregate(
    genome_mb ~ species_id + display_name,
    data = genome_data,
    FUN = function(x) mean(as.numeric(x), na.rm = TRUE)
  )

  scientific_df <- aggregate(
    scientific_name ~ species_id,
    data = genome_data,
    FUN = function(x) {
      values <- x[!is.na(x) & nzchar(trimws(x))]
      if (length(values) == 0) "" else as.character(values[[1]])
    }
  )

  summary_df <- summary_df[summary_df$species_id %in% names(story_chromosome_counts), , drop = FALSE]
  summary_df$scientific_name <- scientific_df$scientific_name[match(summary_df$species_id, scientific_df$species_id)]
  summary_df$genome_gb <- round(summary_df$genome_mb / 1000, 2)
  summary_df$chromosomes_2n <- unname(story_chromosome_counts[summary_df$species_id])
  summary_df$color_hex <- unname(palette[summary_df$species_id])
  summary_df$display_name <- factor(
    summary_df$display_name,
    levels = summary_df$display_name[order(match(summary_df$species_id, story_species_order))]
  )
  summary_df <- summary_df[order(summary_df$display_name), , drop = FALSE]

  genome_panel <- plotly::plot_ly(
    data = summary_df,
    x = ~display_name,
    y = ~genome_gb,
    type = "bar",
    marker = list(color = summary_df$color_hex),
    text = ~paste0(formatC(genome_gb, format = "f", digits = 2), " Gb"),
    textposition = "outside",
    cliponaxis = FALSE,
    hovertemplate = paste0(
      "<b>%{x}</b><br>",
      "<i>%{customdata}</i><br>",
      labels$genome_size_axis, ": %{y:.2f}<extra></extra>"
    ),
    customdata = ~scientific_name,
    showlegend = FALSE
  )

  chromosome_panel <- plotly::plot_ly(
    data = summary_df,
    x = ~display_name,
    y = ~chromosomes_2n,
    type = "bar",
    marker = list(color = summary_df$color_hex),
    text = ~paste0("2n = ", chromosomes_2n),
    textposition = "outside",
    cliponaxis = FALSE,
    hovertemplate = paste0(
      "<b>%{x}</b><br>",
      "<i>%{customdata}</i><br>",
      labels$chromosome_axis, ": %{y}<extra></extra>"
    ),
    customdata = ~scientific_name,
    showlegend = FALSE
  )

  plotly::subplot(genome_panel, chromosome_panel, margin = 0.08) %>%
    plotly::layout(
      title = list(
        text = paste0(
          as.character(labels$karyotype_title),
          "<br><sup>",
          as.character(labels$karyotype_subtitle),
          "</sup>"
        ),
        font = list(size = 15, color = "#824C71")
      ),
      margin = list(l = 70, r = 20, b = 72, t = 96),
      xaxis = list(
        title = story_axis_title(labels$species_axis),
        tickangle = -18
      ),
      yaxis = list(
        title = story_axis_title(labels$genome_size_axis),
        rangemode = "tozero",
        range = c(0, max(summary_df$genome_gb, na.rm = TRUE) * 1.22),
        titlefont = list(size = 11, color = "#824C71")
      ),
      xaxis2 = list(
        title = story_axis_title(labels$species_axis),
        tickangle = -18
      ),
      yaxis2 = list(
        title = story_axis_title(labels$chromosome_axis),
        rangemode = "tozero",
        range = c(0, max(summary_df$chromosomes_2n, na.rm = TRUE) * 1.18),
        titlefont = list(size = 11, color = "#824C71")
      ),
      annotations = list(
        list(
          x = 0.22,
          y = 1.02,
          xref = "paper",
          yref = "paper",
          text = paste0("<b>", as.character(labels$genome_size_panel), "</b>"),
          showarrow = FALSE,
          font = list(size = 12, color = "#824C71")
        ),
        list(
          x = 0.78,
          y = 1.02,
          xref = "paper",
          yref = "paper",
          text = paste0("<b>", as.character(labels$chromosome_panel), "</b>"),
          showarrow = FALSE,
          font = list(size = 12, color = "#824C71")
        )
      ),
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor = "rgba(0,0,0,0)"
    )
}

build_chromosome_idiogram_plot <- function(species_palette, lang = "en") {
  labels <- build_story_plot_text(lang)
  palette <- story_species_palette(species_palette)
  species_labels <- story_species_labels(lang)
  scientific_names <- c(
    cattle = "Bos taurus",
    sheep = "Ovis aries",
    goat = "Capra hircus",
    pig = "Sus scrofa domesticus"
  )

  df <- story_chromosome_lengths
  df <- df[df$species_id %in% story_species_order, , drop = FALSE]
  df$display_name <- unname(species_labels[df$species_id])
  df$scientific_name <- unname(scientific_names[df$species_id])

  p <- plotly::plot_ly()

  for (species_id in story_species_order) {
    species_df <- df[df$species_id == species_id, , drop = FALSE]
    if (nrow(species_df) == 0) {
      next
    }

    p <- p %>%
      plotly::add_bars(
        data = species_df,
        x = ~chromosome_index,
        y = ~length_mb,
        name = species_df$display_name[[1]],
        marker = list(color = unname(palette[[species_id]])),
        customdata = ~scientific_name,
        hovertemplate = paste0(
          "<b>%{fullData.name}</b><br>",
          "<i>%{customdata}</i><br>",
          labels$chromosome_index, ": %{x}<br>",
          labels$chromosome_length, ": %{y:.2f} Mb<extra></extra>"
        )
      )
  }

  p %>%
    plotly::layout(
      title = list(
        text = paste0(
          as.character(labels$chromosome_story_title),
          "<br><sup>",
          as.character(labels$chromosome_story_subtitle),
          "</sup>"
        ),
        font = list(size = 15, color = "#824C71")
      ),
      barmode = "group",
      margin = list(l = 60, r = 20, b = 55, t = 75),
      legend = list(orientation = "h", y = 1.08, x = 0.02),
      xaxis = list(
        title = story_axis_title(labels$chromosome_index),
        dtick = 2
      ),
      yaxis = list(title = story_axis_title(labels$chromosome_length))
    )
}

build_genome_composition_plot <- function(lang = "en") {
  labels <- build_story_plot_text(lang)

  plotly::plot_ly(
    data = story_genome_composition,
    labels = ~category,
    values = ~percentage,
    type = "pie",
    hole = 0.62,
    sort = FALSE,
    marker = list(colors = story_genome_composition$fill),
    textinfo = "label+percent",
    hovertemplate = paste0(
      "%{label}<br>",
      labels$composition_share, ": %{value:.1f}%<extra></extra>"
    )
  ) %>%
    plotly::layout(
      title = list(
        text = paste0(
          as.character(labels$composition_title),
          "<br><sup>",
          as.character(labels$composition_subtitle),
          "</sup>"
        ),
        font = list(size = 15, color = "#824C71")
      ),
      margin = list(l = 10, r = 10, b = 40, t = 75),
      legend = list(orientation = "h", y = -0.05, x = 0.02)
    )
}

build_phylogeny_tree_plot <- function(species_palette, lang = "en") {
  labels <- build_story_plot_text(lang)
  palette <- story_species_palette(species_palette)

  branch_df <- story_phylogeny_data
  tip_df <- story_phylogeny_tips
  tip_df$color_hex <- unname(palette[tip_df$species_id])

  plotly::plot_ly(type = "scatter", mode = "lines") %>%
    plotly::add_segments(
      data = branch_df,
      x = ~x_start,
      xend = ~x_end,
      y = ~y_start,
      yend = ~y_end,
      line = list(color = "#8D9E99", width = 4),
      hoverinfo = "none",
      showlegend = FALSE
    ) %>%
    plotly::add_markers(
      data = tip_df,
      x = ~x,
      y = ~y,
      marker = list(size = 18, color = tip_df$color_hex, line = list(color = "white", width = 1.4)),
      text = ~label,
      hovertemplate = "%{text}<extra></extra>",
      showlegend = FALSE
    ) %>%
    plotly::add_text(
      data = tip_df,
      x = ~x + 0.018,
      y = ~y,
      text = ~label,
      textposition = "middle right",
      textfont = list(size = 13, color = "#824C71"),
      hoverinfo = "none",
      showlegend = FALSE
    ) %>%
    plotly::layout(
      title = list(
        text = paste0(
          as.character(labels$divergence_title),
          "<br><sup>",
          as.character(labels$divergence_subtitle),
          "</sup>"
        ),
        font = list(size = 15, color = "#824C71")
      ),
      margin = list(l = 30, r = 140, b = 45, t = 75),
      xaxis = list(title = story_axis_title(labels$divergence_axis), range = c(-0.01, 0.27), zeroline = FALSE),
      yaxis = list(title = "", showticklabels = FALSE, zeroline = FALSE, gridcolor = "rgba(0,0,0,0)"),
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor = "rgba(0,0,0,0)"
    )
}
