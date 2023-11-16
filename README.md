# vegan-meta
what do high-quality RCTs tell us about vegan persuasion efforts?

### about this repo

* `vegan-meta-pap.Rmd` is an outline for how I plan to do the analyses. It also lists some guiding principles for how we recorded data from studies.

* `run.sh` executes the script(s).

* everything in `functions` is used in the analysis, and the files themselves should be pretty well-documented. I copied them verbatim from https://github.com/setgree/sv-meta, but in brief:
  * `d_calc.R` is the main function for calculating Glass's $\Delta$;
  * `map_robust.R` is a wrapper around `metafor::robust()` that allows you to pipe results to the function (e.g. `dat |> map_robust()`), or do `purrr` stuff (e.g.`dat |> split(~some_var) | > map(map_robust)`);
  * `sum_lm.R`prints a subset of the results from `summary(lm())` and also works in a pipe
  * `var_d_calc.R` calculates the variance of $\Delta$.
  
The other stuff is project setup, the license, etc. 