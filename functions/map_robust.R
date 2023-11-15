#' Apply metafor::robust to the split/map paradigm from purrr.
#' 
#' Our meta-analysis often called for splitting the dataset into subsets
#' (e.g. behavioral vs. ideas-based outcomes, or by study design) and then 
#' separately meta-analyzing each subset. This led to some very clunky 
#' syntax, so we wrote this function to make our code easier to write and read, 
#' and then to extract just the results we were actually using in the paper.
#' 
#' The typical call is `dat |> split(~some_var) |> map(map_robust)`, but
#' `dat |> map_robust()` also works. 
#' 
#'@importFrom metafor robust
#'@importFrom tibble as_tibble



map_robust <- function(x) {
  result <- robust(x = rma(yi = x$d, vi = x$var_d), 
                   cluster = x$unique_study_id)
  data.frame(beta = round(result$beta, 3),
             se = round(result$se, 3),
             pval = ifelse(result$pval < 0.0001, "< 0.0001", 
                           round(result$pval, digits = 4))) %>% 
    as_tibble()
}
