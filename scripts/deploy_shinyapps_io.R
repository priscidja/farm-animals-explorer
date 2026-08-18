deploy_farm_animals_explorer <- function(
  app_dir = ".",
  app_name = "farm-animals-explorer",
  app_title = "Farm Animals Explorer",
  launch_browser = TRUE
) {
  if (!requireNamespace("rsconnect", quietly = TRUE)) {
    stop(
      paste(
        "The rsconnect package is not installed.",
        "Run install.packages('rsconnect') before deploying."
      ),
      call. = FALSE
    )
  }

  normalized_app_dir <- normalizePath(app_dir, winslash = "/", mustWork = TRUE)

  rsconnect::deployApp(
    appDir = normalized_app_dir,
    appName = app_name,
    appTitle = app_title,
    launch.browser = launch_browser
  )
}
