# Meaningfully reducing consumption of meat and animal products is an unsolved problem: results from a meta-analysis


## code
  * `./MAP-reduction-meta.Rmd` is the paper, along with its `.bib` file and style file, etc. 
  * `./supplement-MAP-reduction.Rmd`, the supplement
  * `./scripts/*.R` is where most of the actual R code lives
  * `./functions/*.R` are some functions we wrote, mostly adapted/lifted from a previous project, [PaluckMetaSOP](https://github.com/setgree/PaluckMetaSOP).

## data
  * `./data/vegan-meta.csv`  is our dataset of studies
  * `./data/RPMC-data.csv` is a supplementary dataset of studies aimed at reducing consumption of red and processed meat
  * `./data/excluded-studies.csv` is our list of studies we looked at but didn't include & why
  * `./data/review-of-reviews.csv` is a list of prior reviews we looked at to find studies
  
## everything else
project setup, license, .gitignore, past drafts, presentations etc.

## To reproduce the paper locally
(This assumes you use Rstudio)
1. Download this repo (`git clone https://github.com/hsflabstanford/vegan-meta.git`)
2. Open `vegan-meta.Rproj` (all paths are set relative to its directory)
3. Make sure everything in `./scripts/libraries.R` is installed
4. Either run `run.sh` or open `./manuscript/MAP-reduction-meta.Rmd` and select `knit`


