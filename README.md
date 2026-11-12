# Deriva & Difusión

Blog de estadística bayesiana, procesos estocásticos y modelamiento
neuro-inmuno-fisiológico en R. Hecho con [Quarto](https://quarto.org), solo
en inglés, base monocroma con dos acentos (ámbar = *drift*, cian =
*diffusion*), modo claro y oscuro y tipografía Latin Modern.

## Uso diario

```bash
quarto preview                    # servidor local con recarga en vivo
quarto render                     # genera el sitio en _site/

# nueva entrada
Rscript tools/nueva-entrada.R kalman-filter "The Kalman filter"
```

Requisitos: Quarto ≥ 1.7, R ≥ 4.0 y los paquetes de `DESCRIPTION`
(`knitr`, `rmarkdown`, `ggplot2`). Para que las figuras usen la misma
tipografía que el texto, instala Latin Modern en el sistema
(`sudo apt install fonts-lmodern`, o desde
<https://www.gust.org.pl/projects/e-foundry/latin-modern>); si no está, las
figuras usan la serif por defecto y todo lo demás funciona igual.

## Estructura

```
_quarto.yml              configuración del sitio (título, URL, barra, tema)
index.qmd  about.qmd     portada y «About»
posts/<slug>/index.qmd   entradas
_es-backup/              versión en español archivada (Quarto la ignora)
R/tema.R                 tema de ggplot2 y opciones de knitr compartidas
references.bib           bibliografía común a todas las entradas
assets/
  base.scss              todo el diseño (tipografía, código, tablas, portada…)
  acento.scss            colores de acento, atmósfera, estilo de revista
  journal.lua            filtro: cabecera de artículo y «Cite as»
  grano.svg              fibra del papel (modo claro)
  claro.scss oscuro.scss grises y acentos de cada modo
  sitio.html             JavaScript: progreso de lectura, portada, cursor
  indice.ejs             plantilla del índice de entradas
  fonts/                 Latin Modern en WOFF2 (GUST Font License)
tools/nueva-entrada.R    crea el esqueleto de una entrada
_freeze/                 resultados de R ya calculados (se versiona)
.github/workflows/       publicación automática en GitHub Pages
```

## Escribir una entrada

Cada entrada es una carpeta con un `index.qmd`. El preámbulo mínimo:

```yaml
---
title: "Título"
description: "Una o dos frases; aparece como resumen y en el índice."
date: 2026-11-12
categories: [bayesiana]
---
```

El primer bloque de código debe ser `source("R/tema.R")`: carga `ggplot2`,
aplica el tema y configura las figuras como SVG transparente. El código se
ejecuta desde la raíz del proyecto, así que las rutas a datos se escriben
relativas a ella (`datos/archivo.csv`).

Campos opcionales del preámbulo que usa el estilo de revista:

```yaml
keywords: [palabra clave, otra]   # se muestra tras el resumen
article-type: "Research Note"     # por defecto «Original Article»
received: 2026-10-28              # opcional; también `accepted`
```

El volumen (año − 2025, en romanos) y el número (mes) salen de `date`, así
que «Vol. I · No. 11» no requiere mantenimiento. Los pies se numeran «Fig. 1.»
y «Table I.» (configurado en `crossref` de `_quarto.yml`).

Convenciones que mantienen el diseño:

- **Figuras solo en grises.** Se dibujan en negro sobre transparente y el
  sitio las invierte en modo oscuro (con color se vería mal en uno de los
  dos). Distingue series por tipo de línea, forma o tono (`dd_tinta`). El
  color vive en la interfaz, no en las figuras.
- **Símbolos en las etiquetas con `expression()`** (`expression(tau ~ "(s)")`)
  y matemáticas en los pies de figura con `$...$`.
- **Referencias cruzadas** con las etiquetas de Quarto: `@fig-…`, `@tbl-…`,
  `@eq-…`, `@sec-…`, y teoremas con `::: {#thm-…}`, `#prp-`, `#def-`.
- **Citas** con `[@clave]`; las claves viven en `references.bib`.
- **Cifras en el texto calculadas**, no copiadas: `` `r round(x, 1)` ``.

## Por qué escala

`execute: freeze: auto` guarda en `_freeze/` el resultado de cada entrada.
Al renderizar, Quarto solo vuelve a ejecutar el R de las entradas cuya
fuente cambió; las demás se recomponen desde el resultado guardado. Con
cientos de entradas, un cambio de diseño se publica en segundos y una
entrada antigua nunca se rompe porque un paquete se actualizó. Versiona
`_freeze/` junto con el código.

El índice se pagina de doce en doce, se filtra por categoría y hay búsqueda
de texto completo y RSS, todo generado por Quarto.

## Publicar en GitHub Pages

El sitio vive en <https://driftdiffusion.com>. Cada `push` a `main` ejecuta
`.github/workflows/publish.yml`, que instala Quarto, R y las fuentes,
renderiza y publica.

Configuración única:

1. **Settings → Pages → Source: GitHub Actions.**
2. **Settings → Pages → Custom domain:** `driftdiffusion.com`, y activa
   *Enforce HTTPS* cuando el certificado esté listo.
3. En el DNS del dominio:
   - cuatro registros `A` para el apex: `185.199.108.153`,
     `185.199.109.153`, `185.199.110.153`, `185.199.111.153`;
   - (opcional) un `CNAME` de `www` a `matcasti.github.io`.

`_site/` no se versiona: lo genera Actions. `_freeze/` sí, para que una
entrada no vuelva a ejecutarse en cada publicación.

## Personalizar

- **Nombre del sitio:** `website.title` y `navbar.title` en `_quarto.yml` y
  el titular de `index.qmd`.
- **Autor:** `author` en `posts/_metadata.yml`.
- **Colores:** grises y acentos (`$accent`, `$accent2`) en `assets/claro.scss`
  y `assets/oscuro.scss`; todo el resto del color sale de esas variables.
- **Animación de la portada:** constantes `K`, `theta` y `sigma` al inicio
  del bloque 3 de `assets/sitio.html`. Respeta `prefers-reduced-motion`.
- **KaTeX:** la versión está fijada en `_quarto.yml` (`html-math-method`).
