table_one_function <- function(filter_string = NULL, filter_column = NULL, 
                               str_detect_flag = TRUE, approach_name = "Overall", 
                               data = dat) {
  
  # Handle the case where no filter is applied
  if (is.null(filter_string) || is.null(filter_column)) {
    filtered_data <- data
  } else {
    # Apply appropriate filtering based on the str_detect_flag
    if (str_detect_flag) {
      filtered_data <- data %>% 
        filter(str_detect(!!sym(filter_column), filter_string))
    } else {
      filtered_data <- data %>% 
        filter(!!sym(filter_column) == filter_string)
    }
  }
  
  # Check if the filtered data has any rows; if not, return a tibble with NA
  if (nrow(filtered_data) == 0) {
    result <- tibble(
      Approach = approach_name,
      N_Studies = NA_integer_,
      N_estimates = NA_integer_,
      Delta = NA_real_,
      CI = NA_character_,
      p_val = NA_real_
    )
    return(result)
  }
  
  # Run the robumeta::robu model on the filtered data
  model <- robumeta::robu(
    formula = d ~ 1,
    data = filtered_data,
    studynum = filtered_data$unique_study_id,
    var.eff.size = filtered_data$var_d,
    modelweights = 'CORR',
    small = TRUE
  )
  
  # Extract results
  estimate <- model$reg_table$b.r
  ci_lower <- model$reg_table$CI.L
  ci_upper <- model$reg_table$CI.U
  p_val <- format(round(model$reg_table$prob, 3), scientific = FALSE)
  p_val <- sub("^0\\.", ".", p_val)  # Remove leading zero
  num_studies <- length(unique(filtered_data$unique_study_id))  
  num_estimates <- nrow(filtered_data)  
  
  # Create the base tibble
  result <- tibble(
    Approach = approach_name,
    N_Studies = num_studies,
    N_estimates = num_estimates,  
    Delta = round(estimate, 2),  
    CI = paste0("[", round(ci_lower, 2), ", ", round(ci_upper, 2), "]"),
    p_val = p_val
  )
  
  return(result)
}
