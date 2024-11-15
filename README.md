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

## SessionInfo
```
─ Session info ─────────────────────────────────────────────────────────────────────────────────────────────────────────────
 setting  value
 version  R version 4.4.1 (2024-06-14)
 os       macOS 15.1
 system   aarch64, darwin20
 ui       RStudio
 language (EN)
 collate  en_US.UTF-8
 ctype    en_US.UTF-8
 tz       America/New_York
 date     2024-11-15
 rstudio  2024.09.1+394 Cranberry Hibiscus (desktop)
 pandoc   3.5 @ /opt/homebrew/bin/ (via rmarkdown)

─ Packages ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 package         * version    date (UTC) lib source
 cli               3.6.3      2024-06-21 [1] CRAN (R 4.4.0)
 colorspace        2.1-1      2024-07-26 [1] CRAN (R 4.4.0)
 digest            0.6.37     2024-08-19 [1] CRAN (R 4.4.1)
 dplyr           * 1.1.4      2023-11-17 [1] CRAN (R 4.4.0)
 evaluate          1.0.1      2024-10-10 [1] CRAN (R 4.4.1)
 fansi             1.0.6      2023-12-08 [1] CRAN (R 4.4.0)
 fastmap           1.2.0      2024-05-15 [1] CRAN (R 4.4.0)
 forcats         * 1.0.0      2023-01-29 [1] CRAN (R 4.4.0)
 generics          0.1.3      2022-07-05 [1] CRAN (R 4.4.0)
 ggplot2         * 3.5.1      2024-04-23 [1] CRAN (R 4.4.0)
 ggtext          * 0.1.2      2022-09-16 [1] CRAN (R 4.4.0)
 glue              1.8.0      2024-09-30 [1] CRAN (R 4.4.1)
 gridtext          0.1.5      2022-09-16 [1] CRAN (R 4.4.0)
 gtable            0.3.5      2024-04-22 [1] CRAN (R 4.4.0)
 htmltools         0.5.8.1    2024-04-04 [1] CRAN (R 4.4.0)
 kableExtra      * 1.4.0      2024-01-24 [1] CRAN (R 4.4.0)
 knitr             1.48       2024-07-07 [1] CRAN (R 4.4.0)
 lattice           0.22-6     2024-03-20 [1] CRAN (R 4.4.1)
 lifecycle         1.0.4      2023-11-07 [1] CRAN (R 4.4.0)
 magrittr          2.0.3      2022-03-30 [1] CRAN (R 4.4.0)
 mathjaxr          1.6-0      2022-02-28 [1] CRAN (R 4.4.0)
 Matrix          * 1.7-0      2024-04-26 [1] CRAN (R 4.4.1)
 metadat         * 1.2-0      2022-04-06 [1] CRAN (R 4.4.0)
 metafor         * 4.6-0      2024-03-28 [1] CRAN (R 4.4.0)
 MetaUtility     * 2.1.2      2021-10-30 [1] CRAN (R 4.4.0)
 munsell           0.5.1      2024-04-01 [1] CRAN (R 4.4.0)
 nlme              3.1-164    2023-11-27 [1] CRAN (R 4.4.1)
 numDeriv        * 2016.8-1.1 2019-06-06 [1] CRAN (R 4.4.0)
 pillar            1.9.0      2023-03-22 [1] CRAN (R 4.4.0)
 pkgconfig         2.0.3      2019-09-22 [1] CRAN (R 4.4.0)
 PublicationBias * 2.4.0      2024-10-22 [1] Github (mathurlabstanford/PublicationBias@748b33e)
 purrr           * 1.0.2      2023-08-10 [1] CRAN (R 4.4.0)
 R6                2.5.1      2021-08-19 [1] CRAN (R 4.4.0)
 rbibutils         2.3        2024-10-04 [1] CRAN (R 4.4.1)
 Rcpp              1.0.13     2024-07-17 [1] CRAN (R 4.4.0)
 Rdpack            2.6.1      2024-08-06 [1] CRAN (R 4.4.0)
 rlang             1.1.4      2024-06-04 [1] CRAN (R 4.4.0)
 rmarkdown         2.28       2024-08-17 [1] CRAN (R 4.4.0)
 robumeta        * 2.1        2023-03-28 [1] CRAN (R 4.4.0)
 rstudioapi        0.17.1     2024-10-22 [1] CRAN (R 4.4.1)
 rticles         * 0.27       2024-04-06 [1] CRAN (R 4.4.0)
 scales          * 1.3.0      2023-11-28 [1] CRAN (R 4.4.0)
 sessioninfo       1.2.2      2021-12-06 [1] CRAN (R 4.4.0)
 stringi           1.8.4      2024-05-06 [1] CRAN (R 4.4.0)
 stringr         * 1.5.1      2023-11-14 [1] CRAN (R 4.4.0)
 svglite           2.1.3      2023-12-08 [1] CRAN (R 4.4.0)
 systemfonts       1.1.0      2024-05-15 [1] CRAN (R 4.4.0)
 tibble            3.2.1      2023-03-20 [1] CRAN (R 4.4.0)
 tidyr           * 1.3.1      2024-01-24 [1] CRAN (R 4.4.0)
 tidyselect        1.2.1      2024-03-11 [1] CRAN (R 4.4.0)
 utf8              1.2.4      2023-10-22 [1] CRAN (R 4.4.0)
 vctrs             0.6.5      2023-12-01 [1] CRAN (R 4.4.0)
 viridisLite       0.4.2      2023-05-02 [1] CRAN (R 4.4.0)
 withr             3.0.1      2024-07-31 [1] CRAN (R 4.4.0)
 xfun              0.48       2024-10-03 [1] CRAN (R 4.4.1)
 xml2              1.3.6      2023-12-04 [1] CRAN (R 4.4.0)
 ```


