# ---------------------------------------------------------------------------
# Deriva & Difusión — tema gráfico común a todas las entradas
#
# Uso, en el primer bloque de cada entrada:
#   source("R/tema.R")
#
# Los gráficos se dibujan en negro sobre fondo transparente y en SVG.
# El sitio los invierte por CSS en modo oscuro, así que una sola figura
# sirve para ambos modos. Por eso: nada de color, solo grises, tipos de
# línea y grosor.
# ---------------------------------------------------------------------------

library(ggplot2)

# Latin Modern si está instalada en el sistema (apt install fonts-lmodern,
# o descargar de https://www.gust.org.pl/projects/e-foundry/latin-modern);
# si no, la serif por defecto.
dd_fuentes <- tryCatch(
  system2("fc-list", ":family", stdout = TRUE, stderr = FALSE),
  error = function(e) character(), warning = function(w) character()
)
dd_hay_fuente <- function(fam) any(grepl(fam, dd_fuentes, fixed = TRUE))

dd_familia <- if (dd_hay_fuente("Latin Modern Roman")) "Latin Modern Roman" else "serif"

# Argumentos del dispositivo SVG: fondo transparente y, si existe, Latin
# Modern Math para los símbolos de las etiquetas escritas con expression().
dd_dev_args <- list(bg = "transparent")
if (dd_hay_fuente("Latin Modern Math") && getRversion() >= "4.0.0") {
  dd_dev_args$symbolfamily <- grDevices::cairoSymbolFont("Latin Modern Math",
                                                         usePUA = FALSE)
}

# Escala de tinta: del negro al gris claro
dd_tinta <- c("black", "grey35", "grey55", "grey72")

theme_dd <- function(base_size = 12.5, base_family = dd_familia) {
  theme_minimal(base_size = base_size, base_family = base_family) %+replace%
    theme(
      plot.background   = element_rect(fill = "transparent", colour = NA),
      panel.background  = element_rect(fill = "transparent", colour = NA),
      legend.background = element_rect(fill = "transparent", colour = NA),
      legend.key        = element_rect(fill = "transparent", colour = NA),
      panel.grid.major  = element_line(colour = "grey90", linewidth = 0.3),
      panel.grid.minor  = element_blank(),
      axis.line         = element_line(colour = "black", linewidth = 0.35),
      axis.ticks        = element_line(colour = "black", linewidth = 0.35),
      axis.ticks.length = unit(3, "pt"),
      axis.text         = element_text(colour = "black", size = rel(0.88)),
      axis.title        = element_text(colour = "black", size = rel(0.96)),
      axis.title.x      = element_text(margin = margin(t = 7)),
      axis.title.y      = element_text(margin = margin(r = 7), angle = 90),
      strip.text        = element_text(colour = "black", size = rel(0.96),
                                       hjust = 0, margin = margin(b = 5)),
      legend.position   = "top",
      legend.justification = "left",
      legend.title      = element_blank(),
      legend.text       = element_text(size = rel(0.92)),
      legend.key.width  = unit(26, "pt"),
      legend.margin     = margin(0, 0, 0, 0),
      legend.box.margin = margin(0, 0, -4, 0),
      plot.title        = element_text(face = "bold", hjust = 0, size = rel(1.05),
                                       margin = margin(b = 6)),
      plot.margin       = margin(6, 10, 4, 4)
    )
}

theme_set(theme_dd())
update_geom_defaults("line", list(linewidth = 0.55, colour = "black"))
update_geom_defaults("point", list(size = 1.4, colour = "black"))

if (requireNamespace("knitr", quietly = TRUE)) {
  knitr::opts_chunk$set(
    dev = "svg",
    dev.args = dd_dev_args,
    fig.width = 7,
    fig.height = 4.1,
    fig.align = "center",
    out.width = "100%",
    comment = "#>"
  )
}

# Tabla de resumen posterior: media, desviación e intervalo de credibilidad
resumen_posterior <- function(x, prob = 0.95) {
  a <- (1 - prob) / 2
  c(media = mean(x), de = sd(x),
    inf = unname(quantile(x, a)), sup = unname(quantile(x, 1 - a)))
}
