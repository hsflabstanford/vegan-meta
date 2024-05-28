RPMC <- read.csv("./data/RPMC-data.csv") |>
  group_by(title) |>
  mutate(unique_paper_id = cur_group_id())  |> 
  ungroup() |> 
  group_by(unique_paper_id, intervention_condition) |> 
  mutate(unique_study_id = cur_group_id()) |>
  ungroup() |>
  mutate(decade = as.factor(case_when(year >= 2000 & year <= 2009 ~ "2000s",
                                      year >= 2010 & year <= 2019  ~ "2010s",
                                      year >= 2020 ~ "2020s")),
         total_sample = n_c_post + n_c_post,
         d = mapply(
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
  select(-one_of("X")) |>
  select(author, year, title, unique_paper_id, unique_study_id, everything()) 

first_decade_RPMC_studies <- RPMC |> filter(year == 2005)

carfora_studies <- RPMC |> filter(str_detect(author, "Carfora"))

