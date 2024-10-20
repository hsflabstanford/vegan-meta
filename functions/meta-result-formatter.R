#' Format Meta-Analysis Results
#' This function formats the results of a meta-analysis by 
#' combining effect sizes, standard errors, and p-values
#' into a standardized format with significance stars.
#' It returns a character vector with the formatted results.
#' @param model A tibble containing columns `Delta`, `se`, and `pval`. 
#' `Delta` represents the effect size, 
#' `se` is the standard error, and `pval` is the p-value.
#' 
#' @return A character vector with the formatted results. 
#' Each entry is formatted as `Delta*** (se)` where
#' stars are added based on the p-value significance level. 
#' @export
meta_result_formatter <-function(model){
  model |>
    mutate(
      formatted = sprintf("%.4f%s (%.4f)", Delta,
                          case_when(is.na(pval)~"",
                                    as.numeric(pval) < 0.001 ~ "***",
                                    as.numeric(pval) < 0.01 ~ "**",
                                    as.numeric(pval) < 0.05 ~ "*",
                                    TRUE ~ ""),
                          se)) |> 
    pull(formatted)
  }