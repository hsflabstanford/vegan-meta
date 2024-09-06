library(haven)
library(dplyr)
# all we need is the SD of the control group's proportion of vegetarian days
# everything else is in Fig. 6. Average number of vegetarian days over past seven days (from round three).

dat <- read_dta('./supplementary-analyses/Shreedar 2021/Parts123_OSF.dta')

# what's going on with the data
dat |> filter(!is.na(past3d_veg2)) |> group_by(treatb1b2) |> summarise(final_outcome = mean(past3d_veg2)) 
#  these numbers line up perfectly with figure 5

# now trying to reproduce figure 6
dat |> filter(!is.na(pastweek_veg3)) |> group_by(treatb1b2) |> summarise(final_outcome = mean(pastweek_veg3) -2 ) 

# maybe they eliminate anyone with impossible answers?
dat |> filter(!is.na(pastweek_veg3)) |> filter(pastweek_veg3 < 8) |> group_by(treatb1b2) |> summarise(final_outcome = mean(pastweek_veg3)) 

# it's close enough. just need the SD
dat |> filter(treatb1b2 == 0) |> filter(!is.na(pastweek_veg3)) |> summarise(sd_ctrl = sd(pastweek_veg3))
