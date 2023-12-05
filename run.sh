#!/bin/bash
set -ex

# step 1: descriptive stats
Rscript -e "rmarkdown::render('./vegan-meta.Rmd', output_dir = './results')"
