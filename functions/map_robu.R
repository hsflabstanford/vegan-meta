#' Apply robumeta::robu in a pipe sequence or to subsets using purrr's split/map
#'
#' Performs robust variance estimation (RVE) meta-regression on eithersubsets
#'  or the whole dataset.
#' Its intended usage is in in context of the  split/map & pipes paradigm: 
#' `dat |> split(~some_var) |> map(map_robu)`.
#' 
#' `dat |> map_robu()` will return the meta-analytic estimate for the whole dataset.
#'
#' NOTE: If there is only one study in a cluster, this function will
#' just reproduce that study's meta-analytic estimate verbatim. This is good for
#' some circumstances but not others. Adapt to your needs.
#'
#' @importFrom robumeta robu 
#' @importFrom tibble as_tibble
#'
#' @param x The dataset or subset to perform meta-analysis on.
#' @param model The underlying meta-analytic model: 'CORR' is default and 'HIER' is 2nd option
#' @return A tibble/data frame with meta-analysis results.
#' @export

map_robu <- function(x, model = "CORR") {
  # Function to format p-values without leading zeroes or unnecessary detail 
  # if they're very small
  format_pval <- function(p) {
    if (is.na(p)) {
      NA
    } else if (p < 0.0001) {
      "< .0001"
    } else {
      formatted_p <- formatC(p, format = "f", digits = 4)
      if (substr(formatted_p, 1, 1) == "0") {
        substr(formatted_p, 2, nchar(formatted_p))
      } else {
        formatted_p
      }
    }
  }
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
    result <- robu(formula = d ~ 1, data = x, 
                   studynum = unique_study_id, 
                   var.eff.size = var_d, modelweights = model)
    output <- data.frame(
      N_studies = result$N,
      Delta = round(result$reg_table$b.r, 4),
      se = round(result$reg_table$SE, 4),
      pval = format_pval(result$reg_table$prob)) |> 
      tibble::as_tibble()
    
    return(output)
  }
}
