# Overall
model <- dat |> map_robust()

# Nudge
choice_model <- dat |> filter(str_detect(theory, 'choice architecture')) |> map_robust()

# Norms
norms_model <- dat |> filter(theory == 'norms') |> map_robust()

# Persuasion Overall
persuasion_model <- dat |> filter(theory == 'persuasion') |> map_robust()

# Norms + Persuasion
norms_persuasion_model <- dat |> filter(theory == 'norms & persuasion') |> map_robust()

# Persuasion (Health)
health_model <- dat |> filter(str_detect(secondary_theory, 'health')) |> map_robust()

# Persuasion (Environment)
environment_model <- dat |> filter(str_detect(secondary_theory, 'environment')) |> map_robust()

# Persuasion (Animal Welfare)
animal_model <- dat |> filter(str_detect(secondary_theory, 'animal')) |> map_robust()

# red and processed meat model
rpmc_model <- RPMC |> map_robust()