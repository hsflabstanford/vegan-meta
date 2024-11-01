RPMC <- read.csv("./data/robustness-data.csv") |>
  filter(inclusion_exclusion == 1) |>
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
  select(author, year, title, unique_paper_id, unique_study_id, everything())
# 
# 
# merged_dat <- full_join(dat, RPMC) |>
#   group_by(title) |>
#   select(c(-unique_study_id, unique_paper_id)) |> 
#   mutate(unique_paper_id = cur_group_id())  |> 
#   ungroup() |> 
#   group_by(unique_paper_id, study_num_within_paper) |> 
#   mutate(unique_study_id = cur_group_id()) |>
#   ungroup() 
# supplementary data
library(googlesheets4)
library(readr)

# read_sheet(ss = "1mPCt7HuK7URvuWcsMQokQCOGnSold-TS0NyC1EZniJk",
#            sheet = "robustness-data") |>
#   write_csv('./data/robustness-data.csv')

# read_sheet(ss = "1mPCt7HuK7URvuWcsMQokQCOGnSold-TS0NyC1EZniJk",
#            sheet = "red-and-processed-meat") |>
#   write_csv('./data/RPMC-data.csv')

# library(dplyr, warn.conflicts = F)
# read_sheet('1mPCt7HuK7URvuWcsMQokQCOGnSold-TS0NyC1EZniJk',
#                                sheet = 'excluded-studies') |>
#   select(Author,	Year,	Title,	doi_or_url,	source,	excllusion_reason) |>
#   write_csv('./data/excluded-studies.csv')
# 
# read_sheet('1mPCt7HuK7URvuWcsMQokQCOGnSold-TS0NyC1EZniJk',
#            sheet = 'review-of-reviews') |>
#   select(Author, Year, Title, DOI_or_URL) |>
#   write_csv('./data/review-of-reviews.csv')
