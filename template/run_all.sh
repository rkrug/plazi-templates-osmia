#!/bin/sh
# Check every Osmia.* style in this folder against every PDF in $1; per-PDF summary to verification_all_pdfs.tsv
# usage: sh run_all.sh ../source-is-Osmia-S4210192884/pdf
cd "$(dirname "$0")"
out=$(mktemp -d)
for p in "$1"/*.pdf; do for t in Osmia.*; do echo "$t $p"; done; done |
  xargs -P 6 -n 2 sh -c 'LANG=en_US.UTF-8 Rscript check_template.R "$0" "$1" /dev/null > "'"$out"'/$(basename "$1" .pdf)__$0.txt" 2>&1'
printf "pdf\trecognised_by\tempty_fields\n" > verification_all_pdfs.tsv
for p in "$1"/*.pdf; do
  f=$(basename "$p" .pdf); m=""; e=""
  for t in Osmia.*; do
    r="$out/${f}__$t.txt"
    grep -q '^##' "$r" && ! grep -q 'did NOT match' "$r" &&
      { m="$m${m:+,}$t"; e=$(grep '<none>' "$r" | awk '{print $1}' | paste -sd, -); }
  done
  printf "%s\t%s\t%s\n" "$f" "${m:-none}" "$e" >> verification_all_pdfs.tsv
done
cat "$out"/*.txt > verification_all_pdfs.log
rm -r "$out"
