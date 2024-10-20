extract_model_results <- function(filter_string = NULL, filter_column = NULL, 
                                  str_detect_flag = TRUE, approach_name = "Overall", 
                                  data = dat, second_p_value = FALSE) {
  
  # Handle the case where no filter is applied
  if (is.null(filter_string) || is.null(filter_column)) {
    filtered_data <- data
  } else {
    # Apply the appropriate filtering based on the str_detect_flag
    if (str_detect_flag) {
      filtered_data <- data |> 
        filter(str_detect(!!sym(filter_column), filter_string))
    } else {
      filtered_data <- data |> 
        filter(!!sym(filter_column) == filter_string)
    }
  }
  
  # Check if the filtered data has any rows, if not return a tibble with NA
  if (nrow(filtered_data) == 0) {
    result <- tibble(
      Approach = approach_name,
      N_Studies = NA_integer_,
      N_estimates = NA_integer_,
      Delta = NA_real_,
      CI = NA_character_,
      p_val = NA_real_
    )
    if (second_p_value) {
      result <- result |> mutate(second_p_value = NA_real_)
    }
    return(result)
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
  p_val <- format(round(model$reg_table$prob, 4), scientific = FALSE)
  p_val <- sub("^0\\.", ".", p_val)  # Remove leading zero
  num_studies <- length(unique(model$X.full$study))  
  num_estimates <- nrow(model$data.full)  
  
  # Create the base tibble
  result <- tibble(
    Approach = approach_name,
    N_Studies = num_studies,
    N_estimates = num_estimates,  
    Delta = round(estimate, 3),  
    CI = paste0("[", round(ci_lower, 3), ", ", round(ci_upper, 3), "]"),
    p_val = p_val
  )
  
  # If second_p_value is TRUE, calculate and add the second p-value column
  if (second_p_value) {
    binary_variable <- ifelse(
      str_detect(data[[filter_column]], filter_string), 1, 0
    )
    
    # Run the meta-regression model with the binary variable
    mod_model <- robumeta::robu(
      formula = d ~ binary_variable,
      data = data,  
      studynum = unique_study_id,
      var.eff.size = var_d,
      modelweights = 'CORR',
      small = TRUE
    )
    
    # Extract the p-value for the moderator variable
    second_p_value_val <- format(round(mod_model$reg_table$prob[2], 4), 
                                 scientific = FALSE)
    second_p_value_val <- sub("^0\\.", ".", second_p_value_val)  # Remove leading zero
    
    # Add second p-value column
    result <- result |> mutate(second_p_value = second_p_value_val)
  }
  
  return(result)
}
