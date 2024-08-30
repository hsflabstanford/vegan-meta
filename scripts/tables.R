table_one <- tibble(
  Approach = c("\\textbf{Overall}", "Norms", "Nudge", 
               "Persuasion", 
               "Norms + Persuasion"),
  "N (Studies)" = c(model$N_studies,
                    norms_model$N_studies,
                    nudge_model$N_studies,
                    persuasion_model$N_studies,
                    norms_persuasion_model$N_studies),
  "N (Interventions)" = c(model$N_interventions,
                          norms_model$N_interventions,
                          nudge_model$N_interventions,
                          persuasion_model$N_interventions,
                          norms_persuasion_model$N_interventions),
  "N (Subjects)" = c(model$N_subjects,
                     norms_model$N_subjects,
                     nudge_model$N_subjects,
                     persuasion_model$N_subjects,
                     norms_persuasion_model$N_subjects),
  "Glass's $\\Delta$ (SE)" = c(mr(model),
                               mr(norms_model),
                               mr(nudge_model),
                               mr(persuasion_model),
                               mr(norms_persuasion_model))) |>
  meta_table_maker(caption = "Norm, Nudge, and persuasion approaches to MAP reduction", 
                   label = "tab:table_one", footnote = T) |>
  add_footnote("Note: Many cluster-assigned studies do not report an exact number of subjects, \\linebreak so our N of subjects are rounded estimates.", notation = 'none', escape = F)



table_two <- tibble(
  "Persauasion Approach" = c("Health", 
                             "Environment", 
                             "Animal Welfare"),
  "N (studies)" = c(health_model$N_studies,
                    environment_model$N_studies,
                    animal_model$N_studies),
  "N (interventions)" = c(health_model$N_interventions,
                          environment_model$N_interventions,
                          animal_model$N_interventions),
  "N (subjects)" = c(health_model$N_subjects,
                     environment_model$N_subjects,
                     animal_model$N_subjects),
  "Glass's $\\Delta$ (SE)" = c(mr(health_model),
                               mr(environment_model),
                               mr(animal_model))) |>
  meta_table_maker(caption = "Three approaches to MAP reduction persuasion", 
                   label = "tab:table_two", footnote = F) |> 
  add_footnote("Note: because many studies present more than one category of message, the Ns for studies, \\linebreak interventions, and subjects will sum to more than the total numbers in the persuasion category.", notation = 'none', escape = F)

table_three <- dat |> 
  split(~pub_status) |> 
  map(map_robust) |> 
  map(~ .x |> mutate("Glass's $\\Delta$ (SE)" =
                       meta_result_formatter(.x))) |> 
  bind_rows(.id = 'Publication status') |> 
  mutate(`Publication status` = case_when(
    `Publication status` == "advocacy_org" ~ "Advocacy Organization",
    TRUE ~ `Publication status`
  )) |>
  rename(
    `N (Studies)` = N_studies,
    `N (Interventions)` = N_interventions,
    `N (subjects)` = N_subjects) |>
  select(-c(Delta, se, pval))  |> 
  meta_table_maker(
    caption = "Difference in effect size by publication status",
    label = "tab:table_three",
    footnote = TRUE)

# we cut this one from the final 
RPM_table <- tibble(
  "N (Studies)" = rpmc_model$N_studies,
  "N (Interventions)" = rpmc_model$N_interventions,
  "Glass's $\\Delta$ (SE)" = mr(rpmc_model)) |>
  kable(format = "latex", booktabs = TRUE, escape = FALSE,
        caption = "Meta-analytic results for red and processed meat",
        label = "tab:rpm_table") |>
  kable_styling(latex_options = "hold_position") |>
  footnote(general_title = "",
           general = "* p $<$ 0.05, ** p $<$ 0.01, *** p $<$ 0.001",
           escape = FALSE)

table_four <- dat |> 
  mutate(grouped_delivery_method = case_when(
    str_detect(delivery_method, "article|op-ed|leaflet|flyer|printed booklet") ~ "Printed Materials",
    str_detect(delivery_method, "video") ~ "Video",
    str_detect(delivery_method, "in-cafeteria") ~ "In-Cafeteria",
    str_detect(delivery_method, "online") ~ "Online",
    TRUE ~ "Other")) |> 
  filter(grouped_delivery_method != 'Other') |> 
  split(~grouped_delivery_method) |> map(map_robust) |>
  map(~ .x |> mutate("Glass's $\\Delta$ (SE)" =
                       meta_result_formatter(.x))) |> 
  bind_rows(.id = "Delivery method") |> 
  arrange(desc(N_studies)) |> 
  rename(
    `N (Studies)` = N_studies,
    `N (Interventions)` = N_interventions,
    `N (subjects)` = N_subjects) |>
  select(-c(Delta, se, pval)) |> 
  meta_table_maker(
    caption = "Difference in effect size by delivery method",
    label = "tab:table_four",
    footnote = F)

table_five <- dat |> 
  mutate(grouped_region = case_when(
    country %in% c("United States", "Canada") ~ "North America",
    country %in% c("United Kingdom", "Denmark", "Germany", "Italy", "Netherlands", "Sweden") ~ "Europe",
    str_detect(country, "worldwide|United States, United Kingdom, Canada, Australia, and other|Iran|Thailand|Australia") ~ "Asia, Australia, and worldwide",
    TRUE ~ "Other")) |> 
  split(~grouped_region) |> 
  map(map_robust) |> 
  map(~ .x |> mutate("Glass's $\\Delta$ (SE)" = meta_result_formatter(.x))) |> 
  bind_rows(.id = "Region") |> 
  arrange(desc(N_studies)) |> 
  rename(
    `N (Studies)` = N_studies,
    `N (Interventions)` = N_interventions,
    `N (Subjects)` = N_subjects) |>
  select(-c(Delta, se, pval))  |> 
  meta_table_maker(caption = "Difference in effect size by study region",
                   label = "tab:table_five")

supplementary_table <- dat |> 
  group_by(unique_paper_id) |> 
  slice(1) |> 
  ungroup() |>
  mutate(source_group = case_when(
    str_detect(source, "Ammann|Chang|Bianchi|Gennaro|Harguess|Mathur|Ronto|Wynes") ~ 'Prior literature review',
    str_detect(source, 'CV') ~ 'Researcher CVs',
    str_detect(source, 'internet search') ~ 'Internet search',
    str_detect(source, 'prior knowledge') ~ 'Prior knowledge',
    str_detect(source, 'RP research') ~ 'Rethink Priorities search',
    str_detect(source, 'snowball search') ~ 'Snowball search',
    str_detect(source, 'systematic search') ~ 'Systematic search',
    str_detect(source, 'undermind.ai') ~ 'AI search tool',
    TRUE ~ 'other')) |> 
  sum_tab(source_group) |> 
  enframe(name = "Source", value = "Count") |> 
  arrange(desc(Count)) |> 
  meta_table_maker(caption = "\\textbf{Table S1}: Sources of studies in dataset", 
                   label = 'tab:supp_table')
