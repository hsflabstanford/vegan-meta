meta_table <- bind_rows(
  # Overall row
  run_subset_meta_analysis(data = dat, approach_name = "Overall", col_name = "Approach"),
  
  # Theory-specific results with proper Approach names
  bind_rows(
    run_subset_meta_analysis(data = dat, filter_string = "Choice Architecture", 
                             filter_column = "theory", approach_name = "Choice Architecture", col_name = "Approach"),
    run_subset_meta_analysis(data = dat, filter_string = "Psychology", 
                             filter_column = "theory", approach_name = "Psychology", col_name = "Approach"),
    run_subset_meta_analysis(data = dat, filter_string = "Persuasion", 
                             filter_column = "theory", approach_name = "Persuasion",
                             str_detect_flag = FALSE, col_name = "Approach"),
    run_subset_meta_analysis(data = dat, filter_string = "Persuasion & Psychology", 
                             filter_column = "theory", approach_name = "Persuasion \\& Psychology", col_name = "Approach")),

  # Type of Persuasion-specific results with proper Approach names
  bind_rows(
    run_subset_meta_analysis(data = dat, filter_string = "animal", 
                             filter_column = "secondary_theory", approach_name = "Animal Welfare", col_name = "Approach"),
    run_subset_meta_analysis(data = dat, filter_string = "environment", 
                             filter_column = "secondary_theory", approach_name = "Environment", col_name = "Approach"),
    run_subset_meta_analysis(data = dat, filter_string = "health", 
                             filter_column = "secondary_theory", approach_name = "Health", col_name = "Approach"))) |>
  kbl(
    booktabs = TRUE, 
    col.names = c("Approach", "N (Studies)", "N (Estimates)", 
                  "SMD", "95\\% CIs", "p val"),
    caption = "Theory-based Meta-analytic Results", 
    align = 'l',
    label = "table_one", escape = FALSE) |>             
  kable_styling(full_width = FALSE, latex_options = "hold_position") |>
  # Group Rows
  pack_rows(
    group_label = "Theory", 
    start_row = 2, 
    end_row = 5, 
    latex_gap_space = "0.5em", 
    bold = TRUE) |>
  pack_rows(
    group_label = "Type of Persuasion", 
    start_row = 6, 
    end_row = 8, 
    latex_gap_space = "0.5em", 
    bold = TRUE) |> 
  # Add Footnote
  add_footnote(
    "Types of persuasion Ns will not total to the Ns for persuasion overall because many studies employ multiple categories of argument.",
    notation = "none")

