# Table 1
meta_table <- bind_rows(
  extract_model_results(approach_name = "Overall"),
  bind_rows(
    extract_model_results("Choice Architecture", "theory"),
    extract_model_results("Persuasion", "theory", FALSE),
    extract_model_results("Psychology", "theory", FALSE),
    extract_model_results("Persuasion & Psychology", "theory")
  ),
  bind_rows(
    extract_model_results("animal", "secondary_theory"),
    extract_model_results("environment", "secondary_theory"),
    extract_model_results("health", "secondary_theory")
  )
) |>
  kbl(booktabs = TRUE, col.names = c("Approach", "N (Studies)", "N (Interventions)", 
                                     "Delta", "95% CIs", "p value"), 
      caption = "Meta-Analysis Results", 
      label = "table_one") |>
  kable_styling(latex_options = c("striped", "hold_position", "scale_down"), font_size = 10) |>
  pack_rows(group_label = "Theory", start_row = 2, 
            end_row = 5, latex_gap_space = "0.5em", bold = TRUE) |>
  pack_rows(group_label = "Type of Persuasion", 
            start_row = 6, 
            end_row = 8, 
            latex_gap_space = "0.5em", bold = TRUE) |>
  row_spec(0, bold = TRUE, font_size = 12)

