library(haven)
library(dplyr, warn.conflicts = F)
dat <- read_sav('./Raw_data 040220.sav')

control_mean <- dat |> 
  filter(intervention == 3) |> 
  summarise(mean(FS_sold)) |> 
  pull()

dat |> 
  group_by(intervention) |> 
  summarise(
    mean_outcome = mean(FS_sold),
    diff_from_control = mean(FS_sold) - control_mean,
    sd_outcome = sd(FS_sold)
  )
# this all lines up