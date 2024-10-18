# Sensitivity analysis table
sensitivity_table <- bind_rows(
  # Publication status model results
  pub_status_model_results <- bind_rows(
    extract_model_results("Advocacy Organization", "pub_status", data = dat, 
                          approach_name = "Nonprofit white paper", second_p_value = TRUE),
    extract_model_results("Journal article", "pub_status", data = dat, 
                          approach_name = "Journal article", second_p_value = TRUE),
    extract_model_results("Preprint|Thesis", "pub_status", data = dat, 
                          approach_name = "Preprint or Thesis", second_p_value = TRUE)
  ),
  
  # Outcome recording model results
  outcome_model_results <- bind_rows(
    extract_model_results("Y", "self_report", data = dat, 
                          approach_name = "Self reported", second_p_value = TRUE),
    extract_model_results("N", "self_report", data = dat, 
                          approach_name = "Objectively measured", second_p_value = TRUE)
  )
) |> 
  kbl(booktabs = TRUE, 
      col.names = c("Moderator", "N (Studies)", "N (Estimates)", 
                    "Delta", "95% CIs", "p value", "second p value"), 
      caption = "Sensitivity Analysis Results", 
      label = "table_three") |>
  
  # Dynamically calculate row indices based on the number of rows
  pack_rows(group_label = "Publication Status", 
            start_row = 1, 
            end_row = nrow(pub_status_model_results), 
            latex_gap_space = "0.5em", bold = TRUE) |>
  
  pack_rows(group_label = "Outcome Recording", 
            start_row = nrow(pub_status_model_results) + 1, 
            end_row = nrow(pub_status_model_results) + nrow(outcome_model_results), 
            latex_gap_space = "0.5em", bold = TRUE) |>
  add_footnote("This table presents results from the sensitivity analysis, focusing on publication status and outcome recording.", 
               notation = "none")
