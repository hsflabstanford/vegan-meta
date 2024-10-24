meta_table_maker <- function(data, format = "latex", booktabs = TRUE, escape = FALSE,
                             caption = "", label = "", footnote = FALSE) {
  table <- knitr::kable(data, format = format, booktabs = booktabs, escape = escape, 
                        caption = caption, label = label) |>
    kableExtra::kable_styling(latex_options = "hold_position")
  
  if (footnote) {
    table <- table |>
      kableExtra::footnote(
        general_title = "",
        general = "* p $<$ 0.05, ** p $<$ 0.01, *** p $<$ 0.001.",
        escape = FALSE
      )
  }
  
  return(table)
}

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

get_significance_stars <- function(pval) {
  sapply(pval, function(x) {
    if (is.na(x)) {
      ""
    } else if (x < .001) {
      "***"
    } else if (x < .01) {
      "**"
    } else if (x < .05) {
      "*"
    } else {
      ""
    }
  })
}

# handy shortcut 
mr <- meta_result_formatter

# something for first descriptive table
summarize_to_tibble <- function(data, condition, group_col_name, sort_desc = TRUE) {
  result <- data |>
    mutate({{ group_col_name }} := case_when(!!!condition)) |>  # Apply the condition to create the grouping variable
    group_by({{ group_col_name }}) |>
    summarise(study_count = n_distinct(unique_study_id)) |>
    mutate(Category = as.character({{ group_col_name }}), `Number of Studies` = study_count, .keep = "none")
  
  if (sort_desc) {
    result <- result |>
      arrange(desc(`Number of Studies`))  # Sort by Number of Studies if sort_desc is TRUE
  }
  
  return(result)
}

bold_labels <- function(x) {
  ifelse(x == "RE Estimate", "<b>RE Estimate</b>", x)
}

# prior version of this function
extract_model_results <- function(model, approach_name) {
  estimate <- model$reg_table$b.r
  ci_lower <- model$reg_table$CI.L
  ci_upper <- model$reg_table$CI.U
  p_val <- round(model$reg_table$prob, 4)
  
  num_studies <- length(unique(model$X.full$study))  # Number of unique studies
  num_point_estimates <- nrow(model$data.full)       # Total number of rows (point estimates)
  
  # Create the tibble and remove backticks by renaming columns with valid R names
  tibble(
    Approach = approach_name,
    N_Studies = num_studies,
    N_Point_estimates = num_point_estimates,  
    Delta = round(estimate, 3),  # Changed from `∆` to Delta for R Markdown
    CI = paste0("[", round(ci_lower, 3), ", ", round(ci_upper, 3), "]"),  # Renamed `95% CIs` to CI
    p_val = p_val  # Renamed `p val` to p_val
  )
}
