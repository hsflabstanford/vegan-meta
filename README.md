# Reducing consumption of meat and animal products: what works? 

what do high-quality RCTs tell us about vegan persuasion efforts?

Forthcoming on the effecive altruism forum, and then eventually (we hope) in an academic paper

### The main files:

  * `vegan-meta-pap.Rmd` simulates data and runs our planned analyses on it. It also lists some guiding principles for how we recorded data from studies.
  * `vegan-meta.Rmd` runs the quantitative analyses on our actual dataset.
  * `run.sh` executes the scripts.

### functions
everything in `functions` is used in the analysis, and the files themselves should be pretty well-documented. Mostly I wrote them to avoid writing certain bits of code over and over, or to have something that was formatted properly to work in a sequence of pipes (`|>`). I mostly copied them verbatim from https://github.com/setgree/sv-meta, but in brief:
  * `d_calc.R` is the main function for calculating Glass's $\Delta$;
  * `map_robust.R` is a wrapper around `metafor::robust()` that allows you to pipe results to the function (e.g. `dat |> map_robust()`), or do `purrr` stuff (e.g.`dat |> split(~some_var) | > map(map_robust)`);
  * `study_count.R` counts unique_study_id(s) in a subset or subsets of the data 
  * `sum_lm.R`prints a subset of the results from `summary(lm())` and also works in a pipe
  * `sum_tab.R` exists because this chunk doesn't work/have a dplyr-native solution:  `dat |> filter(some_var) |> table(some_other_var)`. The function prints the output from `table(some_other_var)` in a way that's pipe compatible.
  * `var_d_calc.R` calculates the variance of $\Delta$.
  
### data
  * `vegan-meta.csv`  is our dataset of studies
  * `excluded-studies.csv` is our list of studies we looked at but didn't include
  * `vegan-codebook.csv` is our codebook for the dataset
  
The other stuff in this repo is project setup, license, .gitignore, etc. 

Our code and data are also [available on Code Ocean](https://doi.org/10.24433/CO.6020578.v1), where they can be rerun from scratch in a frozen, code-compatible computational environment.

