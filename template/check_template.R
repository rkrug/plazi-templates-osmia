# Check a Plazi/GoldenGATE document style against a PDF and draw its areas onto a copy.
# usage: LANG=en_US.UTF-8 Rscript check_template.R <template> <in.pdf> <out.pdf>
# Areas are read as [left, right, top, bottom] in PDF points, origin top-left (pdftools' system).
# ponytail: text in an area = words whose centre lies inside it; GoldenGATE's own OCR/word model may differ.

a <- commandArgs(TRUE)
kv <- read.delim(a[1], header = FALSE, quote = "", col.names = c("k", "v"), colClasses = "character")
tp <- setNames(kv$v, kv$k)
dd <- pdftools::pdf_data(a[2], font_info = TRUE)
num <- function(x) if (is.na(x)) NA else as.numeric(x)
boxes <- function(v) lapply(regmatches(v, gregexpr("\\[[^]]+\\]", v))[[1]], function(b) as.numeric(strsplit(gsub("[][]", "", b), ",")[[1]]))

# text inside an area on pages 0..maxp, optionally font-filtered
area_text <- function(b, maxp, fs = NA, fmin = NA, fmax = NA, bold = NA) {
  out <- character()
  for (p in seq_len(min(maxp + 1, length(dd)))) {
    d <- dd[[p]]; cx <- d$x + d$width / 2; cy <- d$y + d$height / 2
    s <- cx >= b[1] & cx <= b[2] & cy >= b[3] & cy <= b[4]
    if (!is.na(fs)) s <- s & abs(d$font_size - fs) < 0.6
    if (!is.na(fmin)) s <- s & d$font_size >= fmin - 0.6
    if (!is.na(fmax)) s <- s & d$font_size <= fmax + 0.6
    if (isTRUE(bold == "true")) s <- s & grepl("Bold|Semibold|SemiBold|Black|Heavy", d$font_name)
    d <- d[s, ]; if (!nrow(d)) next; d <- d[order(d$y + d$height), ]
    ln <- cumsum(c(1, diff(d$y + d$height) > 4)); d <- d[order(ln, d$x), ]; ln <- sort(ln)
    d$space <- d$space | c(diff(ln) != 0, TRUE)
    # glue words that pdftools reports as not followed by a space (small-caps pieces such as "M" + "AHÉ")
    out <- c(out, paste0(d$text, ifelse(d$space, " ", ""), collapse = ""))
  }
  # whitespace as a tokenizer sees it: tabs, CRs and no-break spaces inside PDF "words" become one space
  gsub("[\\s\u00a0]+", " ", paste(out, collapse = " "), perl = TRUE)
}
first <- function(pat, x) { m <- regmatches(x, regexpr(pat, x, perl = TRUE)); if (length(m)) m else NA }
every <- function(pat, x) { m <- regmatches(x, gregexpr(pat, x, perl = TRUE))[[1]]; if (length(m)) paste(m, collapse = " | ") else NA }

cat("##", basename(a[1]), "vs", basename(a[2]), "\n")
ok <- TRUE
amax <- max(0, num(tp["anchor.maxPageId"]), na.rm = TRUE)
for (an in unique(sub("^anchor\\.([^.]+)\\..*", "\\1", grep("^anchor\\.[^.]+\\.pattern$", names(tp), value = TRUE)))) {
  g <- function(x) tp[paste0("anchor.", an, ".", x)]
  t <- area_text(boxes(g("area"))[[1]], amax, num(g("fontSize")), num(g("minFontSize")), num(g("maxFontSize")), g("isBold"))
  hit <- grepl(g("pattern"), t, perl = TRUE)
  ok <- ok && (hit || g("isRequired") != "true")
  cat(sprintf("  anchor %-14s %s  [%s]\n", an, if (hit) "MATCH" else "no match", substr(t, 1, 70)))
}
fields <- unique(sub("^docMeta\\.(.+)\\.(area|valuePattern|fixedValue)$", "\\1", grep("^docMeta\\..+\\.(area|valuePattern|fixedValue)$", names(tp), value = TRUE)))
for (f in fields) {
  g <- function(x) tp[paste0("docMeta.", f, ".", x)]
  if (!is.na(g("fixedValue"))) { cat(sprintf("  %-28s = %s (fixed)\n", f, g("fixedValue"))); next }
  if (is.na(g("area"))) next
  maxp <- num(g("maxPageId")); if (is.na(maxp)) maxp <- max(0, num(tp["docMeta.maxPageId"]), na.rm = TRUE)
  t <- area_text(boxes(g("area"))[[1]], maxp, num(g("fontSize")), num(g("minFontSize")), num(g("maxFontSize")), g("isBold"))
  if (f == "author" && !is.na(g("contextPattern"))) { # as GoldenGATE: one value per context match
    cm <- regmatches(t, gregexpr(g("contextPattern"), t, perl = TRUE))[[1]]
    if (!is.na(g("valuePattern"))) cm <- na.omit(vapply(cm, function(x) as.character(first(g("valuePattern"), x)), ""))
    v <- if (length(cm)) paste(cm, collapse = " | ") else NA
  } else {
    v <- if (!is.na(g("contextPattern"))) first(g("contextPattern"), t) else t
    if (!is.na(g("valuePattern"))) v <- (if (f == "author") every else first)(g("valuePattern"), v)
  }
  cat(sprintf("  %-28s = %s\n", f, if (is.na(v)) "<none>" else if (f == "author") v else substr(v, 1, 90)))
}

# overlay: one transparent page per PDF page, then qpdf --overlay
col <- c(anchor = "#d62728", docMeta = "#1f77b4", header = "#7f7f7f", column = "#2ca02c", number = "#ff7f0e", content = "#9467bd")
ov <- tempfile(fileext = ".pdf"); sz <- pdftools::pdf_pagesize(a[2])
pdf(ov, width = sz$width[1] / 72, height = sz$height[1] / 72, bg = "transparent")
draw <- function(v, kind, label) for (b in boxes(v)) {
  rect(b[1], b[4], b[2], b[3], border = col[kind], col = adjustcolor(col[kind], 0.12), lwd = 1.2, lty = if (kind == "content") 2 else 1)
  text(b[1] + 1, b[3] + 1, label, adj = c(0, 1), cex = 0.42, col = col[kind], font = 2)
}
for (p in seq_along(dd)) {
  par(mar = c(0, 0, 0, 0)); plot.new(); plot.window(c(0, sz$width[p]), c(sz$height[p], 0), xaxs = "i", yaxs = "i")
  if (p > max(0, num(tp["layout.coverPageCount"]), na.rm = TRUE)) draw(tp["layout.contentArea"], "content", "layout.contentArea")
  cover <- max(0, num(tp["layout.coverPageCount"]), na.rm = TRUE)
  side <- if (p <= cover) "cover" else if (p == cover + 1) "first" else if ((p - cover) %% 2) "odd" else "even"
  for (k in c("headerAreas", "columnAreas", "number.area")) {
    v <- tp[paste0("layout.page.", side, ".", k)]
    if (!is.na(v)) draw(v, c(headerAreas = "header", columnAreas = "column", number.area = "number")[k], paste0(side, ".", k))
  }
  if (p - 1 <= amax)
    for (k in grep("^anchor\\..+\\.area$", names(tp), value = TRUE)) draw(tp[k], "anchor", sub("\\.area$", "", k))
  for (k in grep("^docMeta\\..+\\.area$", names(tp), value = TRUE)) {
    maxp <- num(tp[sub("area$", "maxPageId", k)]); if (is.na(maxp)) maxp <- max(0, num(tp["docMeta.maxPageId"]), na.rm = TRUE)
    if (p - 1 <= maxp) draw(tp[k], "docMeta", sub("^docMeta\\.(.+)\\.area$", "\\1", k))
  }
  legend("bottomleft", names(col), fill = adjustcolor(col, 0.3), border = col, cex = 0.4, bty = "n", horiz = TRUE, inset = c(0.01, 0.002))
}
invisible(dev.off())
system2("qpdf", c(shQuote(a[2]), "--overlay", shQuote(ov), "--", shQuote(a[3])))
cat("  ->", a[3], if (ok) "" else "(a required anchor did NOT match)", "\n")
