#' Apply metafor::robust in a pipe sequence or to subsets using purrr's split/map
#' 
#' This function simplifies the process of performing a robust meta-analysis on subsets of a dataset.
#' The typical usage involves piping a dataset into the split/map paradigm: `dat |> split(~some_var) |> map(map_robust)`.
#' Alternatively, `dat |> map_robust()` can also be used.
#' 
#' @importFrom metafor robust
#' @importFrom tibble as_tibble
#'

map_robust <- function(x) {
  # Perform robust meta-analysis using metafor::robust function
  result <- robust(x = rma(yi = x$d, vi = x$var_d), cluster = x$unique_study_id)
  
  # Extract relevant results and format them into a tibble/data frame
  output <- data.frame(
    beta = round(result$beta, 3),
    se = round(result$se, 3),
    pval = ifelse(result$pval < 0.0001, "< 0.0001", round(result$pval, digits = 4))
  ) %>% 
    as_tibble()
  
  return(output)
}
