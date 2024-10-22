# Function to run subset meta-analysis for a given level
run_subset_meta_analysis <- function(data, group_var = NULL, level = NULL, 
                                     filter_string = NULL, filter_column = NULL, 
                                     str_detect_flag = TRUE, approach_name = NULL,
                                     col_name = "Moderator") {
  # Handle filtering
  if (!is.null(filter_column) && !is.null(filter_string)) {
    if (str_detect_flag) {
      data_subset <- data %>% filter(str_detect(!!sym(filter_column), filter_string))
    } else {
      data_subset <- data %>% filter(!!sym(filter_column) == filter_string)
    }
    Moderator <- ifelse(is.null(approach_name), filter_string, approach_name)
  } else if (!is.null(group_var) && !is.null(level)) {
    data_subset <- data %>% filter(!!sym(group_var) == level)
    Moderator <- level
  } else {
    data_subset <- data
    Moderator <- ifelse(is.null(approach_name), "Overall", approach_name)
  }
  
  # Get number of studies and estimates
  num_studies <- n_distinct(data_subset$unique_study_id)
  num_estimates <- nrow(data_subset)
  
  if (num_studies < 1) {
    # No studies available
    result <- tibble(
      !!col_name := Moderator,
      N_Studies = num_studies,
      N_Estimates = num_estimates,
      Delta = NA_real_,
      CI = NA_character_,
      p_val = NA_character_
    )
    return(result)
  }
  
  # Run meta-analysis (even with 1 study)
  model <- tryCatch({
    robumeta::robu(
      formula = d ~ 1,
      data = data_subset,
      studynum = data_subset$unique_study_id,
      var.eff.size = data_subset$var_d,
      modelweights = "CORR",
      small = TRUE
    )
  }, error = function(e) {
    return(NULL)
  })
  
  if (is.null(model)) {
    result <- tibble(
      !!col_name := Moderator,
      N_Studies = num_studies,
      N_Estimates = num_estimates,
      Delta = NA_real_,
      CI = NA_character_,
      p_val = NA_character_
    )
    return(result)
  }
  
  # Extract results
  estimate <- model$reg_table$b.r
  ci_lower <- model$reg_table$CI.L
  ci_upper <- model$reg_table$CI.U
  p_val <- format(round(model$reg_table$prob, 3), scientific = FALSE)
  p_val <- sub("^0\\.", ".", p_val)  # Remove leading zero
  
  # Create result tibble
  result <- tibble(
    !!col_name := Moderator,
    N_Studies = num_studies,
    N_Estimates = num_estimates,
    Delta = round(estimate, 2),
    CI = paste0("[", round(ci_lower, 2), ", ", round(ci_upper, 2), "]"),
    p_val = p_val
  )
  
  return(result)
}

# Function to run meta-regression and extract second p-values
run_meta_regression <- function(data, group_var, ref_level) {
  # Include all levels with at least one study
  sufficient_levels <- data |>
    group_by(!!sym(group_var)) |>
    summarise(N_Studies = n_distinct(unique_study_id)) |>
    filter(N_Studies >= 1) |>
    pull(!!sym(group_var))
  
  # Subset data to include all sufficient levels
  data <- data |> filter(!!sym(group_var) %in% sufficient_levels)
  
  # Ensure the grouping variable is a factor with the reference level first
  data <- data |>
    mutate(
      group_var_factor = factor(!!sym(group_var), levels = c(ref_level, setdiff(sufficient_levels, ref_level)))
    )
  
  # Check if there are at least two levels to run meta-regression
  if (length(unique(data$group_var_factor)) < 2) {
    # Not enough groups to run meta-regression
    p_values_named <- setNames(rep(NA_character_, length(sufficient_levels)), sufficient_levels)
    p_values_named[ref_level] <- "ref"
    return(p_values_named)
  }
  
  # Run meta-regression
  model <- tryCatch({
    robumeta::robu(
      formula = d ~ group_var_factor,
      data = data,
      studynum = data$unique_study_id,
      var.eff.size = data$var_d,
      modelweights = "CORR",
      small = TRUE
    )
  }, error = function(e) {
    # Handle error in meta-regression
    p_values_named <- setNames(rep(NA_character_, length(sufficient_levels)), sufficient_levels)
    p_values_named[ref_level] <- "ref"
    return(p_values_named)
  })
  
  # Extract p-values
  coef_table <- model$reg_table
  p_values <- coef_table$prob
  names(p_values) <- rownames(coef_table)
  
  # Adjust names to match levels
  p_values <- p_values[-1]  # Exclude the intercept (reference level)
  level_names <- levels(data$group_var_factor)[-1]
  names(p_values) <- level_names
  
  # Format p-values
  p_values_formatted <- formatC(p_values, format = "f", digits = 4)
  p_values_formatted <- sub("^0\\.", ".", p_values_formatted)
  
  # Create a named vector of p-values, include NA for levels not in meta-regression
  p_values_named <- setNames(rep(NA_character_, length(sufficient_levels)), sufficient_levels)
  p_values_named[ref_level] <- "ref"
  p_values_named[level_names] <- p_values_formatted
  
  return(p_values_named)
}

# Function to process each group
process_group <- function(data, group_var, ref_level) {
  # Automatically determine group levels present in data
  group_levels <- data |>
    filter(!is.na(!!sym(group_var))) |>
    pull(!!sym(group_var)) |>
    unique()
  
  # Ensure the reference level is first
  group_levels <- c(ref_level, setdiff(group_levels, ref_level))
  
  # Run subset meta-analyses for each level
  group_results <- lapply(group_levels, function(level) {
    run_subset_meta_analysis(data, group_var, level)
  }) |> bind_rows()
  
  # Identify levels with sufficient data
  sufficient_levels <- group_results |> filter(!is.na(Delta)) |> pull(Moderator)
  
  # Run meta-regression to get second p-values
  group_p_values <- run_meta_regression(data, group_var, ref_level)
  
  # Add the second p-values to the results and make 'ref' bold
  group_results <- group_results |>
    mutate(
      p_val_ref = group_p_values[Moderator],
      p_val_ref = ifelse(
        p_val_ref == "ref",
        cell_spec(p_val_ref, bold = TRUE),
        p_val_ref
      )
    )
  
  # Reorder columns without 'Group'
  group_results <- group_results |>
    select(Moderator, N_Studies, N_Estimates, Delta, CI, p_val, p_val_ref)
  
  return(group_results)
}

