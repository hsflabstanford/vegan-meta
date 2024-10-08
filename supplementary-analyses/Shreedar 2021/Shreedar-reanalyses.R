library(haven)
library(dplyr)
# all we need is the SD of the control group's proportion of vegetarian days
# everything else is in Fig. 6. Average number of vegetarian days over past seven days (from round three).

dat <- read_dta('./supplementary-analyses/Shreedar 2021/Parts123_OSF.dta')

# what's going on with the data
dat |> filter(!is.na(past3d_veg2)) |> group_by(treatb1b2) |> summarise(final_outcome = mean(past3d_veg2)) 
#  these numbers line up perfectly with figure 5

dat |> filter(!is.na(pastweek_veg)) |> group_by(treatb1b2) |> summarise(baseline_outcome = mean(pastweek_veg),
                                                                        baseline_sd = sd(pastweek_veg)) 
# these numbers line up exactly with table 3, good
# SD is 2.29

# now trying to reproduce figure 6
dat |> filter(!is.na(pastweek_veg3)) |> group_by(treatb1b2) |> summarise(final_outcome = mean(pastweek_veg3),
                                                                        final_sd = sd(pastweek_veg3)) 
# that's not right
dat |> group_by(treatb1b2) |> filter(!is.na(past3d_veg2)) |> s
ummarise(final_outcome = mean(past3d_veg2))
# that's probably right. figure 6 has a typo about which data it is reporting,
# should be 3 day not 7. To do d_i_d, we'll take the seven day data. 

# not sure what's going on here
# but I do notice substantial baseline differences. 
# we do d_i_d whenever we can. might be a data issue
# The figure 6 numbers don't really line up with the data at all nor the numbers in table 3
# I am starting to think there was a mistake
# Ns
dat |>  group_by(treatb1b2) |> filter(!is.na(pastweek_veg3)) |> filter(pastweek_veg3 < 8) |> summarise(n = n())
