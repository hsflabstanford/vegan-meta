#!/bin/bash
set -ex

Rscript -e "rmarkdown::render('./MAP-reduction-meta.Rmd', clean = T)"


# to sort bibliography (from package `bibtex2html`, via `npm install -g bibtex-tidy`)
bibtex-tidy --curly --numeric --tab --modify --align=13 --sort=key --duplicates=key --no-escape --sort-fields --no-remove-dupe-fields --enclosing-braces=title ./vegan-refs.bib
