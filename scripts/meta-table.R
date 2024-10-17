meta_table <- bind_rows(
  # Overall row
  extract_model_results(approach_name = "Overall"),
  
  # Theory-specific results with proper Approach names
  bind_rows(
    extract_model_results("Choice Architecture", "theory", data = dat, 
                          approach_name = "Choice Architecture"),
    extract_model_results("Psychology", "theory", data = dat, 
                          approach_name = "Psychology"),
    extract_model_results("Persuasion", "theory", FALSE, data = dat, 
                          approach_name = "Persuasion"),
    extract_model_results("Persuasion & Psychology", "theory", data = dat, 
                          approach_name = "Persuasion & Psychology")
  ),
  
  # Type of Persuasion-specific results with proper Approach names
  bind_rows(
    extract_model_results("animal", "secondary_theory", data = dat, 
                          approach_name = "Animal Welfare"),
    extract_model_results("environment", "secondary_theory", data = dat, 
                          approach_name = "Environment"),
    extract_model_results("health", "secondary_theory", data = dat, 
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
