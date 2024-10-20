
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
    str_detect(country, regex("Iran|Thailand", ignore_case = TRUE)) ~ "Asia",
    str_detect(country, regex("Australia", ignore_case = TRUE)) ~ "Australia",
    TRUE ~ NA_character_),
  decade_group = case_when(
    decade == "2000s" ~ "2000s",
    decade == "2010s" ~ "2010s",
    decade == "2020s" ~ "2020s",
    TRUE ~ NA_character_),
  delivery_group = case_when(
    str_detect(delivery_method, regex("article|op-ed|leaflet|flyer|printed booklet|mailed|lecture", 
                                      ignore_case = TRUE)) ~ "Educational Materials",
    str_detect(delivery_method, regex("video", ignore_case = TRUE)) ~ "Video",
    str_detect(delivery_method, regex("in-cafeteria", ignore_case = TRUE)) ~ "In-cafeteria",
    str_detect(delivery_method, regex("online|internet|text|email", ignore_case = TRUE)) ~ "Online",
    str_detect(delivery_method, regex("dietary consultation", ignore_case = TRUE)) ~ "Dietary Consultation",
    str_detect(delivery_method, regex("free meat alternative", ignore_case = TRUE)) ~ "Free Meat Alternative",
    TRUE ~ NA_character_))

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
  
  # Check if there's sufficient data
  num_studies <- n_distinct(data_subset$unique_study_id)
  num_estimates <- nrow(data_subset)
  
  if (num_studies < 2) {
    # Not enough studies to run meta-analysis
    return(tibble(
      Moderator = level,
      N_Studies = num_studies,
      N_Estimates = num_estimates,
      Delta = NA_real_,
      CI = NA_character_,
      p_val = NA_character_
    ))
  }
  
  # Run meta-analysis
  model <- robumeta::robu(
    formula = d ~ 1,
    data = data_subset,
    studynum = data_subset$unique_study_id,
    var.eff.size = data_subset$var_d,
    modelweights = "CORR",
    small = TRUE
  )
  
  # Extract results
  estimate <- model$reg_table$b.r
  ci_lower <- model$reg_table$CI.L
  ci_upper <- model$reg_table$CI.U
  p_val <- formatC(model$reg_table$prob, format = "f", digits = 3)
  p_val <- sub("^0\\.", ".", p_val)  # Remove leading zero
  
  # Create result tibble
  tibble(
    Moderator = level,
    N_Studies = num_studies,
    N_Estimates = num_estimates,
    Delta = round(estimate, 2),
    CI = paste0("[", round(ci_lower, 2), ", ", round(ci_upper, 2), "]"),
    p_val = p_val
  )
}

# Define function to run meta-regression and extract second p-values
run_meta_regression <- function(data, group_var, ref_level) {
  # Filter out levels with insufficient data
  sufficient_levels <- data %>%
    group_by(!!sym(group_var)) %>%
    summarise(N_Studies = n_distinct(unique_study_id)) %>%
    filter(N_Studies >= 2) %>%
    pull(!!sym(group_var))
  
  # Subset data to only include sufficient levels
  data <- data %>% filter(!!sym(group_var) %in% sufficient_levels)
  
  # Ensure the grouping variable is a factor with the reference level first
  data <- data %>%
    mutate(
      group_var_factor = factor(!!sym(group_var), levels = c(ref_level, setdiff(sufficient_levels, ref_level)))
    )
  
  # Check if there's sufficient data for meta-regression
  if (length(unique(data$group_var_factor)) < 2) {
    # Not enough groups to run meta-regression
    return(setNames(rep(NA_character_, length(sufficient_levels)), sufficient_levels))
  }
  
  # Run meta-regression
  model <- robumeta::robu(
    formula = d ~ group_var_factor,
    data = data,
    studynum = data$unique_study_id,
    var.eff.size = data$var_d,
    modelweights = "CORR",
    small = TRUE
  )
  
  # Extract p-values
  coef_table <- model$reg_table
  p_values <- coef_table$prob
  names(p_values) <- rownames(coef_table)
  
  # Adjust names to match levels
  p_values <- p_values[-1]  # Exclude the intercept (reference level)
  level_names <- levels(data$group_var_factor)[-1]
  names(p_values) <- level_names
  
  # Format p-values
  p_values_formatted <- formatC(p_values, format = "f", digits = 3)
  p_values_formatted <- sub("^0\\.", ".", p_values_formatted)
  
  # Create a named vector of p-values, include NA for levels not in meta-regression
  p_values_named <- setNames(rep(NA_character_, length(sufficient_levels)), sufficient_levels)
  p_values_named[ref_level] <- "ref"
  p_values_named[level_names] <- p_values_formatted
  
  return(p_values_named)
}

# Function to process each group
process_group <- function(data, group_var, group_levels, ref_level, group_label) {
  # Run subset meta-analyses for each level
  group_results <- lapply(group_levels, function(level) {
    run_subset_meta_analysis(data, group_var, level)
  }) %>% bind_rows()
  
  # Identify levels with sufficient data
  sufficient_levels <- group_results %>% filter(!is.na(Delta)) %>% pull(Moderator)
  
  # Run meta-regression to get second p-values
  group_p_values <- run_meta_regression(data, group_var, ref_level)
  
  # Add the second p-values to the results
  group_results <- group_results %>%
    mutate(p_val_ref = group_p_values[Moderator],
           Group = group_label)
  
  # Reorder columns
  group_results <- group_results %>%
    select(Group, Moderator, N_Studies, N_Estimates, Delta, CI, p_val, p_val_ref)
  
  return(group_results)
}

# Process Population Group
population_levels <- c("University students and staff", "Adults", "Adolescents", "All ages")
ref_level_population <- "University students and staff"
population_results <- process_group(dat, "population_group", population_levels, ref_level_population, "Population")

# Process Region Group
region_levels <- c("North America", "Europe", "Multi-region", "Asia", "Australia")
ref_level_region <- "North America"
region_results <- process_group(dat, "region_group", region_levels, ref_level_region, "Region")

# Process Publication Decade Group
decade_levels <- c("2000s", "2010s", "2020s")
ref_level_decade <- "2000s"
decade_results <- process_group(dat, "decade_group", decade_levels, ref_level_decade, "Publication Decade")

# Process Delivery Methods Group
delivery_levels <- c("Educational Materials", "Video", "In-cafeteria", "Online", "Dietary Consultation", "Free Meat Alternative")
ref_level_delivery <- "Educational Materials"
delivery_results <- process_group(dat, "delivery_group", delivery_levels, ref_level_delivery, "Delivery Methods")

# Combine all results into a final table
moderator_table <- bind_rows(
  population_results,
  region_results,
  decade_results,
  delivery_results
)

# Remove entries with zero studies
moderator_table <- moderator_table %>% filter(N_Studies > 0)

# Order the table by Group and then by the order of levels defined
moderator_table <- moderator_table %>%
  mutate(
    Moderator = factor(Moderator, levels = c(population_levels, region_levels, decade_levels, delivery_levels)),
    Group = factor(Group, levels = c("Population", "Region", "Publication Decade", "Delivery Methods"))
  ) %>%
  arrange(Group, Moderator)

# Format the table
moderator_table %>%
  kbl(booktabs = TRUE,
      col.names = c("Group", "Moderator", "N (Studies)", "N (Estimates)",
                    "Delta", "95% CIs", "p value", "p-value vs. ref. level"),
      caption = "Moderator Analysis Results",
      label = "table_two") %>%
  kable_styling(full_width = FALSE) %>%
  pack_rows("Population", 1, nrow(population_results), bold = TRUE, italic = FALSE) %>%
  pack_rows("Region", (nrow(population_results) + 1), (nrow(population_results) + nrow(region_results)), bold = TRUE, italic = FALSE) %>%
  pack_rows("Publication Decade", (nrow(population_results) + nrow(region_results) + 1), (nrow(population_results) + nrow(region_results) + nrow(decade_results)), bold = TRUE, italic = FALSE) %>%
  pack_rows("Delivery Methods", (nrow(population_results) + nrow(region_results) + nrow(decade_results) + 1), nrow(moderator_table), bold = TRUE, italic = FALSE) %>%
  column_spec(1, bold = FALSE) %>%
  add_footnote("[insert great footnote]",
               notation = "none")
