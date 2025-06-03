#!/bin/bash
set -ex

# CO specific links
# ln -s ../data ./data
# ls -l ./data
# ln -s ../results ./results
# mkdir ../results/figures

# knit main script & replace all instances of [H] with [!ht] in the supplementary .tex file
Rscript -e "rmarkdown::render('./MAP-reduction-meta-appetite.Rmd', output_dir = './results', clean = T)"
Rscript -e "rmarkdown::render('./supplement-MAP-reduction.Rmd', output_dir = './results', clean = T)"

# to sort bibliography (from package `bibtex2html`, via `npm install -g bibtex-tidy` -- requires Node.js)
bibtex-tidy --curly --numeric --tab --modify --align=13 --sort=key --duplicates=key --no-escape --sort-fields --no-remove-dupe-fields --enclosing-braces=title ./vegan-refs.bib

