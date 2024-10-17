extract_model_results <- function(filter_string = NULL, filter_column = NULL, str_detect_flag = TRUE, approach_name = "Overall", data = dat) {
  # Handle the case where no filter is applied
  if (is.null(filter_string) || is.null(filter_column)) {
    filtered_data <- data
  } else {
    # Apply the appropriate filtering based on the str_detect_flag
    if (str_detect_flag) {
      filtered_data <- data |> filter(str_detect(!!sym(filter_column), filter_string))
    } else {
      filtered_data <- data |> filter(!!sym(filter_column) == filter_string)
    }
  }
  
  # Run the robumeta::robu model on the filtered data
  model <- robumeta::robu(
    formula = d ~ 1,
    data = filtered_data,
    studynum = unique_study_id,
    var.eff.size = var_d,
    modelweights = 'CORR',
    small = TRUE
  )
  
  # Extract results
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
