# -------------------------------
# 1. Create Variables in 'dat'
# -------------------------------

dat <- dat |> 
  mutate(
    # Create 'pub_group' variable
    pub_group = case_when(
      str_detect(pub_status, regex("Advocacy Organization", ignore_case = TRUE)) ~ "Nonprofit white paper",
      str_detect(pub_status, regex("Journal article", ignore_case = TRUE)) ~ "Journal article",
      str_detect(pub_status, regex("Preprint|Thesis", ignore_case = TRUE)) ~ "Preprint or thesis",
      TRUE ~ NA_character_
    ),
    
    # Create 'open_science_group' variable
    open_science_group = case_when(
      public_pre_analysis_plan == 'N' & open_data == 'N' ~ "None",
      public_pre_analysis_plan != 'N' & open_data == 'N' ~ "Pre-analysis plan only",
      public_pre_analysis_plan == 'N' & open_data != 'N' ~ "Open data only",
      public_pre_analysis_plan != 'N' & open_data != 'N' ~ "Pre-analysis plan \\& open data"),
    
    # Create 'data_collection_group' variable
    data_collection_group = case_when(
      self_report == 'Y' ~ 'Self-reported',
      self_report == 'N' ~ 'Objectively measured',
      TRUE ~ NA_character_
    )) 

# -------------------------------
# 2. Process Each Sensitivity Analysis Group
# -------------------------------

# 2.1. Publication Status
pub_status_results <- process_group(dat, "pub_group", ref_level = "Journal article")

# 2.2. Data Collection Strategy
data_collection_results <- process_group(dat, "data_collection_group", ref_level = "Self-reported")

# 2.3. Open Science Practices
open_science_results <- process_group(dat, "open_science_group", ref_level = "None", 
  order_levels = c("None", "Pre-analysis plan only", "Open data only", "Pre-analysis plan \\& open data"))


# -------------------------------
# 3. Calculate Row Indices for Grouping
# -------------------------------

start_row_pub_status <- 1
end_row_pub_status <- start_row_pub_status + nrow(pub_status_results) - 1

start_row_data_collection <- end_row_pub_status + 1
end_row_data_collection <- start_row_data_collection + nrow(data_collection_results) - 1

start_row_open_science <- end_row_data_collection + 1
end_row_open_science <- start_row_open_science + nrow(open_science_results) - 1

# -------------------------------
# 4. Combine sensitivity analyses and format for publication
# -------------------------------

sensitivity_table <- bind_rows(
  pub_status_results,
  data_collection_results,
  open_science_results) |>
  kbl(
    booktabs = TRUE,
    col.names = c("Study Characteristic", "N (Studies)", "N (Estimates)", 
                  "SMD", "95\\% CIs", 
                  "\\shortstack{Subset \\\\ $p$ value}", 
                  "\\shortstack{Moderator \\\\ $p$ value}"), 
    caption = "Table S1: Sensitivity Analysis Results", 
    label = "table_S1",
    align = "l",
    escape = FALSE) |>
  kable_styling(full_width = FALSE, latex_options = "hold_position") |>
  pack_rows("Publication Status", start_row_pub_status, end_row_pub_status, bold = TRUE, italic = FALSE) |>
  pack_rows("Data Collection Strategy", start_row_data_collection, end_row_data_collection, bold = TRUE, italic = FALSE) |>
  pack_rows("Open Science", start_row_open_science, end_row_open_science, bold = TRUE, italic = FALSE) |>
  add_footnote("Sensitivity analyses by publication status, data collection strategy, and open science practices.", 
               notation = "none")
