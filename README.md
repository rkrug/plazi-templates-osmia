# Osmia — Plazi document styles

Plazi/GoldenGATE document styles ("journal templates") for **Osmia — Revue
d'Hyménoptérologie / Journal of Hymenopterology** (ISSN 2727-3806), built and
checked with the `plazi-journal-template` skill (repository `goldengate`).

- `template/` — the current styles (version 4), their check results,
  `template_report.html` and `qc_report.html` (GoldenGATE's quality
  control); `template/README.md` describes the styles, the test results and
  the changes per version.
- `template/v1/` … `v4/` — frozen versions with their results and annotated
  example PDFs (`vN/annotated/`, not in git);
  `vN/changes.txt` lists what changed in each style.
- `source-is-…/` — the OpenAlex queries of the downloads the styles were
  tested on (`works/parquet/_query_oql.txt`).

Not in git: the downloaded PDFs, OpenAlex parquet files and GoldenGATE output.
Recreate the downloads by running the query with the download app, then the
checks as described in the skill.
