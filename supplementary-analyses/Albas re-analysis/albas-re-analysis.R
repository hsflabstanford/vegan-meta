
dat <- haven::read_sav('../literature/included/supplementary materials/Albas re-analysis/Albas 2023 data.sav')

# "In the final sample, 83 participants received descriptive norm only feedback
# ... 87 participants received descriptive plus injunctive norm feedback... and
# and 109 participants received no feedback"
tab <- table(dat$Feedback)
# there are two equivalent ways to select objects fron this table
tab[["0"]] == tab[1]
# this is just to be extra careful, the text already tells us what's what
n_c <- as.numeric(tab[["0"]])
n_t_descriptive <- as.numeric(tab[["1"]])
n_c <- as.numeric(tab[["0"]])

  # Subset the data for each group
control_group <- dat[dat$Feedback == 0, ]
descriptive_norm_group <- dat[dat$Feedback == 1, ]
injunctive_norm_group <- dat[dat$Feedback == 2, ]

# Calculate T2-T0 differences for each group compared to control (group 0)
diff_0 <- mean(control_group$T2_meatconsumption - control_group$T0_meatconsumption)
diff_1 <- mean(descriptive_norm_group$T2_meatconsumption - descriptive_norm_group$T0_meatconsumption)
diff_2 <- mean(injunctive_norm_group$T2_meatconsumption - injunctive_norm_group$T0_meatconsumption)

# Calculate the standard deviation of T0_meatconsumption for the control group (group 0)
sd_control_group <- sd(control_group$T0_meatconsumption)

# Display the results
descriptive_norm_group_did <- diff_1 - diff_0; descriptive_norm_group_did
injunctive_norm_group_did <- diff_2 - diff_0; injunctive_norm_group_did
cat("Standard Deviation of T0_meatconsumption for Group 0:", round(sd_control_group, 4), "\n")

# just making sure I understand what's going on with this data
# F-test
var.test(descriptive_norm_group$T2_meatconsumption, control_group$T2_meatconsumption)
var.test(injunctive_norm_group$T2_meatconsumption, control_group$T2_meatconsumption)

# regression
summary(lm(T2_meatconsumption ~ Feedback + T0_meatconsumption , data = dat))

# the reason this isn't directionally the same as the d_i_d is baseline variance
mean(descriptive_norm_group$T2_meatconsumption) - mean(control_group$T2_meatconsumption) 
mean(injunctive_norm_group$T2_meatconsumption) - mean(control_group$T2_meatconsumption) 

# another way to slice it 
summary(lm(T2_meatconsumption - T0_meatconsumption ~ Feedback , data = dat))
