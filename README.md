# Farm Animals Explorer

`Farm Animals Explorer` is a Shiny teaching app for comparing cattle, sheep, goats, and pigs across biology, taxonomy, genomics, religion, domestication, breeds, anatomy, sustainability, and quiz-based learning.

The app is designed so that most teaching content lives in small CSV files. That makes it easy to update the classroom material without rewriting the Shiny interface.

## Main features

- Species cards with common names, taxonomy, bilingual terminology, and teaching prompts
- Genome explorer with assembly summaries, comparison plots, and downloadable filtered tables
- Science, religion, breed, domestication, anatomy, and sustainability teaching sections
- English, Spanish, and Portuguese interface support
- Quiz tab for classroom review

## Project structure

- `app.R`: main Shiny app
- `R/data_access.R`: data loading and validation helpers
- `data/`: tracked app data used at runtime
- `data-raw/`: local raw inputs that stay out of Git
- `figs/`: app figures and species illustrations
- `scripts/`: helper scripts for genome summaries, plots, quiz content, and deployment
- `www/styles.css`: custom app styling

## Run locally

Open `farm-animals-explorer.Rproj` in Positron or RStudio, then run:

```r
shiny::runApp()
```

If needed, install the core runtime packages first:

```r
install.packages(c("shiny", "plotly"))
```

## Data workflow

The repository tracks only lightweight teaching assets and summary tables.

Tracked in Git:

- `data/species_profiles.csv`
- `data/genome_summary.csv`
- `data/science_use.csv`
- `data/breed_profiles.csv`
- `data/domestication_sites.csv`
- `data/anatomy_explorer.csv`
- `data/sustainability_profiles.csv`
- `data/genome_stories.csv`
- figures in `figs/`

Ignored from Git:

- `data/genome data/` raw NCBI downloads
- `data-raw/` temporary raw exports except its README
- local error screenshots
- R session files and macOS metadata

## Rebuild the genome summary

When you download a fresh NCBI assembly table, place it in `data-raw/` and run:

```r
source("scripts/build_genome_summary_from_ncbi_table.R")
build_genome_summary("data-raw/assembly_table.tsv")
```

That rebuilds `data/genome_summary.csv`, which is the file used by the app.

## GitHub-ready workflow

From the project directory:

```bash
git status
git add .
git commit -m "Prepare Farm Animals Explorer for GitHub and deployment"
```

Because the raw genome folder is ignored, the commit should stay lightweight and safe for GitHub.

## Deployment

This app is best deployed to a Shiny host such as:

- `shinyapps.io`
- Posit Connect

A helper script is included for `shinyapps.io` deployment:

```r
source("scripts/deploy_shinyapps_io.R")
deploy_farm_animals_explorer()
```

Before deploying, make sure `rsconnect` is installed:

```r
install.packages("rsconnect")
```

Then set your account credentials as environment variables in the terminal before starting R:

```bash
export SHINYAPPS_NAME="YOUR_ACCOUNT_NAME"
export SHINYAPPS_TOKEN="YOUR_TOKEN"
export SHINYAPPS_SECRET="YOUR_SECRET"
```

Then run:

```r
source("scripts/deploy_shinyapps_io.R")
deploy_farm_animals_explorer()
```

## Notes

- The phylogeny section now uses the uploaded figure asset directly from `figs/phylogeny-tree.png`.
- Large FASTA, GBFF, and downloaded NCBI folders should stay outside GitHub even if you use them locally for analysis.
