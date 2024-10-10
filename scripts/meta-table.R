source('./scripts/models.R')
# models calls robumeta::robu() a bunch of times
theory_part <- bind_rows(
  choice_results, persuasion_results,
  psychology_results, persuasion_psych_results)

persuasion_part <- bind_rows(
  animal_results, environment_results, health_results)

meta_table <- bind_rows(
  overall_results,
  theory_part,
  persuasion_part
) |>
  kbl(booktabs = TRUE, col.names = c("Approach", "N (Studies)", "N (Interventions)", "Delta", "95% CIs", "p value")) |>
  kable_styling(latex_options = c("striped", "hold_position", "scale_down"), 
                font_size = 10) |>
  pack_rows(group_label = "Theory", start_row = 2, 
            end_row = 1 + nrow(theory_part), latex_gap_space = "0.5em", bold = TRUE) |>
  pack_rows(group_label = "Type of Persuasion", 
            start_row = 2 + nrow(theory_part), 
            end_row = 1 + nrow(theory_part) + nrow(persuasion_part), 
            latex_gap_space = "0.5em", bold = TRUE) |>
  row_spec(0, bold = TRUE, font_size = 12)