#!/bin/bash
set -ex

Rscript -e "rmarkdown::render('./MAP-reduction-meta.Rmd', clean = T)"
Rscript -e "rmarkdown::render('./supplement-MAP-reduction.Rmd', clean = T)"

# Replace all instances of [H] with [!ht] in the generated .tex file
sed -i '' 's/\\begin{table}\[!h\]/\\begin{table}[!ht]/g' MAP-reduction-meta.tex 
sed -i '' 's/\\begin{table}\[!h\]/\\begin{table}[!ht]/g' supplement-MAP-reduction.tex 

Rscript -e "tinytex::latexmk('MAP-reduction-meta.tex')"
Rscript -e "tinytex::pdflatex('supplement-MAP-reduction.tex')"

# move results to results and get rid of aux stuff
mv *{.pdf,.tex} ./results && rm *.{aux,out,blg}

# to sort bibliography (from package `bibtex2html`, via `npm install -g bibtex-tidy`)
bibtex-tidy --curly --numeric --tab --modify --align=13 --sort=key --duplicates=key --no-escape --sort-fields --no-remove-dupe-fields --enclosing-braces=title ./documentation/vegan-refs.bib

# if log files were generated
rm *.log
