#!/bin/bash
set -ex

Rscript -e "rmarkdown::render('./manuscript/MAP-reduction-meta.Rmd', clean = T)"
