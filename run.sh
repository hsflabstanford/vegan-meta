#!/bin/bash
set -ex

# CO specific links
# ln -s ../data ./data
# ls -l ./data
# ln -s ../results ./results
# mkdir ../results/figures

# knit main script & replace all instances of [H] with [!ht] in the generated .tex file
Rscript -e "rmarkdown::render('./MAP-reduction-meta-appetite.Rmd', clean = T)"
sed -i '' 's/\\begin{table}\[!h\]/\\begin{table}[!ht]/g' MAP-reduction-meta-appetite.tex 
Rscript -e "tinytex::latexmk('MAP-reduction-meta-appetite.tex')"
mv ./figures/*.pdf ./results/figures

# supplement
Rscript -e "rmarkdown::render('./supplement-MAP-reduction.Rmd', clean = T)"
sed -i '' 's/\\begin{table}\[!h\]/\\begin{table}[!ht]/g' supplement-MAP-reduction.tex 
Rscript -e "tinytex::pdflatex('supplement-MAP-reduction.tex')"
mv *{.pdf,.tex} ./results

# to sort bibliography (from package `bibtex2html`, via `npm install -g bibtex-tidy`)

bibtex-tidy --curly --numeric --tab --modify --align=13 --sort=key --duplicates=key --no-escape --sort-fields --no-remove-dupe-fields --enclosing-braces=title ./vegan-refs.bib
# if log files were generated
