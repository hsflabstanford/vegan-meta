# peacock 2017 re-analysis

# we want a T1-T0 for each treatment group restricted people who have both data
# at T1 and T0, then do a DiD vs control group changeand divide by SD of the
# control group
# data available on https://osf.io/2kpq9/
# https://talkeco.org/wp-content/uploads/which-request-creates-the-most-diet-change-reanalysis.pdf

library(dplyr)
library(purrr)
source('./scripts/functions.R')
peacock_dat <- read.csv('./supplementary-analyses/peacock 2017 re-analysis/Which_request_creates_the_most_diet_change.csv') |>
  filter(!is.na(Total_Chg)) |> filter(BookletDescrp != "") |>
  group_by(BookletDescrp) |>
  filter(n() >= 25) |>
  ungroup()

ctrl_mean <- peacock_dat |>
  filter(BookletDescrp == "control") |>
  summarise (ctrl_mean = mean(Total_Chg))
ctrl_sd <- peacock_dat |>
  filter(BookletDescrp == "control") |>
  summarise(ctrl_sd = sd(Total_Chg))

peacock_tab <- peacock_dat |>
  group_by(BookletDescrp) |>
  summarise(
    N = n(),
    total_chg = mean(Total_Chg, na.rm = TRUE),
    d_i_d = total_chg - ctrl_mean$ctrl_mean,
    t_test = list(t.test(Total_Chg, peacock_dat |> filter(BookletDescrp == "control") |>  pull(Total_Chg))),
    t_stat = map_dbl(t_test, ~ .x$statistic),
    p_value = map_dbl(t_test, ~ .x$p.value)
  ) |> select(-t_test)
peacock_tab

# got it -- and remember "Animal-Friendly Changes In Diet 
# (positive numbers indicate a reduction in consumption)"