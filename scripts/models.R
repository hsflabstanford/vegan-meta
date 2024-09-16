# Overall
model <- dat |> map_robust()

# Nudge
choice_model <- dat |> filter(str_detect(theory, 'Choice Architecture')) |> map_robust()

# psychology
psychology_model <- dat |> filter(theory == 'Psychology') |> map_robust()

# Persuasion Overall
persuasion_model <- dat |> filter(theory == 'Persuasion') |> map_robust()

# persuasion plus
persuasion_psychology_model <- dat |> filter(str_detect(theory, "Persuasion & Psychology")) |> map_robust()

# Persuasion (Health)
health_model <- dat |> filter(str_detect(secondary_theory, 'health')) |> map_robust()

# Persuasion (Environment)
environment_model <- dat |> filter(str_detect(secondary_theory, 'environment')) |> map_robust()

# Persuasion (Animal Welfare)
animal_model <- dat |> filter(str_detect(secondary_theory, 'animal')) |> map_robust()

# red and processed meat model
rpmc_model <- RPMC |> map_robust()



