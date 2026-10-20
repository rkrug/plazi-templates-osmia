# Compare the values each recognised style extracted (verification_all_pdfs.log) with OpenAlex metadata
# usage: Rscript compare_openalex.R <download folder with works/parquet>  (run after run_all.sh)
#        Rscript compare_openalex.R <download folder> gg_values.tsv  (GoldenGATE's values, from gg_extract.R)
D <- commandArgs(TRUE)[1]; G <- commandArgs(TRUE)[2]; T <- "."
con <- DBI::dbConnect(duckdb::duckdb())
w <- DBI::dbGetQuery(con, sprintf("SELECT replace(id,'https://openalex.org/','') id, lower(replace(doi,'https://doi.org/','')) doi, biblio.volume vol, biblio.first_page fp, biblio.last_page lp, publication_year yr, title, len(authorships) na FROM read_parquet('%s/works/parquet/**/*.parquet')", path.expand(D)))
if (is.na(G)) {
v <- read.delim(file.path(T, "verification_all_pdfs.tsv"), colClasses = "character"); v <- v[v$recognised_by != "none", ]
log <- readLines(file.path(T, "verification_all_pdfs.log"))
starts <- grep("^## ", log)
get <- function(pdf, tmpl) { i <- starts[grepl(paste0("## ", tmpl, " vs ", pdf, ".pdf"), log[starts], fixed = TRUE)]; j <- starts[starts > i][1]; if (is.na(j)) j <- length(log) + 1
  b <- log[(i + 1):(j - 1)]; b <- b[grepl("^  [A-z.-]+ +=", b)]; setNames(trimws(sub("^[^=]+= ", "", b)), trimws(sub("=.*", "", b))) }
} else { g <- read.delim(G, colClasses = "character", check.names = FALSE, quote = "")
  v <- data.frame(pdf = g$pdf, recognised_by = g$style)[g$style != "none", ]
  get <- function(pdf, tmpl) unlist(g[g$pdf == pdf, c("ID-DOI", "volume", "pagination", "title", "author")]) }
norm <- function(x) tolower(gsub("[^[:alnum:]]", "", iconv(x, to = "ASCII//TRANSLIT")))
bad <- list()
for (k in seq_len(nrow(v))) {
  x <- get(v$pdf[k], v$recognised_by[k]); r <- w[w$id == sub(".*_", "", v$pdf[k]), ]
  chk <- function(field, ok, got, want) if (!ok) bad[[length(bad) + 1]] <<- data.frame(pdf = v$pdf[k], field, got = substr(got, 1, 45), openalex = substr(as.character(want), 1, 45))
  if (!is.na(x["ID-DOI"]) && x["ID-DOI"] != "<none>") chk("DOI", tolower(gsub("\\s", "", x["ID-DOI"])) == r$doi, x["ID-DOI"], r$doi)
  if (!is.na(r$vol) && x["volume"] != "<none>") chk("volume", x["volume"] == r$vol, x["volume"], r$vol)
  if (!is.na(x["pagination"]) && x["pagination"] != "<none>") { p <- strsplit(gsub("\\s", "", x["pagination"]), "[-–]")[[1]]
    chk("pagination", p[1] == r$fp && (length(p) == 1 || p[2] == r$lp), x["pagination"], paste(r$fp, r$lp, sep = "-")) }
  chk("title", startsWith(norm(r$title), substr(norm(sub("\\s*$", "", x["title"])), 1, 40)) || startsWith(norm(x["title"]), substr(norm(r$title), 1, 40)), x["title"], r$title)
  na <- if (x["author"] == "<none>") 0 else length(strsplit(x["author"], " \\| ")[[1]])
  chk("authors(n)", na == r$na, paste(na, ":", x["author"]), r$na)
}
b <- do.call(rbind, bad); cat("checked", nrow(v), "PDFs;", if (is.null(b)) 0 else nrow(b), "differences\n"); if (!is.null(b)) print(b, row.names = FALSE, right = FALSE)
