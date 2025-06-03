# -------------------------------
# 0. libraries, data and functions
# -------------------------------
library(dplyr, warn.conflicts = F)
library(flextable, warn.conflicts = F)
source('./scripts/load-data.R')
source('./scripts/functions.R')

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
      public_pre_analysis_plan != 'N' & open_data != 'N' ~ "Pre-analysis plan & open data"),
    
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
                                      order_levels = c("None", "Pre-analysis plan only", "Open data only", "Pre-analysis plan & open data"))

# -------------------------------
# 3. Combine and format for Word output
# -------------------------------

sensitivity_table <- bind_rows(
  pub_status_results,
  data_collection_results,
  open_science_results)

# Convert numeric columns to character so binding with text rows works
sensitivity_table <- sensitivity_table |>
  mutate(across(c(N_Studies, N_Estimates, Delta, CI, p_val, p_val_ref), as.character))

# Insert header rows
sensitivity_table <- bind_rows(
  tibble(Moderator = "Publication Status", N_Studies = "", N_Estimates = "", Delta = "", CI = "", p_val = "", p_val_ref = ""),
  sensitivity_table[1:3, ],
  tibble(Moderator = "Data Collection Strategy", N_Studies = "", N_Estimates = "", Delta = "", CI = "", p_val = "", p_val_ref = ""),
  sensitivity_table[4:5, ],
  tibble(Moderator = "Open Science", N_Studies = "", N_Estimates = "", Delta = "", CI = "", p_val = "", p_val_ref = ""),
  sensitivity_table[6:9, ]
)

# Build the flextable
sensitivity_table <- sensitivity_table |>
  mutate(
    p_val = ifelse(grepl("ref", p_val, ignore.case = TRUE), "ref", p_val),
    p_val_ref = ifelse(grepl("ref", p_val_ref, ignore.case = TRUE), "ref", p_val_ref)) |>
  flextable() |>
  set_caption("Table S1: Sensitivity Analysis Results") |>
  set_header_labels(
    Moderator = "Study Characteristic",
    N_Studies = "N (Studies)",
    N_Estimates = "N (Estimates)",
    Delta = "SMD",
    CI = "95% CIs",
    p_val = "Subset p value",
    p_val_ref = "Moderator p value") |>
    theme_booktabs() |>
    bold(i = which(sensitivity_table$p_val == "ref"), j = "p_val", bold = TRUE, part = "body") |>
    bold(i = which(sensitivity_table$p_val_ref == "ref"), j = "p_val_ref", bold = TRUE, part = "body") |> 
    align(j = 2:ncol(sensitivity_table), align = "center") |>
    autofit() |>
    add_footer_lines("Sensitivity analyses. The first p value tests the hypothesis that the subset of studies with a given characteristic is significantly different from an SMD of zero. The second compares effects within a given category to the reference category for that moderator.") |>
    bold(i = c(1, 5, 8), j = 1, bold = TRUE, part = "body")

sensitivity_table
