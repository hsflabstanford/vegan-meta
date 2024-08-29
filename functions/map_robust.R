#' Apply Robust Meta-Analysis to Data Subsets
#'
#' Applies a specified meta-analytic model to a subset of data, handling cases with a single unique study separately.
#'
#' @param x A data frame containing the meta-analytic data. It should include the variables `d` (effect size), `var_d` (variance of effect size), and `unique_study_id` (unique study identifier).
#' @param model A character string specifying the meta-analytic model to use. Options are "CORR", "HIER", or "RMA". Default is "CORR".
#'
#' @return A tibble with the following columns:
#' \itemize{
#'   \item \code{N_interventions}: Number of interventions included in the meta-analysis.
#'   \item \code{N_studies}: Number of unique studies included.
#'   \item \code{N_subjects}: Total number of subjects across studies.
#'   \item \code{Delta}: Estimated effect size, rounded to three digits.
#'   \item \code{se}: Standard error of the estimated effect size, rounded to three digits.
#'   \item \code{pval}: P-value associated with the estimated effect size, formatted for readability.
#' }
#'
#' @details
#' If there is only one unique study in the dataset, the function returns the mean effect size and its standard error. 
#' For multiple studies, the specified meta-analytic model is applied. Supported models include "CORR" and "HIER" from the `robumeta` package, and "RMA" from the `metafor` package.
#'
#' @examples
#' \dontrun{
#'   # Example usage:
#'   result <- map_robust(my_data, model = "RMA")
#'   print(result)
#' }
#'
#' @importFrom dplyr summarise pull tibble
#' @importFrom robumeta robu
#' @importFrom metafor rma
#' @export
map_robust <- function(x, model = "CORR") {
  tryCatch({
    format_pval <- function(p) {
      if (is.na(p)) return(NA)
      if (p < 0.0001) return("< .0001")
      formatted_p <- formatC(p, format = "f", digits = 4)
      return(ifelse(p < 1, gsub("^0\\.", ".", formatted_p), formatted_p))
    }
    
    round_to <- function(x, accuracy, f = round) {
      f(x / accuracy) * accuracy
    }
    
    calculate_n_total <- function(data) {
      summarise(data, n_total = round_to(sum(n_t_total_pop + n_c_total_pop), 100, floor)) |>
        pull(n_total)
    }
    
    N_total <- calculate_n_total(x)
    
    if (length(unique(x$unique_study_id)) == 1) {
      Delta <- round(mean(x$d), 3)
      se <- round(mean(x$se_d), 3)
      pval <- NA
      output <- tibble(
        N_interventions = nrow(x),
        N_studies = length(unique(x$unique_study_id)),
        N_subjects = N_total,
        Delta = Delta,
        se = se,
        pval = pval
      )
    } else {
      if (model == "CORR" || model == "HIER") {
        result <- robu(formula = d ~ 1, data = x, 
                       studynum = unique_study_id, 
                       var.eff.size = var_d, 
                       modelweights = model)
        output <- tibble(
          N_interventions = result$M,
          N_studies = result$N,
          N_subjects = N_total,
          Delta = round(result$reg_table$b.r, 3),
          se = round(result$reg_table$SE, 3),
          pval = format_pval(result$reg_table$prob)
        )
      } else if (model == "RMA") {
        result <- metafor::rma(yi = d, vi = var_d, data = x)
        output <- tibble(
          N_interventions = nrow(x),
          N_studies = length(unique(x$unique_study_id)),
          N_subjects = N_total,
          Delta = round(result$b, 3),
          se = round(result$se, 3),
          pval = format_pval(result$pval)
        )
      } else {
        stop("Invalid model specified. Choose 'CORR', 'HIER', or 'RMA'.")
      }
    }
    
    return(output)
  }, error = function(e) {
    message("Error: ", e$message)
    return(tibble(
      N_interventions = NA,
      N_studies = NA,
      N_subjects = NA,
      Delta = NA,
      se = NA,
      pval = NA
    ))
  })
}
