# Overall results by theory
# Filter the data for each theory/approach, apply count_and_robust, and then combine
all_results <- bind_rows(
  dat |> filter(str_detect(theory, "norms")) |> count_and_robust() |> mutate(Approach = "Norms"),
  dat |> filter(str_detect(theory, "nudge")) |> count_and_robust() |> mutate(Approach = "Nudge"),
  dat |> filter(str_detect(secondary_theory, "health")) |> count_and_robust() |> mutate(Approach = "Health"),
  dat |> filter(str_detect(secondary_theory, "environment")) |> count_and_robust() |> mutate(Approach = "Environment"),
  dat |> filter(str_detect(secondary_theory, "animal welfare")) |> count_and_robust() |> mutate(Approach = "Animal Welfare"),
  dat |> filter(str_detect(theory, "persuasion")) |> count_and_robust() |> mutate(Approach = "Persuasion")) |> 
  select(Approach, N_unique, everything())

all_results_gt_table <- all_results |>
  gmt(
    title = "Summary of Results by Theory",
    subtitle = "Comparing Effect Sizes Across Different Theories",
    col_name = Approach,
    col_label = "Theory",
    tab_source_note = "Note that because many studies present overlapping approaches, the numbers in this table do not sum to the total number of studies in our sample."
  )

# Overall results by delivery method
delivery_method_results <- bind_rows(
  dat |> filter(str_detect(internet, "Y")) |> count_and_robust() |> mutate(DeliveryMethod = "Internet"),
  dat |> filter(str_detect(leaflet, "Y")) |> count_and_robust() |> mutate(DeliveryMethod = "Pamphlet"),
  dat |> filter(str_detect(video, "Y")) |> count_and_robust() |> mutate(DeliveryMethod = "Video"),
  dat |> filter(cafeteria_or_restaurant_based == "Y") |> count_and_robust() |> mutate(DeliveryMethod = "Place-Based"),
  dat |> filter(cafeteria_or_restaurant_based == 'N' &
                  !str_detect(video, "Y") &
                  !str_detect(leaflet, "Y") &
                  !str_detect(internet, "Y")) |> count_and_robust() |> mutate(DeliveryMethod = "Everything else")
)

delivery_method_table <- delivery_method_results |>
  gmt(
    title = "Summary of Results by Delivery Method",
    subtitle = "Comparing Effect Sizes Across Different Delivery Methods",
    col_name = DeliveryMethod,
    col_label = "Delivery Method")

# Results by animal advocacy organization
advocacy_org_results <- dat |>
  split(~advocacy_org) |>
  map(count_and_robust) |>
  bind_rows(.id = "advocacy_org") |>
  arrange(desc(N_unique)) |>
  mutate(pval = as.numeric(pval)) |>
  mutate(
    advocacy_org = if_else(advocacy_org == "N", 
                           "Researchers (non-advocacy)", advocacy_org))

advocacy_org_table <- advocacy_org_results |>
  gmt(
    title = "Results by Animal Advocacy Organization",
    col_name = advocacy_org,
    col_label = "Advocacy Organization",
    tab_source_note = TRUE
  )

# Results by country
country_results <- dat |>
  split(~country) |>
  map(count_and_robust) |>
  bind_rows(.id = "country") |>
  arrange(desc(N_unique)) |>
  mutate(pval = as.numeric(pval)) |>
  mutate(
    country = if_else(
      country == "United States, United Kingdom, Canada, Australia, and other",
      "US, UK, Canada, Australia, and other",
      country
    )
  )

country_results_table <- country_results |>
  gmt(
    title = "Results by Country",
    col_name = country,
    col_label = "Country",
    tab_source_note = TRUE
  )

# Meat vs MAP as a general category
meat_vs_map <- dat |>
  split(~str_detect(pattern = "MAP", dat$outcome_category)) |>
  map(count_and_robust) |>
  bind_rows(.id = 'meat_vs_map') |>
  mutate(
    meat_vs_map = case_when(
      meat_vs_map == TRUE ~ "MAP overall",
      meat_vs_map == FALSE ~ "Meat",
      TRUE ~ NA
    )
  )

meat_vs_map_table <- meat_vs_map |>
  gmt(
    title = "Differences in effect studies between Meat and MAP outcomes",
    col_name = meat_vs_map,
    col_label = "Outcome type"
  )

# Results by open science practices
study_quality_results <- list(
  "Pre-analysis Plan" = dat |> filter(public_pre_analysis_plan != 'N'),
  "Open Data" = dat |> filter(open_data != 'N'),
  "Both" = dat |> filter(public_pre_analysis_plan != 'N' & open_data != 'N'),
  "Neither" = dat |> filter(public_pre_analysis_plan == 'N' & open_data == 'N')
) |>
  map(~ .x |> count_and_robust()) |>
  bind_rows(.id = "Open Science Practice")

study_quality_results_table <- study_quality_results |>
  gmt(
    title = "Effect Sizes of Studies by Open Science Practices",
    col_name = 'Open Science Practice',
    col_label = "Open Science Practice",
    tab_source_note = TRUE
  )


# Print the tables to verify
print(all_results_gt_table)
print(delivery_method_table)
print(advocacy_org_table)
print(country_results_table)
print(meat_vs_map_table)
print(study_quality_results_table)

