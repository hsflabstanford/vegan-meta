robustness_dat <- read.csv('./data/robustness-check.csv') |>
  group_by(title) |>
  mutate(unique_paper_id = cur_group_id())  |> 
  ungroup() |> 
  group_by(unique_paper_id, study_num_within_paper) |> 
  mutate(unique_study_id = cur_group_id()) |>
  ungroup() |>
  mutate(decade = as.factor(case_when(year >= 2000 & year <= 2009 ~ "2000s",
                                      year >= 2010 & year <= 2019  ~ "2010s",
                                      year >= 2020 ~ "2020s")),
         pub_status = case_when(
           venue == "advocacy org publication" ~ 'Advocacy Organization',
           venue == "Bachelor's Thesis" ~ 'Thesis',
           venue == "Dissertation" ~ 'Thesis',
           venue == "Master's Thesis" ~ 'Thesis',
           venue == "SSRN (Preprint)" ~ 'Preprint',
           str_detect(doi_or_url, "10\\.") ~ "Journal article"),
         total_sample = n_c_post + n_c_post, d = mapply(
           FUN = d_calc,
           stat_type = eff_type,
           stat =  u_s_d,
           sample_sd = ctrl_sd,
           n_t = n_t_post,
           n_c = n_c_post),
         var_d = mapply(
           FUN = var_d_calc,
           d = d,
           n_c = n_c_post,
           n_t = n_t_post),
         se_d = sqrt(var_d)) |> 
  select(author, year, title, unique_paper_id, unique_study_id, everything())


# how many studies? 
robust_num_papers <- as.numeric(max(robustness_dat$unique_paper_id))
robust_num_studies <- as.numeric(max(robustness_dat$unique_study_id))
robust_num_interventions <- as.numeric(nrow(robustness_dat))
robust_n_total <-  round_to(x = sum(robustness_dat$n_c_total_pop) + 
                              sum(robustness_dat$n_t_total_pop), 1000, floor)

# models

## robustness model

robustness_model <- robustness_dat |> map_robust()

## no delay model

robustness_dat |> filter(str_detect(notes, 'no delay')) |> map_robust()

## randomization model

robustness_dat |> filter(str_detect(notes, 'RCT issue')) |> map_robust()

robustness_dat |> filter(str_detect(notes, 'horse')) |> map_robust()

robustness_dat |> filter(str_detect(notes, 'not randomized')) |> map_robust()

#underpowered model
underpower_model <- robustness_dat |> filter(str_detect(notes, 'underpowered')) |> map_robust()

# merge robustness data and main data
integrated_model <- full_join(dat, robustness_dat) |> map_robust()
