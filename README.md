# vegan-meta
what do high-quality RCTs tell us about vegan persuasion efforts?

### about this repo

* `vegan-meta-pap.Rmd` is basically an outline for how I plan to do the analyses. It also lists some guiding principles for how we recorded data from studies.

* `run.sh` executes the script(s)

* everything in `functions` is used in the analysis, and the files themselves should be pretty well-documented. I copied them verbatim from https://github.com/setgree/sv-meta, but in brief:
  * `d_calc.R` is the main function for calculating Glass's $\Delta$ or Cohen's d, depending on what you standardize on. This paper uses Glass's $\Delta$. This function was developed and refined over the course of the Contact and Prejudice reduction metas that Seth and John-Henry worked on previously. 
  * `map_robust.R` is a wrapper around `metafor::robust()` that allows us to pipe results to the function. It also works with `split | > map` analyses, which we found useful. 
  * `sum_lm.R`prints a subset of the results from `summary(lm())` and also works in a pipe, e.g. `dat |> sum_lm()`.
  * `var_d_calc.R` calculates the variance of $\Delta$.
  
The other stuff is project setup, the license, etc. 