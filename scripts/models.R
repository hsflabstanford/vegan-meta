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
overall_results <- extract_model_results(model, "Overall")
choice_results <- extract_model_results(choice_model, "Choice Architecture")
psychology_results <- extract_model_results(psychology_model, "Psychology")
persuasion_results <- extract_model_results(persuasion_model, "Persuasion")
persuasion_psych_results <- extract_model_results(persuasion_psychology_model, "Psychology & Persuasion")

health_results <- extract_model_results(health_model, "Health")
environment_results <- extract_model_results(environment_model, "Environment")
animal_results <- extract_model_results(animal_model, "Animal Welfare")

