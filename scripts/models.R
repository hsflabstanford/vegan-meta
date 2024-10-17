# Overall
model <-robumeta::robu(formula = d ~ 1, data = dat, studynum = unique_study_id, 
                       var.eff.size = var_d, modelweights = 'CORR', small = TRUE)

# Nudge
choice_model <- dat |> filter(str_detect(theory, 'Choice Architecture')) |> 
  robumeta::robu(formula = d ~ 1, studynum = unique_study_id, 
                 var.eff.size = var_d, modelweights = 'CORR', small = TRUE)

# psychology
psychology_model <- dat |> filter(theory == 'Psychology') |> 
  robumeta::robu(formula = d ~ 1, studynum = unique_study_id, 
                 var.eff.size = var_d, modelweights = 'CORR', small = TRUE)

# Persuasion Overall
persuasion_model <- dat |> filter(theory == 'Persuasion') |> 
  robumeta::robu(formula = d ~ 1, studynum = unique_study_id, 
                 var.eff.size = var_d, modelweights = 'CORR', small = TRUE)

# persuasion plus
persuasion_psychology_model <- dat |> filter(str_detect(theory, "Persuasion & Psychology")) |> 
  robumeta::robu(formula = d ~ 1, studynum = unique_study_id, 
                 var.eff.size = var_d, modelweights = 'CORR', small = TRUE)
# Persuasion (Health)
health_model <- dat |> filter(str_detect(secondary_theory, 'health')) |> 
  robumeta::robu(formula = d ~ 1, studynum = unique_study_id, 
                 var.eff.size = var_d, modelweights = 'CORR', small = TRUE)
# Persuasion (Environment)
environment_model <- dat |> filter(str_detect(secondary_theory, 'environment')) |> 
  robumeta::robu(formula = d ~ 1, studynum = unique_study_id, 
                 var.eff.size = var_d, modelweights = 'CORR', small = TRUE)
# Persuasion (Animal Welfare)
animal_model <- dat |> filter(str_detect(secondary_theory, 'animal')) |> 
  robumeta::robu(formula = d ~ 1, studynum = unique_study_id, 
                 var.eff.size = var_d, modelweights = 'CORR', small = TRUE)
# red and processed meat model
rpmc_model <- RPMC |> 
  robumeta::robu(formula = d ~ 1, studynum = unique_study_id, 
                 var.eff.size = var_d, modelweights = 'CORR', small = TRUE)

# Extract results for each model
overall_results <- extract_model_results("Overall")
rpmc_results <- extract_model_results(data = RPMC, approach_name = "Overall")

choice_results <- extract_model_results("Choice Architecture", "theory")
psychology_results <- extract_model_results("Psychology", "theory", FALSE)
persuasion_results <- extract_model_results("Persuasion", "theory", FALSE)
persuasion_psych_results <- extract_model_results("Persuasion & Psychology", "theory")

health_results <- extract_model_results("health", "secondary_theory")
environment_results <- extract_model_results("environment", "secondary_theory")
animal_results <- extract_model_results("animal", "secondary_theory")

