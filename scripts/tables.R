# descriptive results tables

# country breakdown table
data.frame(
  Country = c("United States", "Germany", "Multiple (online)", "United Kingdom", "Netherlands", "Sweden", "Australia", "Canada", "Denmark"),
    Interventions = c(country_dat[["United States"]],
                      country_dat[["Germany"]],
                      5,
                      country_dat[["United Kingdom"]],
                      country_dat[["Netherlands"]],
                      country_dat[["Sweden"]],
                      country_dat[["Australia"]],
                      country_dat[["Canada"]],
                      country_dat[["Denmark"]])) |> gt() |> # gtsave('./tables/country_breakdown_table.png')
# sparkman et al table
data.frame(
  Study = c("One", "Two", "Three", "Four"),
  Location = c(
    "The Axe & Palm cafe",
    "Farm Hill (virtual)",
    "Vino Enoteca (lunch)",
    "Vino Enoteca (dinner)"
  ),
  `Effect on veg sales` = c(
    "+ 1.4 to 1.7%",
    "+ 2.6% (non-significant)",
    "+ 2.2%",
    "- 3.7%"),
  stringsAsFactors = FALSE,
  check.names = FALSE) |> gt() |> # gtsave('./tables/sparkman_table.png')


# Overall results by theory

all_results <- bind_rows(
  dat |> filter(str_detect(theory, "norms")) |> count_and_robust() |> mutate(Approach = "Norms"),
  dat |> filter(str_detect(theory, "nudge")) |> count_and_robust() |> mutate(Approach = "Nudge"),
  dat |> filter(str_detect(secondary_theory, "health")) |> count_and_robust() |> mutate(Approach = "Health"),
  dat |> filter(str_detect(secondary_theory, "environment")) |> count_and_robust() |> mutate(Approach = "Environment"),
  dat |> filter(str_detect(secondary_theory, "animal welfare")) |> count_and_robust() |> mutate(Approach = "Animal Welfare"),
  dat |> filter(str_detect(theory, "persuasion")) |> count_and_robust() |> mutate(Approach = "Persuasion")) |> 
  select(Approach, N_unique, everything())

# Overall results by delivery method
delivery_method_results <- bind_rows(
  dat |> filter(str_detect(internet, "Y")) |> count_and_robust() |> mutate(DeliveryMethod = "Internet"),
  dat |> filter(str_detect(leaflet, "Y")) |> count_and_robust() |> mutate(DeliveryMethod = "Pamphlet"),
  dat |> filter(str_detect(video, "Y")) |> count_and_robust() |> mutate(DeliveryMethod = "Video"),
  dat |> filter(cafeteria_or_restaurant_based == "Y") |> count_and_robust() |> mutate(DeliveryMethod = "Place-Based"),
  dat |> filter(cafeteria_or_restaurant_based == 'N' &
                  !str_detect(video, "Y") &
                  !str_detect(leaflet, "Y") &
                  !str_detect(internet, "Y")) |> 
    count_and_robust() |> mutate(DeliveryMethod = "Everything else"))

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

# Results by country
country_results <- dat |>
  mutate(
    country = if_else(
      country == "United States, United Kingdom, Canada, Australia, and other",
      "worldwide",
      country)) |> 
  split(~country) |>
  map(count_and_robust) |>
  bind_rows(.id = "country") |>
  arrange(desc(N_unique)) |>
  mutate(pval = as.numeric(pval))

# Meat vs MAP as a general category
meat_vs_map <- dat |>
  split(~str_detect(pattern = "MAP", dat$outcome_category)) |>
  map(count_and_robust) |>
  bind_rows(.id = 'meat_vs_map') |>
  mutate(
    meat_vs_map = case_when(
      meat_vs_map == TRUE ~ "MAP overall",
      meat_vs_map == FALSE ~ "Meat",
      TRUE ~ NA))

# Results by open science practices
study_quality_results <- list(
  "Pre-analysis Plan" = dat |> filter(public_pre_analysis_plan != 'N'),
  "Open Data" = dat |> filter(open_data != 'N'),
  "Both" = dat |> filter(public_pre_analysis_plan != 'N' & open_data != 'N'),
  "Neither" = dat |> filter(public_pre_analysis_plan == 'N' & open_data == 'N')
) |>
  map(~ .x |> count_and_robust()) |>
  bind_rows(.id = "Open Science Practice")

# Split by publication type
publication_type_eff_size <- dat |> split(~pub_status) |> 
  map(count_and_robust) |> 
  bind_rows(.id = "publication_type") |>
  arrange(desc(N_unique))

# self report within non-advocacy reports
self_report_non_advocacy_results <- dat |>
  filter(advocacy_org == 'N') |>
  split(~self_report == 'Y') |>
  map(count_and_robust) |>
  bind_rows(.id = 'self_report') |>
  arrange(desc(N_unique))

# population? 
population_results <- dat |> split(~population) |> 
  map(map_robust) |> bind_rows(.id = 'population') |> 
  arrange(desc(N_unique)) 

# gt tables
all_results_gt_table <- all_results |>
  gmt(
    title = "Summary of Results by Theory",
    col_name = Approach,
    col_label = "Theory")
# gtsave(all_results_gt_table, './tables/all_results_gt_table.png')

delivery_method_table <- delivery_method_results |>
  gmt(
    title = "Summary of Results by Delivery Method",
    col_name = DeliveryMethod,
    col_label = "Delivery Method")
# gtsave(delivery_method_table, './tables/delivery_method_table.png')

advocacy_org_table <- advocacy_org_results |>
  gmt(
    title = "Results by Animal Advocacy Organization",
    col_name = advocacy_org,
    col_label = "Advocacy Organization",
    tab_source_note = TRUE
  )
# gtsave(advocacy_org_table, './tables/advocacy_org_table.png')

country_results_table <- country_results |>
  gmt(
    title = "Results by Country",
    col_name = country,
    col_label = "Country")
# gtsave(country_results_table, './tables/country_results_table.png')

meat_vs_map_table <- meat_vs_map |>
  gmt(
    title = "Differences in effect studies between Meat and MAP outcomes",
    col_name = meat_vs_map,
    col_label = "Outcome type")
# gtsave(meat_vs_map_table, './tables/meat_vs_map_table.png')

study_quality_results_table <- study_quality_results |>
  gmt(
    title = "Effect Sizes of Studies by Open Science Practices",
    col_name = 'Open Science Practice',
    col_label = "Open Science Practice",
    tab_source_note = TRUE)
# gtsave(study_quality_results_table, './tables/study_quality_results_table.png')

population_results_table <- population_results |>
  gmt(title = "Results by Population",
         col_name = population,
         col_label = "Population")
# gtsave(population_results_table, './tables/population_results_table.png')

self_report_non_advocacy_table <- self_report_non_advocacy_results |>
  gmt(
    title = "Results by Self-Reported Outcomes excluding advocacy publications",
    col_name = self_report,
    col_label = "Self Report",
    tab_source_note = TRUE)
# gtsave(self_report_non_advocacy_table, './tables/self_report_non_advocacy_table.png')

publication_type_eff_size_table <- publication_type_eff_size |>
  gmt(
    title = "Effect Sizes of Studies by Publication Type",
    col_name = publication_type,
    col_label = "Publication Type",
    tab_source_note = TRUE)
# gtsave(publication_type_eff_size_table, './tables/publication_type_eff_size_table.png')

