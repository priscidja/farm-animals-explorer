configure_shinyapps_account <- function(
  account_name = Sys.getenv("SHINYAPPS_NAME", ""),
  account_token = Sys.getenv("SHINYAPPS_TOKEN", ""),
  account_secret = Sys.getenv("SHINYAPPS_SECRET", "")
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

  if (!all(nzchar(c(account_name, account_token, account_secret)))) {
    return(FALSE)
  }

  rsconnect::setAccountInfo(
    name = account_name,
    token = account_token,
    secret = account_secret
  )

  TRUE
}

deploy_farm_animals_explorer <- function(
  app_dir = ".",
  app_name = "farm-animals-explorer",
  app_title = "Farm Animals Explorer",
  launch_browser = TRUE,
  account_name = Sys.getenv("SHINYAPPS_NAME", ""),
  account_token = Sys.getenv("SHINYAPPS_TOKEN", ""),
  account_secret = Sys.getenv("SHINYAPPS_SECRET", "")
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

  configure_shinyapps_account(
    account_name = account_name,
    account_token = account_token,
    account_secret = account_secret
  )

  configured_accounts <- tryCatch(
    rsconnect::accounts(),
    error = function(e) data.frame()
  )

  if (NROW(configured_accounts) == 0) {
    stop(
      paste(
        "No shinyapps.io account is configured.",
        "Set SHINYAPPS_NAME, SHINYAPPS_TOKEN, and SHINYAPPS_SECRET",
        "in your environment, or call rsconnect::setAccountInfo(...) first."
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
