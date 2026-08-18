normalise_names <- function(x) {
  cleaned <- tolower(gsub("[^A-Za-z0-9]+", "_", x))
  cleaned <- gsub("^_+|_+$", "", cleaned)
  gsub("_+", "_", cleaned)
}

`%||%` <- function(left, right) {
  if (is.null(left) || length(left) == 0) {
    return(right)
  }

  if (length(left) == 1 && is.na(left)) {
    return(right)
  }

  left
}

pick_column <- function(names_vector, patterns, required = TRUE) {
  for (pattern in patterns) {
    hits <- grep(pattern, names_vector, value = TRUE)

    if (length(hits) > 0) {
      return(hits[[1]])
    }
  }

  if (required) {
    stop(
      sprintf(
        "Could not find a column matching any of: %s",
        paste(patterns, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  NULL
}

safe_numeric <- function(x) {
  suppressWarnings(as.numeric(gsub(",", "", x)))
}

replace_if_present <- function(primary, fallback) {
  replacement <- !is.na(primary) & primary != ""
  fallback[replacement] <- primary[replacement]
  fallback
}

extract_qualifier_value <- function(text, key) {
  if (length(text) == 0 || is.na(text) || !nzchar(text)) {
    return(NA_character_)
  }

  pattern <- sprintf("%s:\\s*([^,]+)", key)
  match <- regexec(pattern, text, ignore.case = TRUE)
  pieces <- regmatches(text, match)[[1]]

  if (length(pieces) < 2) {
    return(NA_character_)
  }

  trimws(pieces[[2]])
}

read_ncbi_table <- function(path) {
  if (!file.exists(path)) {
    stop(sprintf("File not found: %s", path), call. = FALSE)
  }

  if (grepl("\\.csv$", path, ignore.case = TRUE)) {
    read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
  } else {
    read.delim(path, stringsAsFactors = FALSE, check.names = FALSE)
  }
}

guess_report_path <- function(input_path) {
  local_candidate <- file.path(dirname(input_path), "assembly_data_report.jsonl")

  if (file.exists(local_candidate)) {
    return(local_candidate)
  }

  search_roots <- c("data-raw", "data")
  candidates <- character()

  for (root in search_roots) {
    if (!dir.exists(root)) {
      next
    }

    matches <- list.files(
      root,
      pattern = "^assembly_data_report\\.jsonl$",
      recursive = TRUE,
      full.names = TRUE
    )

    if (length(matches) > 0) {
      candidates <- c(candidates, matches)
    }
  }

  candidates <- unique(normalizePath(candidates, winslash = "/", mustWork = FALSE))

  if (length(candidates) == 1) {
    return(candidates[[1]])
  }

  NULL
}

read_jsonl_lines <- function(path) {
  raw_lines <- readLines(path, warn = FALSE)
  raw_lines[nzchar(trimws(raw_lines))]
}

parse_report_record <- function(line) {
  record <- jsonlite::fromJSON(line, simplifyVector = TRUE)

  data.frame(
    accession = record$currentAccession %||% record$accession %||% NA_character_,
    scientific_name = record$organism$organismName %||% NA_character_,
    breed = record$organism$infraspecificNames$breed %||%
      record$biosample$breed %||%
      NA_character_,
    source_db = record$sourceDatabase %||% NA_character_,
    assembly_level = record$assemblyInfo$assemblyLevel %||% NA_character_,
    genome_mb = safe_numeric(record$assemblyStats$totalSequenceLength) / 1000000,
    gc_percent = safe_numeric(record$assemblyStats$gcPercent),
    scaffold_n50_mb = safe_numeric(record$assemblyStats$scaffoldN50) / 1000000,
    stringsAsFactors = FALSE
  )
}

read_assembly_report <- function(path) {
  if (is.null(path) || !file.exists(path)) {
    return(NULL)
  }

  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop(
      paste(
        "The jsonlite package is required to read assembly_data_report.jsonl.",
        "Install it with install.packages('jsonlite')."
      ),
      call. = FALSE
    )
  }

  lines <- read_jsonl_lines(path)

  if (length(lines) == 0) {
    return(NULL)
  }

  report_rows <- lapply(lines, parse_report_record)
  report <- do.call(rbind, report_rows)

  report$source_db <- sub("^SOURCE_DATABASE_", "", report$source_db)
  report$source_db <- gsub("_", " ", report$source_db)
  report$source_db <- tools::toTitleCase(tolower(report$source_db))
  report$source_db[report$source_db == "Genbank"] <- "GenBank"
  report$source_db[report$source_db == "Refseq"] <- "RefSeq"

  report
}

classify_species <- function(organism_name) {
  label <- tolower(if (is.na(organism_name)) "" else organism_name)

  if (grepl("bos taurus|cattle|cow", label)) {
    return("cattle")
  }

  if (grepl("ovis aries|sheep|ram|ewe|lamb", label)) {
    return("sheep")
  }

  if (grepl("sus scrofa|pig|swine|boar", label)) {
    return("pig")
  }

  if (grepl("capra hircus|goat", label)) {
    return("goat")
  }

  NA_character_
}

pull_column <- function(data, column_name, default = NA_character_) {
  if (is.null(column_name)) {
    return(rep(default, nrow(data)))
  }

  data[[column_name]]
}

build_genome_summary <- function(
    input_path,
    output_path = file.path("data", "genome_summary.csv"),
    report_path = NULL) {
  raw_data <- read_ncbi_table(input_path)
  names(raw_data) <- normalise_names(names(raw_data))

  report_path <- report_path %||% guess_report_path(input_path)
  report_data <- read_assembly_report(report_path)

  accession_col <- pick_column(
    names(raw_data),
    c("^assembly_accession$", "^accession$", "assembly.*accession")
  )
  organism_col <- pick_column(
    names(raw_data),
    c(
      "^organism_scientific_name$",
      "^organism_name$",
      "^scientific_name$",
      "^organism$"
    )
  )
  assembly_name_col <- pick_column(
    names(raw_data),
    c("^assembly_name$", "^asm_name$", "assembly_name")
  )
  qualifier_col <- pick_column(
    names(raw_data),
    c("^organism_qualifier$", "^qualifier$", "organism_qualifier"),
    required = FALSE
  )
  breed_col <- pick_column(
    names(raw_data),
    c(
      "^organism_infraspecific_names_breed$",
      "^breed$",
      "infraspecific.*breed"
    ),
    required = FALSE
  )
  assembly_level_col <- pick_column(
    names(raw_data),
    c("^assembly_level$", "^level$", "assembly_level"),
    required = FALSE
  )
  source_db_col <- pick_column(
    names(raw_data),
    c("^source_database$", "^source_db$", "^source$", "source_database"),
    required = FALSE
  )
  genome_size_col <- pick_column(
    names(raw_data),
    c(
      "^assembly_stats_total_sequence_length$",
      "^total_sequence_length$",
      "^genome_size$",
      "^size$"
    ),
    required = is.null(report_data)
  )
  gc_col <- pick_column(
    names(raw_data),
    c("^assembly_stats_gc_percent$", "^gc_percent$", "^gc$"),
    required = FALSE
  )
  scaffold_n50_col <- pick_column(
    names(raw_data),
    c("^assembly_stats_scaffold_n50$", "^scaffold_n50$", "scaffold_n50"),
    required = FALSE
  )
  contig_n50_col <- pick_column(
    names(raw_data),
    c("^assembly_stats_contig_n50$", "^contig_n50$", "contig_n50"),
    required = FALSE
  )

  use_contig_fallback <- FALSE

  if (is.null(scaffold_n50_col) && is.null(report_data) && !is.null(contig_n50_col)) {
    scaffold_n50_col <- contig_n50_col
    use_contig_fallback <- TRUE
  }

  data_note <- "Generated from an NCBI table export."

  if (!is.null(report_data)) {
    data_note <- paste(
      data_note,
      sprintf("Enriched with assembly metrics from %s.", basename(report_path))
    )
  }

  if (use_contig_fallback) {
    data_note <- paste(
      data_note,
      "The source table did not include scaffold N50, so the plot column uses contig N50 instead."
    )
  }

  output <- data.frame(
    species_id = vapply(raw_data[[organism_col]], classify_species, character(1)),
    display_name = NA_character_,
    scientific_name = pull_column(raw_data, organism_col),
    breed = replace_if_present(
      pull_column(raw_data, breed_col),
      vapply(
        pull_column(raw_data, qualifier_col),
        extract_qualifier_value,
        character(1),
        key = "breed"
      )
    ),
    accession = pull_column(raw_data, accession_col),
    assembly_name = pull_column(raw_data, assembly_name_col),
    assembly_level = pull_column(raw_data, assembly_level_col, "unknown"),
    source_db = pull_column(raw_data, source_db_col, "NCBI"),
    genome_mb = round(safe_numeric(pull_column(raw_data, genome_size_col, NA_character_)) / 1000000, 2),
    gc_percent = safe_numeric(pull_column(raw_data, gc_col)),
    scaffold_n50_mb = round(safe_numeric(pull_column(raw_data, scaffold_n50_col, NA_character_)) / 1000000, 2),
    data_status = "project",
    data_note = data_note,
    stringsAsFactors = FALSE
  )

  if (!is.null(report_data)) {
    match_index <- match(output$accession, report_data$accession)
    matched_report <- report_data[match_index, , drop = FALSE]

    output$scientific_name <- replace_if_present(
      matched_report$scientific_name,
      output$scientific_name
    )
    output$breed <- replace_if_present(
      matched_report$breed,
      output$breed
    )
    output$assembly_level <- replace_if_present(
      matched_report$assembly_level,
      output$assembly_level
    )
    output$source_db <- replace_if_present(
      matched_report$source_db,
      output$source_db
    )
    output$genome_mb <- replace_if_present(
      matched_report$genome_mb,
      output$genome_mb
    )
    output$gc_percent <- replace_if_present(
      matched_report$gc_percent,
      output$gc_percent
    )
    output$scaffold_n50_mb <- replace_if_present(
      matched_report$scaffold_n50_mb,
      output$scaffold_n50_mb
    )
  }

  output <- output[!is.na(output$species_id), , drop = FALSE]

  if (nrow(output) == 0) {
    stop(
      "No cattle, sheep, pig, or goat rows were detected. Check the organism names in your NCBI export.",
      call. = FALSE
    )
  }

  output$display_name[output$species_id == "cattle"] <- "Cattle"
  output$display_name[output$species_id == "sheep"] <- "Sheep"
  output$display_name[output$species_id == "pig"] <- "Pig"
  output$display_name[output$species_id == "goat"] <- "Goat"

  output$genome_mb <- round(output$genome_mb, 2)
  output$gc_percent <- round(output$gc_percent, 2)
  output$scaffold_n50_mb <- round(output$scaffold_n50_mb, 2)

  dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)
  write.csv(output, output_path, row.names = FALSE)

  output
}

if (!interactive() && sys.nframe() == 0) {
  args <- commandArgs(trailingOnly = TRUE)

  if (length(args) == 0) {
    stop(
      paste(
        "Usage: Rscript scripts/build_genome_summary_from_ncbi_table.R",
        "data-raw/assembly_table.csv [data/genome_summary.csv] [assembly_data_report.jsonl]"
      ),
      call. = FALSE
    )
  }

  destination <- if (length(args) >= 2) args[[2]] else file.path("data", "genome_summary.csv")
  report <- if (length(args) >= 3) args[[3]] else NULL
  result <- build_genome_summary(args[[1]], destination, report)

  cat(
    sprintf("Wrote %s rows to %s\n", nrow(result), destination)
  )
}
