# Reducing consumption of meat and animal products: what works? 

what do high-quality RCTs tell us about vegan persuasion efforts?

The first draft is available on the [EA Forum](https://forum.effectivealtruism.org/posts/k9qqGZtmWz3x4yaaA/environmental-and-health-appeals-are-the-most-effective). Next up is to convert this into a real paper.

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

### paper TODOs
1. Do attitudes and/or intentions predict behaviors? To assess this, we’ll record all attitudinal and intentional outcomes in our database of studies.
2. What can we say about whether people compensate for less meat at one meal with more meat at another? If we studies that show this, then many behavioral economics studies that measure outcomes immediately might not be properly capturing overall effects. In other words, they might be missing widespread ‘regression to the meat.’
3. What are the most common methodological shortcomings of extant work? To assess this, we will conduct a systematic review of all papers that describe themselves, or that were described by previous systematic reviews, as experiments, RCTs, or field experiments, and check which of our criteria they do not meet. This will give researchers a sense of where the field would most benefit from additional attention to rigor: internal validity (randomization), measurement validity (measuring MAP consumption with delay), or statistical power (sample sizes). 
4. What can we say about Intention to Treat (ITT) estimates and comparative cost-effectiveness? For these analyses, we will redo our coding to include more information about initial assignments, as well as potentially code more papers to see how many provide cost estimates. These estimates would be especially relevant for grantmaking institutions. 
5. Try to convert all studies to common measure like grams of meat (sometimes going to be possible but not always — ask for supplementary data from authors)
6. Ask for supplementary data about post-treatment outcomes — rebound or compensation effects
7. Rewrite the introduction to motivate the problem
8. Code up behavioral intentions and attitudes when available 
9. Set up systematic review (to be or not to be conducted) 
10. Calibrated estimate, `MetaUtility::prop_stronger` to give us a sense of results if we weight differently 
7. Publication bias — selection models/sensitivity analyses around significance in addition to point estimates.
8. Funnel plot assumes that the way publication bias manifests is through effect size. other alternative is on significance. maximally severe test for that is tometa-analyze the studies that were nonsignificant or negative
9. Funnel plots will regress on point estimate, which design selection on large point estimates; also look at selection on significance — hedge’s selection model, etc.
10. Incorporate feedback from Dan (I have to recategorize a few studies that I called behavioral but are really Econ)