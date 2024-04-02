#' Apply metafor::robust in a pipe sequence or to subsets using purrr's split/map
#'
#' This function simplifies the process of performing a robust meta-analysis on subsets of a dataset.
#' The typical usage involves piping a dataset into the split/map paradigm: `dat |> split(~some_var) |> map(map_robust)`.
#' Alternatively, `dat |> map_robust()` can also be used.
#'
#' NOTE: This function will FAIL SILENTLY if there is only one study in a cluster, meaning it won't 
#' produce a meta-analysis but will instead just reproduce the meta-analytic estimate verbatim. Be careful!
#'
#' @importFrom metafor robust 
#' @importFrom metafor rma
#' @importFrom tibble as_tibble
#'
#' @param x The dataset or subset to perform meta-analysis on.
#' @return A tibble/data frame with meta-analysis results.
#' @export
map_robust <- function(x) {
  # Check if there is only one study in the cluster
  if (nrow(x) == 1) {
    # Directly take Delta and SE from the dataset
    Delta <- x$d
    se <- x$se_d
    pval <- NA
    
    # Return these values in a tibble
    return(tibble::tibble(N_unique = nrow(x), Delta = Delta, se = se, pval = pval))
  } else {
    # Perform robust meta-analysis using metafor::robust function
    result <- metafor::robust(x = metafor::rma(yi = x$d, vi = x$var_d), cluster = x$unique_study_id)
    
    # Extract relevant results and format them into a tibble/data frame
    output <- data.frame(
      N_unique = nrow(x),
      Delta = round(result$beta, 3),
      se = round(result$se, 3),
      pval = ifelse(result$pval < 0.0001, "< 0.0001", round(result$pval, digits = 4))
    ) |> 
      tibble::as_tibble()
    
    return(output)
  }
}

