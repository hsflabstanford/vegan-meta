library(haven)
library(dplyr, warn.conflicts = F)
dat <- read_sav(file = './supplementary-analyses/Kanchanachitra reanalysis/Raw_data 040220.sav')

control_mean <- dat |> 
  filter(intervention == 3) |> 
  summarise(mean(FS)) |> 
  pull()

dat |> 
  group_by(intervention) |> 
  summarise(
    mean_outcome = mean(FS),
    diff_from_control = mean(FS) - control_mean,
    sd_outcome = sd(FS)
  )

# redoing significance tests based on the total amount of fish sauce sold
# (the study presents fish sauce per person because it's mainly aimed at health
# but if we're interested in MAP reduction efforts we want to know total change)

multi_lm <- function(formula, data, control_condition) {
  # Convert the formula to a character to manipulate the terms
  formula_str <- as.character(formula)
  
  # Extract the dependent and independent variables
  response_var <- formula_str[2]
  predictor_var <- formula_str[3]
  
  # Convert the predictor to a factor if it's not already
  data[[predictor_var]] <- as.factor(data[[predictor_var]])
  
  # Relevel the factor so that the control_condition is the reference (intercept)
  data[[predictor_var]] <- relevel(data[[predictor_var]], ref = control_condition)
  
  # Fit the linear model
  model <- lm(formula, data = data)
  
  # Get the summary of the model
  summary_model <- summary(model)
  
  # Adjust the p-value for the intercept by comparing it to the control group's mean
  control_mean <- mean(data[[response_var]][data[[predictor_var]] == control_condition])
  intercept_se <- summary_model$coefficients[1, "Std. Error"]
  t_value <- (control_mean - control_mean) / intercept_se
  intercept_p_value <- 2 * pt(-abs(t_value), df = summary_model$df[2])
  
  # Update the summary object to include the new p-value
  summary_model$coefficients[1, "Pr(>|t|)"] <- intercept_p_value
  
  return(summary_model)
}

multi_lm(FS ~ intervention, data = dat, control_condition = "3")

# Print the updated summary
# print(model_summary)

