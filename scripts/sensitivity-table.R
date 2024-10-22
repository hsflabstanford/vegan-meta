# -------------------------------
# 0. functions
# -------------------------------


#  function to run subset meta-analysis for a given level
run_subset_meta_analysis <- function(data, group_var, level) {
  # Subset data for the specific level
  data_subset <- data %>% filter(!!sym(group_var) == level)
  
  # Get number of studies and estimates
  num_studies <- n_distinct(data_subset$unique_study_id)
  num_estimates <- nrow(data_subset)
  
  if (num_studies < 1) {
    # No studies available
    return(tibble(
      Moderator = level,
      N_Studies = num_studies,
      N_Estimates = num_estimates,
      Delta = NA_real_,
      CI = NA_character_,
      p_val = NA_character_
    ))
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
    return(tibble(
      Moderator = level,
      N_Studies = num_studies,
      N_Estimates = num_estimates,
      Delta = NA_real_,
      CI = NA_character_,
      p_val = NA_character_
    ))
  }
  
  # Extract results
  estimate <- model$reg_table$b.r
  ci_lower <- model$reg_table$CI.L
  ci_upper <- model$reg_table$CI.U
  p_val <- formatC(model$reg_table$prob, format = "f", digits = 4)
  p_val <- sub("^0\\.", ".", p_val)  # Remove leading zero
  
  # Create result tibble
  tibble(
    Moderator = level,
    N_Studies = num_studies,
    N_Estimates = num_estimates,
    Delta = round(estimate, 3),
    CI = paste0("[", round(ci_lower, 3), ", ", round(ci_upper, 3), "]"),
    p_val = p_val
  )
}


# Define function to run meta-regression and extract second p-values
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
process_group <- function(data, group_var, group_levels, ref_level) {
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
# -------------------------------
# 1. Create Variables in 'dat'
# -------------------------------

dat <- dat |> 
  mutate(
    # Create 'pub_status' variable
    pub_group = case_when(
      str_detect(pub_status, regex("Advocacy Organization", ignore_case = TRUE)) ~ "Nonprofit white paper",
      str_detect(pub_status, regex("Journal article", ignore_case = TRUE)) ~ "Journal article",
      str_detect(pub_status, regex("Preprint|Thesis", ignore_case = TRUE)) ~ "Preprint or thesis",
      TRUE ~ NA_character_
    ),
    
    # Create 'open_science_group' variable
    open_science_group = case_when(
      public_pre_analysis_plan != 'N' & open_data == 'N' ~ "Pre-analysis plan only",
      public_pre_analysis_plan == 'N' & open_data != 'N' ~ "Open only",
      public_pre_analysis_plan != 'N' & open_data != 'N' ~ 'Pre-analysis plan and open data',
      TRUE ~ 'None'
    ),
    
    # Create 'data_collection_group' variable
    data_collection_group = case_when(
      self_report == 'Y' ~ 'Self-reported',
      self_report == 'N' ~ 'Objectively measured',
      TRUE ~ NA_character_
    )
  )

# -------------------------------
# 2. Process Each Sensitivity Analysis Group
# -------------------------------

## 2.1. Publication Status
pub_status_levels <- c("Journal article", "Nonprofit white paper", "Preprint or thesis")
ref_level_pub_status <- "Journal article"
pub_status_results <- process_group(dat, "pub_group", pub_status_levels, ref_level_pub_status)

## 2.2. Data Collection Strategy
data_collection_levels <- c("Self-reported", "Objectively measured")
ref_level_data_collection <- "Self-reported"
data_collection_results <- process_group(dat, "data_collection_group", data_collection_levels, ref_level_data_collection)

## 2.3. Open Science Practices
open_science_levels <- c("None", "Pre-analysis plan and/or open data")
ref_level_open_science <- "None"
open_science_results <- process_group(dat, "open_science_group", open_science_levels, ref_level_open_science)

# -------------------------------
# 3. Combine All Sensitivity Analysis Results
# -------------------------------

sensitivity_table <- bind_rows(
  pub_status_results,
  data_collection_results,
  open_science_results
)

# -------------------------------
# 4. Calculate Row Indices for Grouping
# -------------------------------

start_row_pub_status <- 1
end_row_pub_status <- start_row_pub_status + nrow(pub_status_results) - 1

start_row_data_collection <- end_row_pub_status + 1
end_row_data_collection <- start_row_data_collection + nrow(data_collection_results) - 1

start_row_open_science <- end_row_data_collection + 1
end_row_open_science <- start_row_open_science + nrow(open_science_results) - 1

# -------------------------------
# 5. Format the Sensitivity Analysis Table
# -------------------------------

sensitivity_table <- sensitivity_table |>
  kbl(
    booktabs = TRUE,
    col.names = c("Study Characteristic", "N (Studies)", "N (Estimates)", 
                  "$\\Delta$", "95\\% CIs", "Subset p-value", "Moderator p-value"), 
    caption = "Sensitivity Analysis Results", 
    label = "table_three", 
    escape = FALSE
  ) |>
  kable_styling(full_width = FALSE) |>
  pack_rows("Publication Status", start_row_pub_status, end_row_pub_status, bold = TRUE, italic = FALSE) |>
  pack_rows("Data Collection Strategy", start_row_data_collection, end_row_data_collection, bold = TRUE, italic = FALSE) |>
  pack_rows("Open Science", start_row_open_science, end_row_open_science, bold = TRUE, italic = FALSE) |>
  add_footnote(
    "[INSERT REALLY GOOD FOOTNOTE]",
    notation = "none"
  )
