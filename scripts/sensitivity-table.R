# Create the dataset with new reversed variables
dat <- dat |> 
  mutate(reversed_pap_var = if_else(public_pre_analysis_plan == 'N', 'N', 'Y'),
         reversed_open_data_var = if_else(open_data == 'N', 'N', 'Y'))

# Create the sensitivity table
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
  # Open science practices model results (this part was missing the pipe)
  bind_rows(
    open_science_results <- bind_rows(
      extract_model_results("Y", "reversed_pap_var", data = dat,
                            approach_name = "Pre-analysis plan", second_p_value = TRUE),
      extract_model_results("Y", "reversed_open_data_var", data = dat,
                            approach_name = "Publicly available data", second_p_value = TRUE)
    )
  ) |>
  
  # Create the table with kable and dynamic rows
  kbl(booktabs = TRUE, 
      col.names = c("Stucy Characteristic", "N (Studies)", "N (Estimates)", 
                    "Delta", "95% CIs", "p value", "p-value vs. ref. level"), 
      caption = "Sensitivity Analysis Results", 
      label = "table_three") |>
  
  # Dynamically calculate row indices based on the number of rows
  pack_rows(group_label = "Publication Status", 
            start_row = 1, 
            end_row = nrow(pub_status_model_results), 
            latex_gap_space = "0.5em", bold = TRUE) |>
  
  pack_rows(group_label = "Data collection strategy", 
            start_row = nrow(pub_status_model_results) + 1, 
            end_row = nrow(pub_status_model_results) + nrow(outcome_model_results), 
            latex_gap_space = "0.5em", bold = TRUE) |>
  
  pack_rows(group_label = "Open science practices",
            start_row = nrow(pub_status_model_results) + nrow(outcome_model_results) + 1,
            end_row = nrow(pub_status_model_results) + nrow(outcome_model_results) + nrow(open_science_results),
            latex_gap_space = "0.5em", bold = TRUE)
