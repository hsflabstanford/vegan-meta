count_and_robust <- function(data) {
  # Get the study count
  study_count_data <- study_count(data)
  
  # Perform the robust analysis
  robust_data <- map_robust(data)
  
  # Check if 'N_unique' column exists in robust_data and remove it if present
  if ("N_unique" %in% names(robust_data)) {
    robust_data <- robust_data %>% dplyr::select(-N_unique)
  }
  
  # Bind the columns together
  result <- bind_cols(study_count_data, robust_data)
  
  return(result)
}
