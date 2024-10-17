forest_meta_function <- function(x) {
  result <- rma.uni(yi = x$d, vi = x$var_d, method = 'EE', slab = paste0(x$author, x$year))
  tibble(
    author = x$author[1],        
    year = x$year[1],            
    theory = x$theory[1],        
    estimate = as.numeric(result$b),
    se = result$se,
    var = result$vb,
    ci.lb = result$ci.lb,        
    ci.ub = result$ci.ub,        
  )
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

round_to <- function(x, accuracy, f = round) {
  f(x / accuracy) * accuracy
}
# handy shortcut 
# mr <- meta_result_formatter

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
