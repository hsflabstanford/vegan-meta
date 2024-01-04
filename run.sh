#!/bin/bash
set -ex

# step 0: pre-analysis plan
Rscript -e "rmarkdown::render('./scripts/vegan-meta-pap.Rmd', output_dir = './results')"

# step 1: meta-analysis
Rscript -e "rmarkdown::render('./scripts/vegan-meta.Rmd', output_dir = './results')"
