#!/bin/bash
set -ex

# CO specific links
# ln -s ../data ./data
# ls -l ./data
# ln -s ../results ./results
# mkdir ../results/figures

# knit main script & replace all instances of [H] with [!ht] in the supplementary .tex file
Rscript -e "rmarkdown::render('./WORD-MAP-reduction-meta-appetite.Rmd', clean = T)"
Rscript -e "rmarkdown::render('./supplement-MAP-reduction.Rmd', clean = T)"
sed -i '' 's/\\begin{table}\[!h\]/\\begin{table}[!ht]/g' supplement-MAP-reduction.tex 
Rscript -e "tinytex::pdflatex('supplement-MAP-reduction.tex')"

# or the PDF version
Rscript -e "rmarkdown::render('./PDF-MAP-reduction-meta.Rmd', clean = T)"
sed -i '' 's/\\begin{table}\[!h\]/\\begin{table}[!ht]/g' PDF-MAP-reduction-meta.tex 
Rscript -e "tinytex::pdflatex('PDF-MAP-reduction-meta.tex')"

# move things over but supress error message if nothing is found
rm *.spl 2>/dev/null || true
mv *.tex *.pdf *.docx ./results 2>/dev/null || true
mv ./results/PDF-MAP-reduction-meta.tex MAP-reduction-meta.tex
# to sort bibliography (from package `bibtex2html`, via `npm install -g bibtex-tidy`)

bibtex-tidy --curly --numeric --tab --modify --align=13 --sort=key --duplicates=key --no-escape --sort-fields --no-remove-dupe-fields --enclosing-braces=title ./vegan-refs.bib
# if log files were generated
