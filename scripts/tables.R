#' overall results by theory
# Filter the data for each theory/approach, apply count_and_robust, and then combine
all_results <- bind_rows(
  dat |> filter(str_detect(theory, "norms")) |> count_and_robust() |> mutate(Approach = "Norms"),
  dat |> filter(str_detect(theory, "nudge")) |> count_and_robust() |> mutate(Approach = "Nudge"),
  dat |> filter(str_detect(secondary_theory, "health")) |> count_and_robust() |> mutate(Approach = "Health"),
  dat |> filter(str_detect(secondary_theory, "environment")) |> count_and_robust() |> mutate(Approach = "Environment"),
  dat |> filter(str_detect(secondary_theory, "animal welfare")) |> count_and_robust() |> mutate(Approach = "Animal Welfare"),
  dat |> filter(str_detect(theory, "persuasion")) |> count_and_robust() |> mutate(Approach = "Persuasion")
) |> mutate(pval = as.numeric(pval)) |> 
  select(Approach, N_unique, everything()); all_results

# Format for gt table
all_results_formatted <- all_results |>
  mutate(
    `Glass's ∆ (se)` = sprintf("%.3f%s (%.3f)", Delta, get_significance_stars(pval), se)
  ) |>
  select(Approach, N_unique, `Glass's ∆ (se)`)

all_results_formatted

all_results_gt_table <- all_results_formatted |>
  gt() |>
  tab_header(
    title = "Summary of Results by Theory",
    subtitle = "Comparing Effect Sizes Across Different Theories"
  ) |>
  cols_label(
    Approach = "Theory",
    N_unique = "N (Studies)",
    `Glass's ∆ (se)` = "Glass's ∆ (se)"
  ) |>
  tab_source_note(
    source_note = "* < 0.05, ** < 0.01, *** < 0.001. Note that because many studies present overlapping approaches, the numbers in this table do not sum to the total number of studies in our sample."
  )

# overall results by delivery method
delivery_method_results <- bind_rows(
  dat |> filter(str_detect(internet, "Y")) |> count_and_robust() |> mutate(DeliveryMethod = "Internet"),
  dat |> filter(str_detect(leaflet, "Y")) |> count_and_robust() |> mutate(DeliveryMethod = "Pamphlet"),
  dat |> filter(str_detect(video, "Y")) |> count_and_robust() |> mutate(DeliveryMethod = "Video"),
  dat |> filter(cafeteria_or_restaurant_based == "Y") |> count_and_robust() |> mutate(DeliveryMethod = "Place-Based"),
  dat |> filter(cafeteria_or_restaurant_based == 'N' &
                  !str_detect(video, "Y") &
                  !str_detect(leaflet, "Y") &
                  !str_detect(internet, "Y")) |> count_and_robust() |>
    mutate(DeliveryMethod = "Everything else")) |> 
  mutate(pval = as.numeric(pval)) |> 
  mutate(delta_se = sprintf("%.3f%s (%.3f)", Delta, get_significance_stars(pval), se)) |>
  select(DeliveryMethod, N_unique, delta_se); delivery_method_results

delivery_method_gt_table <- delivery_method_results |>
  gt() |>
  tab_header(
    title = "Summary of Results by Delivery Method",
    subtitle = "Comparing Effect Sizes Across Different Delivery Methods"
  ) |>
  cols_label(
    DeliveryMethod = "Delivery Method",
    N_unique = "N (Studies)",
    delta_se = "Glass's ∆ (se)"
  ) |>
  tab_source_note(
    source_note = "* < 0.05, ** < 0.01, *** < 0.001."
  )

# advocacy org tables
# check orgs
dat |> filter(advocacy_org != 'N') |> 
  select(author, year, theory, secondary_theory, advocacy_org)
advocacy_results <- dat |>
  mutate(advocacy_materials = if_else(advocacy_org == "N", 
                                      "Researcher materials", 
                                      "Advocacy organization materials")) |>
  split(~advocacy_materials) |>
  map(count_and_robust) |>
  bind_rows(.id = "Intervention_type") |> 
  mutate(pval = as.numeric(pval)); advocacy_results

advocacy_org_specific_table <- dat |>
  split(~advocacy_org) |>
  map(count_and_robust) |>
  bind_rows(.id = "advocacy_org") |>
  arrange(desc(N_unique)) |>
  mutate(pval = as.numeric(pval)) |> 
  mutate(advocacy_org = if_else(advocacy_org == "N", 
                                "Researchers (non-advocacy)", 
                                advocacy_org),
         stars = get_significance_stars(pval),
         delta_se = sprintf("%.3f%s (%.3f)", Delta, stars, se)) |>
  select(advocacy_org, N_unique, delta_se) |> 
  gt() |> 
  tab_header(
    title = "Results by Animal Advocacy Organization") |>
  cols_label(
    advocacy_org = "Advocacy Organization",
    N_unique = "N (Studies)",
    delta_se = "Glass's ∆ (se)"
  ) |>
  tab_source_note(
    source_note = "* < 0.05, ** < 0.01, *** < 0.001."
  )

# results by country 
country_results_table <- dat |> split(~country) |> 
  map(count_and_robust) |> 
  bind_rows(.id = "country") |> 
  arrange(desc(N_unique)) |>
  mutate(pval = as.numeric(pval)) |> 
  mutate(country = if_else(country == "United States, United Kingdom, Canada, Australia, and other", "US, UK, Canada, Australia, and other", country),
         delta_se = sprintf("%.3f%s (%.3f)", Delta, get_significance_stars(pval), se)) |> select(country, N_unique, delta_se) |>
  gt() |>
  tab_header(
    title = "Effect sizes by country") |>
  cols_label(
    country = "Country",
    N_unique = "N (Studies)",
    delta_se = "∆ (se)"
  ) |>
  tab_source_note(
    source_note = "* < 0.05, ** < 0.01, *** < 0.001."
  )

# meat vs MAP as a general category
meat_vs_map <- dat |> split(~str_detect(
  pattern = "MAP", dat$outcome_category)) |>
  map(count_and_robust) |> bind_rows(.id = 'meat_vs_map') |> 
  mutate(
    meat_vs_map = case_when(
      meat_vs_map == TRUE ~ "MAP overall",
      meat_vs_map == FALSE ~ "Meat",
      TRUE ~ NA),
    pval = as.numeric(pval)) |> 
  mutate(
    delta_se = sprintf("%.3f%s (%.3f)", Delta, get_significance_stars(pval), se)) |>
  select(meat_vs_map, N_unique, delta_se) |> 
  gt() |>
  tab_header(
    title = "Table XXX",
    subtitle = "Differences in effect studies between Meat and MAP outcomes") |>
  cols_label(
    meat_vs_map = "Outcome type",
    N_unique = "N (Studies)",
    delta_se = "∆ (se)"
  ) |>
  tab_source_note(source_note = "* < 0.05, ** < 0.01, *** < 0.001.") 

study_quality_results_table <- list(
  "Pre-analysis Plan" = dat |> filter(public_pre_analysis_plan != 'N'),
  "Open Data" = dat |> filter(open_data != 'N'),
  "Both" = dat |> filter(public_pre_analysis_plan != 'N', open_data != 'N'),
  "Neither" = dat |> filter(public_pre_analysis_plan == 'N', open_data == 'N')
) |>
  map(~ .x |> count_and_robust()) |>
  bind_rows(.id = "Open Science Practice") |>
  mutate(pval = as.numeric(pval)) |> 
  mutate(delta_se = sprintf("%.3f%s (%.3f)", 
                            Delta, get_significance_stars(pval), se)) |> 
  select(`Open Science Practice`, N_unique, delta_se) |> 
  gt() |>
  tab_header(
    title = "Table XXX",
    subtitle = "Effect Sizes of Studies by Open Science Practices"
  ) |>
  cols_label(
    `Open Science Practice` = "Open Science Practice",
    N_unique = "N (Studies)",
    delta_se = "∆ (se)"
  ) |>
  tab_source_note(
    source_note = "* < 0.05, ** < 0.01, *** < 0.001."
  )
