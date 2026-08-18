`%||%` <- function(left, right) {
  if (is.null(left) || length(left) == 0) {
    return(right)
  }

  if (length(left) == 1 && is.na(left)) {
    return(right)
  }

  left
}

assert_columns <- function(data, required, object_name) {
  missing_columns <- setdiff(required, names(data))

  if (length(missing_columns) > 0) {
    stop(
      sprintf(
        "%s is missing required columns: %s",
        object_name,
        paste(missing_columns, collapse = ", ")
      ),
      call. = FALSE
    )
  }
}

ensure_optional_columns <- function(data, columns) {
  for (column_name in columns) {
    if (!column_name %in% names(data)) {
      data[[column_name]] <- NA_character_
    }
  }

  data
}

split_pipe <- function(text) {
  if (length(text) == 0 || is.na(text) || !nzchar(text)) {
    return(character())
  }

  trimws(strsplit(text, "\\|")[[1]])
}

collapse_pipe <- function(text) {
  values <- split_pipe(text)

  if (length(values) == 0) {
    return("")
  }

  paste(values, collapse = ", ")
}

as_numeric_safe <- function(x) {
  suppressWarnings(as.numeric(gsub(",", "", x)))
}

coalesce_text <- function(primary, fallback) {
  if (length(primary) == 0) {
    return(fallback)
  }

  ifelse(is.na(primary) | primary == "", fallback, primary)
}

load_species_profiles <- function(path) {

  data <- read.csv(
    path,
    sep = ";",
    stringsAsFactors = FALSE,
    check.names = FALSE,
    row.names = NULL
  )

  assert_columns(
    data,
    c(
      "species_id",
      "display_name",
      "scientific_name",
      "common_name_en",
      "common_name_es",
      "kingdom",
      "phylum",
      "class",
      "order",
      "family",
      "genus",
      "digestive_type",
      "card_summary",
      "basic_biology",
      "religion_notes",
      "teaching_focus",
      "color_hex"
    ),
    "species_profiles.csv"
  )

  data <- ensure_optional_columns(
    data,
    c(
      "display_name_es",
      "display_name_pt",
      "digestive_type_es",
      "digestive_type_pt",
      "card_summary_es",
      "card_summary_pt",
      "basic_biology_es",
      "basic_biology_pt",
      "religion_notes_es",
      "religion_notes_pt",
      "teaching_focus_es",
      "teaching_focus_pt"
    )
  )

  data$species_id <- tolower(trimws(data$species_id))
  data
}

load_genome_summary <- function(path) {
  data <- read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)

  assert_columns(
    data,
    c(
      "species_id",
      "scientific_name",
      "accession",
      "assembly_name",
      "assembly_level",
      "source_db",
      "genome_mb",
      "gc_percent",
      "scaffold_n50_mb",
      "data_status",
      "data_note"
    ),
    "genome_summary.csv"
  )

  data$species_id <- tolower(trimws(data$species_id))
  data$genome_mb <- as_numeric_safe(data$genome_mb)
  data$gc_percent <- as_numeric_safe(data$gc_percent)
  data$scaffold_n50_mb <- as_numeric_safe(data$scaffold_n50_mb)

  if (!"display_name" %in% names(data)) {
    data$display_name <- NA_character_
  }

  if (!"breed" %in% names(data)) {
    data$breed <- NA_character_
  }

  data
}

load_science_use <- function(path) {
  data <- read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)

  assert_columns(
    data,
    c(
      "species_id",
      "title_en",
      "title_es",
      "overview_en",
      "overview_es",
      "primary_uses_en",
      "primary_uses_es",
      "key_advantage_en",
      "key_advantage_es",
      "science_image_file"
    ),
    "science_use.csv"
  )

  data <- ensure_optional_columns(
    data,
    c(
      "title_pt",
      "overview_pt",
      "primary_uses_pt",
      "key_advantage_pt"
    )
  )

  data$species_id <- tolower(trimws(data$species_id))
  data
}

load_genome_stories <- function(path) {
  data <- read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)

  assert_columns(
    data,
    c("story_id", "title", "concept", "educational_hook", "special_highlight"),
    "genome_stories.csv"
  )

  data <- ensure_optional_columns(
    data,
    c(
      "title_pt",
      "concept_pt",
      "educational_hook_pt",
      "special_highlight_pt"
    )
  )

  data$story_id <- trimws(data$story_id)
  data
}

load_domestication_sites <- function(path) {
  data <- read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)

  assert_columns(
    data,
    c(
      "site_id",
      "species_id",
      "site_name",
      "region_label",
      "lat",
      "lng",
      "years_bp",
      "years_label",
      "wild_ancestor",
      "domestication_story",
      "artifact_note",
      "genome_fact"
    ),
    "domestication_sites.csv"
  )

  data$site_id <- trimws(data$site_id)
  data$species_id <- tolower(trimws(data$species_id))
  data$lat <- as_numeric_safe(data$lat)
  data$lng <- as_numeric_safe(data$lng)
  data$years_bp <- as_numeric_safe(data$years_bp)
  data
}

load_breed_profiles <- function(path) {
  data <- read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)

  assert_columns(
    data,
    c(
      "breed_id",
      "species_id",
      "breed_name",
      "origin_region",
      "origin_country",
      "origin_lat",
      "origin_lng",
      "primary_purpose",
      "climate_adaptability",
      "historical_usage",
      "overview",
      "genetic_fact",
      "image_file"
    ),
    "breed_profiles.csv"
  )

  data$breed_id <- trimws(data$breed_id)
  data$species_id <- tolower(trimws(data$species_id))
  data$origin_lat <- as_numeric_safe(data$origin_lat)
  data$origin_lng <- as_numeric_safe(data$origin_lng)
  data
}

load_anatomy_explorer <- function(path) {
  data <- read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)

  assert_columns(
    data,
    c(
      "system_id",
      "section_id",
      "section_name",
      "section_order",
      "ph_range",
      "microbe_focus",
      "function",
      "feed_flow",
      "teaching_note",
      "species_examples"
    ),
    "anatomy_explorer.csv"
  )

  data$system_id <- trimws(data$system_id)
  data$section_id <- trimws(data$section_id)
  data$section_order <- as_numeric_safe(data$section_order)
  data
}

load_sustainability_profiles <- function(path) {
  data <- read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)

  assert_columns(
    data,
    c(
      "species_id",
      "feed_type",
      "reference_body_mass_kg",
      "meat_output_kg",
      "milk_output_l",
      "edible_protein_kg",
      "methane_kg_per_kg_protein",
      "water_l_per_kg_protein",
      "environment_note"
    ),
    "sustainability_profiles.csv"
  )

  data$species_id <- tolower(trimws(data$species_id))
  data$feed_type <- trimws(data$feed_type)
  numeric_columns <- c(
    "reference_body_mass_kg",
    "meat_output_kg",
    "milk_output_l",
    "edible_protein_kg",
    "methane_kg_per_kg_protein",
    "water_l_per_kg_protein"
  )

  for (column_name in numeric_columns) {
    data[[column_name]] <- as_numeric_safe(data[[column_name]])
  }

  data
}
