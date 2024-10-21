
# Create all moderator variables in one mutate call
dat <- dat |> mutate(
  population_group = case_when(
    str_detect(population, regex("university", ignore_case = TRUE)) ~ "University students and staff",
    str_detect(population, regex("adult", ignore_case = TRUE)) ~ "Adults",
    str_detect(population, regex("young", ignore_case = TRUE)) ~ "Adolescents",
    str_detect(population, regex("all ages", ignore_case = TRUE)) ~ "All ages",
    TRUE ~ NA_character_),
  region_group = case_when(
    str_detect(country, regex("United States|Canada", ignore_case = TRUE)) ~ "North America",
    str_detect(country, regex("United Kingdom|Denmark|Germany|Italy|Netherlands|Sweden", ignore_case = TRUE)) ~ "Europe",
    str_detect(country, regex("worldwide|United States, United Kingdom, Canada, Australia, and other", ignore_case = TRUE)) ~ "Multi-region",
    str_detect(country, regex("Iran|Thailand", ignore_case = TRUE)) ~ "Asia + Australia",
    country == 'Asia' ~ "Asia + Australia",
    TRUE ~ NA_character_),
  decade_group = case_when(
    decade == "2000s" ~ "2000s",
    decade == "2010s" ~ "2010s",
    decade == "2020s" ~ "2020s",
    TRUE ~ NA_character_),
  delivery_group = case_when(
    str_detect(delivery_method, regex("article|op-ed|leaflet|flyer|printed booklet|mailed|lecture", 
                                      ignore_case = TRUE)) ~ "Educational materials",
    str_detect(delivery_method, regex("video", ignore_case = TRUE)) ~ "Video",
    str_detect(delivery_method, regex("in-cafeteria", ignore_case = TRUE)) ~ "In-cafeteria",
    str_detect(delivery_method, regex("online|internet|text|email", ignore_case = TRUE)) ~ "Online",
    str_detect(delivery_method, regex("dietary consultation", ignore_case = TRUE)) ~ "Dietary consultation",    TRUE ~ NA_character_))


# Check for unmatched data in the new variables and throw an error if found

# Population Group Check
if (any(is.na(dat$population_group))) {
  unmatched_rows <- which(is.na(dat$population_group))
  stop("Error: Some entries in 'population' could not be classified into 'population_group'. Unmatched rows: ", paste(unmatched_rows, collapse = ", "))
} # and so on for different categories

# Define function to run subset meta-analysis for a given level
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

# Process Population Group
population_levels <- c("University students and staff", "Adults", "Adolescents", "All ages")
ref_level_population <- "University students and staff"
population_results <- process_group(dat, "population_group", population_levels, ref_level_population)

# Process Region Group
region_levels <- c("North America", "Europe", "Multi-region", "Asia + Australia")
ref_level_region <- "North America"
region_results <- process_group(dat, "region_group", region_levels, ref_level_region)

# Process Publication Decade Group
decade_levels <- c("2000s", "2010s", "2020s")
ref_level_decade <- "2000s"
decade_results <- process_group(dat, "decade_group", decade_levels, ref_level_decade)

# Process Delivery Methods Group
delivery_levels <- c("Educational materials", "Video", "In-cafeteria", "Online", "Dietary consultation")
ref_level_delivery <- "Educational materials"
delivery_results <- process_group(dat, "delivery_group", delivery_levels, ref_level_delivery)

moderator_table <- bind_rows(
  population_results,
  region_results,
  decade_results,
  delivery_results
)
# Remove entries with zero studies
moderator_table <- moderator_table |> filter(N_Studies > 0)

# Calculate the starting and ending row indices for each group
start_row_population <- 1
end_row_population <- nrow(population_results)
start_row_region <- end_row_population + 1
end_row_region <- start_row_region + nrow(region_results) - 1
start_row_decade <- end_row_region + 1
end_row_decade <- start_row_decade + nrow(decade_results) - 1
start_row_delivery <- end_row_decade + 1
end_row_delivery <- start_row_delivery + nrow(delivery_results) - 1

# Order the table by Group and then by the order of levels defined
# moderator_table <- moderator_table |>
#   mutate(
#     Moderator = factor(Moderator, levels = c(population_levels, region_levels, decade_levels, delivery_levels)),
#     Group = factor(Group, levels = c("Population", "Region", "Publication Decade", "Delivery Methods"))
#   ) |>
#   arrange(Group, Moderator)

# Format the table
revised_moderator_table <- moderator_table |>
  kbl(booktabs = TRUE, 
      col.names = c("Stucy Characteristic", "N (Studies)", "N (Estimates)", 
                    "Delta", "95\\% CIs", "subset p value", "moderator p value"), 
      caption = "Moderator Analysis Results", label = "table_two", escape = FALSE) |>
  kable_styling(full_width = FALSE) |>
  pack_rows("Population", start_row_population, end_row_population, bold = TRUE, italic = FALSE)|>
  pack_rows("Region", start_row_region, end_row_region, bold = TRUE, italic = FALSE) |>
  pack_rows("Publication Decade", start_row_decade, end_row_decade, bold = TRUE, italic = FALSE) |>
   pack_rows("Delivery Methods", start_row_delivery, end_row_delivery, bold = TRUE, italic = FALSE) |>
  add_footnote(
    "[a really good foontote]",
    notation = "none"
  )


