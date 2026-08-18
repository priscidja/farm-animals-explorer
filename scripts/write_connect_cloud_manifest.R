write_connect_cloud_manifest <- function(app_dir = ".") {
  if (!requireNamespace("rsconnect", quietly = TRUE)) {
    stop(
      "The rsconnect package is required. Run install.packages('rsconnect') first.",
      call. = FALSE
    )
  }

  normalized_app_dir <- normalizePath(app_dir, winslash = "/", mustWork = TRUE)
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(normalized_app_dir)

  app_files <- c(
    "app.R",
    "R/data_access.R",
    "scripts/Interactive_charts_for_App.R",
    "scripts/Quiz.R",
    "data/species_profiles.csv",
    "data/genome_summary.csv",
    "data/science_use.csv",
    "data/genome_stories.csv",
    "data/domestication_sites.csv",
    "data/breed_profiles.csv",
    "data/anatomy_explorer.csv",
    "data/sustainability_profiles.csv",
    list.files("figs", recursive = TRUE, full.names = TRUE, all.files = FALSE, no.. = TRUE),
    list.files("www", recursive = TRUE, full.names = TRUE, all.files = FALSE, no.. = TRUE)
  )

  app_files <- unique(app_files[file.exists(app_files)])

  rsconnect::writeManifest(
    appDir = normalized_app_dir,
    appFiles = app_files
  )

  manifest_path <- file.path(normalized_app_dir, "manifest.json")
  if (file.exists(manifest_path) && requireNamespace("jsonlite", quietly = TRUE)) {
    manifest <- jsonlite::fromJSON(manifest_path, simplifyVector = FALSE)
    if (!is.null(manifest$platform) && utils::compareVersion(manifest$platform, "4.6.0") > 0) {
      manifest$platform <- "4.6.0"
      writeLines(
        jsonlite::toJSON(manifest, auto_unbox = TRUE, pretty = TRUE, null = "null"),
        manifest_path
      )
    }
  }

  invisible(app_files)
}
