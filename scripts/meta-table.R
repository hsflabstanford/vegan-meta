meta_table <- bind_rows(
  # Overall row
  table_one_function(approach_name = "Overall", data = dat),
  
  # Theory-specific results with proper Approach names
  bind_rows(
    table_one_function("Choice Architecture", "theory", data = dat, 
                       approach_name = "Choice Architecture"),
    table_one_function("Psychology", "theory", data = dat, 
                       approach_name = "Psychology"),
    table_one_function("Persuasion", "theory", str_detect_flag = FALSE, data = dat, 
                       approach_name = "Persuasion"),
    table_one_function("Persuasion & Psychology", "theory", data = dat, 
                       approach_name = "Persuasion & Psychology")
  ),
  
  # Type of Persuasion-specific results with proper Approach names
  bind_rows(
    table_one_function("animal", "secondary_theory", data = dat, 
                       approach_name = "Animal Welfare"),
    table_one_function("environment", "secondary_theory", data = dat, 
                       approach_name = "Environment"),
    table_one_function("health", "secondary_theory", data = dat, 
                       approach_name = "Health")
  )
) |>
  kbl(booktabs = TRUE, 
      col.names = c("Approach", "N (Studies)", "N (Estimates)", 
                    "Delta", "95% CIs", "p value"), 
      caption = "Meta-Analysis Results", 
      label = "table_one")  |>
  pack_rows(group_label = "Theory", start_row = 2, 
            end_row = 5, latex_gap_space = "0.5em", bold = TRUE) |>
  pack_rows(group_label = "Type of Persuasion", 
            start_row = 6, end_row = 8, latex_gap_space = "0.5em", bold = TRUE) |> 
  add_footnote("Types of persuasion Ns will not total to the Ns for persuasion overall because many studies employ multiple categories of argument.",
               notation = "none")
