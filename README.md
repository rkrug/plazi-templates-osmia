# Osmia — Plazi document styles

Plazi/GoldenGATE document styles ("journal templates") for **Osmia — Revue
d'Hyménoptérologie / Journal of Hymenopterology** (ISSN 2727-3806), built and
checked with the `plazi-journal-template` skill (repository [rkrug/plazi-journal-templates](https://github.com/rkrug/plazi-journal-templates)).

- `template/` — the current styles (version 4), their check results,
  `template_report.html` and `qc_report.html` (GoldenGATE's quality
  control); `template/README.md` describes the styles, the test results and
  the changes per version.
- `template/v1/` … `v4/` — frozen versions with their results and annotated
  example PDFs (`vN/annotated/`, not in git);
  `vN/changes.txt` lists what changed in each style.
- [Releases](https://github.com/rkrug/plazi-templates-osmia/releases) v1–v4:
  per version the annotated example PDFs and the GoldenGATE run (v3:
  structure and metadata, v4: the whole Plazi pipeline with IMFs, figures,
  error protocols and Darwin Core Archives), too large for git.
- `source-is-…/` — the OpenAlex queries of the downloads the styles were
  tested on (`works/parquet/_query_oql.txt`).

Not in git: the downloaded PDFs, OpenAlex parquet files and GoldenGATE output.
Recreate the downloads by running the query with the download app, then the
checks as described in the skill.

## Reconstructing the folders

The repository holds everything but the large or downloaded files. To get
back the folders as they were when version 4 was frozen (needs `gh`, logged
in, and on macOS APFS for `cp -c`):

```bash
# 1. the repository, next to the skill's repository (paths in the reports assume ~/GitHub/goldengate/osmia)
cd ~/GitHub/goldengate && gh repo clone rkrug/plazi-templates-osmia osmia && cd osmia/template

# 2. per version: annotated examples (also in git) and the GoldenGATE runs, from the releases
R=rkrug/plazi-templates-osmia
for v in v1 v2 v3 v4; do gh release download $v -R $R -p '*__*.pdf' -D $v/annotated --skip-existing; done
gh release download v3 -R $R -p '*.pdf.imf*' -D v3/gg_out
gh release download v4 -R $R -p '*.pdf.imf*' -D v4/gg_full

# 3. the working copies of the last runs (clones, no extra disk space)
cp -c -R v4/gg_full gg_full && cp -c -R v3/gg_out gg_out
```

4. **Downloaded articles and OpenAlex records** (`source-is-…/pdf/`,
   `works/parquet/*.parquet`): run the query in each download's
   `works/parquet/_query_oql.txt` with the download app
   (`~/GitHub/fulltext_download`, output folder `~/GitHub/goldengate/osmia`);
   it recreates the folders under the same names. PDFs come from OpenAlex's
   content service ($0.01 each, 101 PDFs); OpenAlex may by now return a few
   more or different works.

The "open in GoldenGATE" links in the local reports are absolute paths
under `~/GitHub/goldengate/osmia`; at another location, regenerate the
reports (`report.R`, `qc_report.R` in the skill, run inside `template/` or
`template/vN/` with the PDF folder as argument).

