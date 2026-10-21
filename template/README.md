# Osmia document styles — version 4

Plazi/GoldenGATE document styles for **Osmia — Revue d'Hyménoptérologie /
Journal of Hymenopterology** (Observatoire des Abeilles, ISSN 2727-3806, DOI
prefix `10.47446/OSMIA`). Format and key meanings: see
`../../PLAZI_templates/README.md`; all styles start from
`_baseTemplate.0000.journal_article`. Version 1 (built from 5 PDFs) is kept in
`v1/`, versions 2 and 3 with their results in `v2/` and `v3/`.

## Styles

| Style | Version | Volumes | Recognised by (anchors) |
|---|---|---|---|
| `Osmia.2007-2012.journal_article` | 4 | 1–5 | running head `OSMIA n°5 - 2012` / `OSMIA n°1 - Janvier 2007` (required); DOI line at the top (optional) |
| `Osmia.2016-2020.journal_article` | 4 | 6–8 | `ARTICLE` or `BRÈVE` tab top-left, 13 pt bold (required); DOI line top-right (optional) |
| `Osmia.2021-.journal_article.0cover` | 4 | 9–14 | "Revue d'Hyménoptérologie" masthead + `ISSN 2727-3806` |
| `Osmia.2021-.journal_article.1cover` | 4 | 9–14, HAL copies | as `.0cover`, one page later, plus the HAL cover page ("To cite this version" / "HAL Id") in front |

Extracted: title, authors, affiliations, e-mails, volume, year, pagination,
DOI; for 2021- also ORCID, author ZooBank LSIDs, article ZooBank ID and
publication date. Journal, publisher, ISSN are fixed values.

## Test results (96 PDFs from `source-is-Osmia-S4210192884`)

Run `sh run_all.sh <pdf folder>` then `Rscript compare_openalex.R <download folder>`.

- **Recognition** (`verification_all_pdfs.tsv`): 76 PDFs recognised — 30 /
  14 / 29 / 3 by the four styles — no PDF by more than one style. The 20 not
  recognised are exactly the non-articles: 9 full-issue PDFs, 8 editorials /
  "Lettre éditoriale", and 3 files that are not Osmia articles (a 1985 Linzer
  biol. Beitr. paper, a PDF starting mid-text, a supplementary file). One
  editorial is recognised as an article: vol. 1's (`1_W3086338040`), which is
  laid out like an article.
- **Values vs OpenAlex** (`compare_openalex.txt`, OpenAlex metadata from
  `works/parquet`): DOI, volume, pagination, title and number of authors agree
  for all 76 except 13 differences, all on the OpenAlex side — 5 where
  OpenAlex has only the first page (`49-49` vs `49–60` in the PDF), 5 titles
  that OpenAlex words or capitalises differently, and `NA_W7166478142`, whose
  PDF is a different article (DOI …14.2, OpenAlex work …14.3).
- **Still empty** (4 PDFs) — the value is not in the PDF: no DOI line
  (`4_W3091727783`, `7_W3090985975`), no e-mails (`7_W2890913696`),
  publication date printed as "dd November 2021" (`9_W3212582118`).

- **GoldenGATE** (`gg_check.sh` from the skill, GoldenGATE Imagine Batch with
  StructureDetector + MetaDataAdder; `gg_values.tsv`, `compare3.tsv`,
  `template_report.html`, version 4 from the full pipeline run): the same style for every PDF as the checker, and no
  other Plazi style claims an Osmia PDF. Values agree with the checker except
  where GoldenGATE does better (DOI/volume/pagination of `4_W3091727783` and
  `7_W3090985975`, "Jean-Luc" Renneson) and the OpenAlex differences above.
  GoldenGATE writes surnames with particles as "Féon, Violette Le". Two
  non-articles fail to convert (scanned PDF, unreadable image).

v1 on the same PDFs: 64 recognised, 12 real articles missed, and e.g. DOI
found in 14 / 29 and publication date in 1 / 29 of the 2021- articles.

## Changes v3 → v4

From the quality control of the full Plazi pipeline (`qc_report.html`):

- Publication date: 2007-2012 from the running head (`Janvier 2007`, or the
  year), 2016-2020 from `Publication : <month year>` or the citation year.
  Only months GoldenGATE can parse are kept (not février, août, décembre):
  an unparseable date makes GoldenGATE silently drop all metadata of the
  article. Missing-date errors 30 → 1.
- Captions, all styles: Plazi's start words
  `(Fig(ure)?(s)?|FIG(URE)?(S)?|Map(s)?|MAP(S)?|Carte(s)?|CARTE(S)?)\.?` and
  `Table(s)?|TABLE(S)?|Tableau(x)?|TABLEAU(X)?` instead of patterns including
  the number, `figureWholeBlock`, `aboveTable`. Missed captions 121 → 109.
- 2021-: French section headings (RÉFÉRENCES, RÉSULTATS, MATÉRIEL ET
  MÉTHODES, REMERCIEMENTS, BIBLIOGRAPHIE). Recognised now, but GoldenGATE
  still leaves the reference list outside any section in 10 PDFs.
- No extracted value changed (`version_changes.tsv`).

## Changes v2 → v3

- `Osmia.2016-2020` author context pattern: one match per author, chained from
  the opening "par" (`(?:^[Pp]ar\s+|\G(?:\s|[,;&*0-9]|\(Coord\)|et\s)*)` +
  the author value pattern), instead of the whole `par …` line. GoldenGATE
  extracts one value per context match, so v2 gave only the first author in
  GoldenGATE (9 of 14 PDFs), while the checker, which then applied the value
  pattern to all of the context, showed all authors. The checker now applies
  context patterns of multi-value fields as GoldenGATE does.

## Changes v1 → v2

- Vol. 1 (2007) included: `2008-2012` → `2007-2012`, running head may carry a month.
- `2018` → `2016-2020` (vol. 6–8 share the layout); `2022-` → `2021-` (from vol. 9).
- DOI line no longer required (2007-2012, 2016-2020); volume/year of
  2007-2012 now read from the running head, present on every article.
- `BRÈVE` (short notes) accepted next to `ARTICLE`.
- `.1cover` variant for PDFs with a HAL cover page (`layout.coverPageCount 1`).
- Areas that depend on title length widened (title, author, citation line);
  values located by context patterns instead: citation `…: 45–54. https://…`,
  `Published (online) | …`, `Reviewers … || zoobank.org/…`, `orcid.org/… • zoobank.org/…`
  (also `www.zoobank.org`, "ZooBank http://…"); dates/article ZooBank searched on p. 1–2.
- Author pattern: given name(s) + SURNAME in capitals (small caps), or a
  mixed-case name followed by its `*`/number marker; never starts with "Par".
- Font ranges for small-caps pieces (titles ≥ 12/16 pt, authors ≥ 6 pt,
  2021- e-mails/affiliations 6–8 pt — vol. 9 uses 8 pt, later 7 pt).
- Single-page pagination allowed; DOIs ending `.edito` accepted.
- 2021-: licence block no longer a header area (vol. 9 affiliations reach
  there); filtered out of affiliations with `filterPatterns`.

## Files

- `Osmia.*` — the four styles (current); `v1/`, `v2/` — earlier versions with their results.
- `check_template.R <style> <pdf> <out.pdf>` — checks anchors and extracted
  values for one PDF, and writes a copy with all areas drawn on it (red
  anchors, blue metadata, grey header/footer, green columns, orange page
  number). Needs R `pdftools` and `qpdf`. Handles `isBold`, font ranges,
  `layout.coverPageCount`; not `filterPatterns`.
- `run_all.sh <pdf folder>` → `verification_all_pdfs.tsv` (+ `.log`).
- `compare_openalex.R <download folder>` → `compare_openalex.txt`.
- `check_results.txt` + `Osmia_<vol>_<work>__<style>.pdf` — annotated
  examples, one or more per style.

## Not verified

- Run in GoldenGATE Imagine Batch (version 20260902-2257, configuration
  Default.imagine 20261015-1753) for structure detection and metadata only, not
  the full Plazi pipeline (bibliography, taxon names, treatments). Areas and
  overlays were not inspected in the GoldenGATE user interface.
- Vol. 12 (2024): both PDFs in the set are not articles, so its layout is
  untested; vol. 14 (2025–26) is covered by three PDFs.
- `@docStyleId` etc. left out — the Plazi server assigns them.
