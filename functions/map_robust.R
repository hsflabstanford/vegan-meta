#' Apply metafor::robust in a pipe sequence or to subsets using purrr's split/map
#'
#' Performs robust meta-analysis on either data subsets or the whole dataset..
#' Its intended usage is in in context of the  split/map & pipes paradigm: 
#' `dat |> split(~some_var) |> map(map_robust)`.
#' 
#' `dat |> map_robust()` will return the meta-analytic estimate for the whole dataset.
#'
#' NOTE: If there is only one study in a cluster, this function will
#' just reproduce that study's meta-analytic estimate verbatim. This is good for
#' some circumstances but not others. Adapt to your needs.
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
    Delta <- round(x$d, 3)
    se <- round(x$se_d, 3)
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

