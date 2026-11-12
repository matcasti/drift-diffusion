#!/usr/bin/env Rscript
# Crea el esqueleto de una entrada nueva.
#
#   Rscript tools/nueva-entrada.R kalman-filter "The Kalman filter"
#
# El primer argumento es el slug (minúsculas y guiones); queda como URL:
# posts/<slug>/.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Uso: Rscript tools/nueva-entrada.R <slug> \"Title\"", call. = FALSE)
}
slug <- args[1]
if (!grepl("^[a-z0-9]+(-[a-z0-9]+)*$", slug)) {
  stop("El slug solo admite minúsculas, números y guiones.", call. = FALSE)
}

dir <- file.path("posts", slug)
if (dir.exists(dir)) stop("Ya existe: ", dir, call. = FALSE)
dir.create(dir, recursive = TRUE)

writeLines(c(
  "---",
  sprintf("title: \"%s\"", args[2]),
  "description: \"One- or two-sentence abstract.\"",
  sprintf("date: %s", Sys.Date()),
  "categories: [bayesian]",
  "draft: true",
  "---",
  "",
  "```{r}",
  "#| label: setup",
  "#| include: false",
  "source(\"R/tema.R\")",
  "```",
  "",
  "## Introduction {#sec-intro}",
  "",
  "Text. See @eq-example and @fig-example.",
  "",
  "$$",
  "\\mathrm{d}X_t = \\theta\\,(\\mu - X_t)\\,\\mathrm{d}t + \\sigma\\,\\mathrm{d}W_t",
  "$$ {#eq-example}",
  "",
  "```{r}",
  "#| label: fig-example",
  "#| fig-cap: \"...\"",
  "set.seed(1)",
  "d <- data.frame(t = 1:200, x = cumsum(rnorm(200)))",
  "ggplot(d, aes(t, x)) + geom_line()",
  ""
), file.path(dir, "index.qmd"), useBytes = TRUE)

message("Creado ", file.path(dir, "index.qmd"))
message("Quita `draft: true` cuando la entrada esté lista para publicarse.")
