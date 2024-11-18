# libraries
library(dplyr, warn.conflicts = F)
library(kableExtra, warn.conflicts = F)

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
                             col_name = "Approach")),
  bind_rows(
    run_subset_meta_analysis(data = dat, filter_string = "animal", 
                             filter_column = "secondary_theory", approach_name = "Animal Welfare", 
                             col_name = "Approach"),
    run_subset_meta_analysis(data = dat, filter_string = "environment", 
                             filter_column = "secondary_theory", approach_name = "Environment", 
                             col_name = "Approach"),
    run_subset_meta_analysis(data = dat, filter_string = "health", 
                             filter_column = "secondary_theory", approach_name = "Health", 
                             col_name = "Approach"))) |>
  kbl(booktabs = TRUE, 
      col.names = c("Approach", "N (Studies)", "N (Estimates)", 
                  "SMD", "95\\% CIs", "$p$ val"),
    caption = "Meta-analytic Results Overall and by Theoretical Approach", 
    align = 'l', label = "table_one", escape = FALSE) |>             
  kable_styling(full_width = FALSE, latex_options = "hold_position") |>
  pack_rows(group_label = "Theory",  start_row = 2,  end_row = 5,  
            latex_gap_space = "0.5em",bold = TRUE) |>
  pack_rows(group_label = "Type of Persuasion",  start_row = 6, end_row = 8,  
            latex_gap_space = "0.5em",  bold = TRUE) |> 
  add_footnote("Note that studies could occupy multiple categories for both theory and type of persuasion, that Ns for Types of Persuasion draws from both Persuasion and Persuasion and Psychology studies, and that some studies with multiple interventions are represented in multiple theoretical categories.",
               notation = "none")

