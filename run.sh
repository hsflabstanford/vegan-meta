#!/bin/bash
set -ex

Rscript -e "rmarkdown::render('./MAP-reduction-meta.Rmd', clean = T)"

# Replace all instances of [H] with [!ht] in the generated .tex file
sed -i '' 's/\\begin{table}\[!h\]/\\begin{table}[!ht]/g' MAP-reduction-meta.tex

Rscript -e "tinytex::latexmk('MAP-reduction-meta.tex')"

# for code ocean
# mv *.pdf ../results
# to sort bibliography (from package `bibtex2html`, via `npm install -g bibtex-tidy`)
bibtex-tidy --curly --numeric --tab --modify --align=13 --sort=key --duplicates=key --no-escape --sort-fields --no-remove-dupe-fields --enclosing-braces=title ./vegan-refs.bib
