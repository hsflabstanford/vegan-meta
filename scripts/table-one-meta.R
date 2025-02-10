source('./scripts/load-data.R')
source('./scripts/functions.R')

meta_table <- bind_rows(
  run_subset_meta_analysis(data = dat, approach_name = "Overall", col_name = "Approach"),
  bind_rows(
    run_subset_meta_analysis(data = dat, filter_string = "Choice Architecture", 
                             filter_column = "theory", approach_name = "Choice Architecture",
                             col_name = "Approach"),
    run_subset_meta_analysis(data = dat, filter_string = "Psychology", 
                             filter_column = "theory", approach_name = "Psychology", 
                             col_name = "Approach"),
    run_subset_meta_analysis(data = dat, filter_string = "Persuasion", 
                             filter_column = "theory", approach_name = "Persuasion",
                             str_detect_flag = FALSE, col_name = "Approach"),
    run_subset_meta_analysis(data = dat, filter_string = "Persuasion & Psychology", 
                             filter_column = "theory", approach_name = "Persuasion \\& Psychology", 
                             col_name = "Approach")
  ),
  bind_rows(
    run_subset_meta_analysis(data = dat, filter_string = "animal", 
                             filter_column = "secondary_theory", approach_name = "Animal Welfare", 
                             col_name = "Approach"),
    run_subset_meta_analysis(data = dat, filter_string = "environment", 
                             filter_column = "secondary_theory", approach_name = "Environment", 
                             col_name = "Approach"),
    run_subset_meta_analysis(data = dat, filter_string = "health", 
                             filter_column = "secondary_theory", approach_name = "Health", 
                             col_name = "Approach")
  )
)

if (!word) {
  meta_table <- meta_table |>
    kbl(booktabs = TRUE, 
        col.names = c("Approach", "N (Studies)", "N (Estimates)", 
                      "Delta", "95\\% CIs", "p val"),
        caption = "Meta-analytic Results Overall and by Theoretical Approach", 
        align = 'l', label = "table_one", escape = FALSE) |>
    kable_styling(full_width = FALSE, latex_options = "hold_position") |>
    pack_rows(group_label = "Theory", start_row = 2, end_row = 5,  
              latex_gap_space = "0.5em", bold = TRUE) |>
    pack_rows(group_label = "Type of Persuasion", start_row = 6, end_row = 8,  
              latex_gap_space = "0.5em", bold = TRUE) |>
    add_footnote("Note that studies could occupy multiple categories for both theory and type of persuasion, that Ns for Types of Persuasion draw from both Persuasion and Persuasion and Psychology studies, and that some studies with multiple interventions are represented in multiple theoretical categories.",
                 notation = "none")
} else {
  # whole complicated thing here  to get a few bold words in their own columns
  # Convert numeric columns to character so binding with text rows works
  meta_table <- meta_table |>
    mutate(across(c(N_Studies, N_Estimates, Delta, CI, p_val), as.character))
  
  # Replace "Persuasion \\& Psychology" with "Persuasion & Psychology" in the Approach column
  meta_table <- meta_table |>
    mutate(Approach = gsub("\\\\&", "&", Approach))
  
  # Insert header rows:
  # - After row 1 (Overall), insert a row with "Theory"
  # - Before rows 6-8 (secondary group), insert a row with "Types of Persuasion"
  meta_table <- bind_rows(
    meta_table[1, ],
    tibble(Approach = "Theory", N_Studies = "", N_Estimates = "", Delta = "", CI = "", p_val = ""),
    meta_table[2:5, ],
    tibble(Approach = "Types of Persuasion", N_Studies = "", N_Estimates = "", Delta = "", CI = "", p_val = ""),
    meta_table[6:8, ]
  )
  
  # Build the flextable with custom header labels and caption
  meta_table <- meta_table |>
    flextable() |>
    set_caption("Table 1: Main Findings") |>
    set_header_labels(
      Approach    = "Approach",
      N_Studies   = "N (Studies)",
      N_Estimates = "N (Estimates)",
      Delta       = "Delta",
      CI          = "95% CIs",
      p_val       = "p val"
    ) |>
    theme_booktabs() |>
    align(j = 2:ncol(meta_table), align = "center") |>
    width(j = 1, width = 2.5) |>
    width(j = 2:ncol(meta_table), width = 1.2) |>
    autofit() |>
    add_footer_lines("Note that studies could occupy multiple categories for both theory and type of persuasion, that Ns for Types of Persuasion draw from both Persuasion and Persuasion and Psychology studies, and that some studies with multiple interventions are represented in multiple theoretical categories")
  
  # Bold the inserted header rows: row 2 ("Theory") and row 7 ("Types of Persuasion")
  meta_table <- meta_table |>
    bold(i = c(2, 7), j = 1, bold = TRUE, part = "body")
  
  meta_table
}
