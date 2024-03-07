library(haven)
library(dplyr, warn.conflicts = F)

# study 2
study_two_dat <- haven::read_sav(file = 'code/piester-et-al-re-analysis/Piester et al. Cafe Studies Study 2.public.sav')

study_two_dat |>
  group_by(condition = case_when(
    cond.taste == 0 & cond.sustain == 0 ~ "Control",
    cond.taste == 1 & cond.sustain == 0 ~ "Taste",
    cond.taste == 0 & cond.sustain == 1 ~ "Sustain",
    cond.taste == 1 & cond.sustain == 1 ~ "Taste + Sustain",
    is.na(veggie.buy) ~ "NA"
  )) |>
  summarise(
    buy_veggie_item = sum(veggie.buy == 1, na.rm = TRUE),
    no_buy_veggie_item = sum(veggie.buy == 0, na.rm = TRUE),
    nas = sum(is.na(veggie.buy))
  )
# these Ns don't line up with those in the paper very well

# linear coefficients? as a sanity check
models <- study_two_dat |>
  mutate(
    is_control = (cond.taste == 0 & cond.sustain == 0),
    is_taste = (cond.taste == 1 & cond.sustain == 0),
    is_sustain = (cond.taste == 0 & cond.sustain == 1),
    is_taste_sustain = (cond.taste == 1 & cond.sustain == 1)
  ) 

  summary(lm(veggie.buy ~ is_taste + is_sustain + is_taste_sustain, dat = models))
# lines up nicely