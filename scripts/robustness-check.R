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
  mutate(theory_category = if_else(str_detect(theory, "Persuasion &"), 
                                   "Persuasion Plus",
                                   theory)) |> 
  select(author, year, title, unique_paper_id, unique_study_id, everything())


new_dat <- full_join(dat, robustness_dat)

# models

## partial model

robustness_dat |> map_robu()

full_model <- new_dat |> map_robust()

# everything?

full_dat <- full_join(new_dat, RPMC)
