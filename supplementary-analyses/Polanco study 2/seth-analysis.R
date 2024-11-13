#' Seth analysis
#' 
library(dplyr)
library(stringr)
library(forcats)
load('RE Experiment_FU1_final.Rdata')
dat <- data |> filter(!is.na(ffq_total_fu1)) |> 
  mutate(ATE = ffq_total_baseline - ffq_total_fu1) |> 
  select(condition, advocacytype, ATE, ffq_total_baseline, ffq_total_fu1)
# a negative (-) answer means meat consumption went up
head(dat)
sd(dat$ffq_total_baseline)
summary(dat$ATE)

# sanity check: what is the overall ATE?

# control data
ctrl_data <- dat |> filter(advocacytype == 'control')
ctrl_sd <- ctrl_data |> summarise(sd = sd(ffq_total_baseline))
ctrl_diff <- ctrl_data |>  summarise(ctrl_diff = mean(ATE))

# treatment data
trt_data <- dat |> filter(advocacytype != 'control')
  
trt_ate <- trt_data |> summarise(mean_ate = mean(ATE))

(trt_ate - ctrl_diff) / ctrl_sd # this is overall delta

# eggs data
egg_data <- dat |> filter(str_detect(condition, 'eggs')) |>
  mutate(condition = fct_drop(condition))
table(egg_data$condition) # check that factors were dropped
sd_egg_control <- sd(egg_data$ATE[egg_data$condition == 'control_eggs'])

ATE_control_eggs <- egg_data |>
  filter(condition == 'control_eggs') |>
  summarise(ATE_control = mean(ATE)) |>
  pull(ATE_control) |>
  as.numeric()

# table of eggg ATEs
egg_results <- egg_data |>
  group_by(condition) |>
  summarise(Ns = n(),
            ATE = mean(ATE),
            DiD = mean(ATE) - ATE_control_eggs,
            Delta = DiD/sd_egg_control)
# and again we're not checking for P values because the authors tell us 
# that they applied a Bonferroni correction and nothing met the defined standard

# fish data
fish_data <- dat |> filter(str_detect(condition, 'fish')) |>
  mutate(condition = fct_drop(condition))
table(fish_data$condition) # check that factors were dropped
sd_fish_control <- sd(fish_data$ATE[fish_data$condition == 'control_fish'])

ATE_control_fish <- fish_data |>
  filter(condition == 'control_fish') |>
  summarise(ATE_control = mean(ATE)) |>
  pull(ATE_control) |>
  as.numeric()

# table of fish ATEs
fish_results <- fish_data |>
  group_by(condition) |>
  summarise(Ns = n(),
            ATE = mean(ATE),
            DiD = mean(ATE) - ATE_control_fish,
            Delta = DiD/sd_fish_control)

# table of generaL ATES
general_data <- dat |> filter(str_detect(condition, 'general')) |>
  mutate(condition = fct_drop(condition))
sd_general_control <- sd(general_data$ATE[general_data$condition == 'control_general'])

ATE_control_general <- general_data |>
  filter(condition == 'control_general') |>
  summarise(ATE_control = mean(ATE)) |>
  pull(ATE_control) |>
  as.numeric()

# table of general ATEs
general_results <- general_data |>
  filter(condition != "control_general") |> 
  group_by(condition) |> 
  summarise(Ns = n(),
            DiD = mean(ATE) - ATE_control_general)
  
# general summary stats
sum_table <- summary(lm(ATE ~ condition, data = dat))
plot(density(dat$ATE))
summary(dat$ATE)
range(dat$ATE)
colnames(dat)
table(dat$advocacytype)
table(dat$condition)
table(dat$purchase_plantbased)
mean(dat$age)
