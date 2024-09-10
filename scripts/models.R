# Overall
model <- dat |> map_robust()

# Nudge
choice_model <- dat |> filter(str_detect(theory, 'choice architecture')) |> map_robust()

# psychology
psychology_model <- dat |> filter(theory == 'psychology') |> map_robust()

# Persuasion Overall
persuasion_model <- dat |> filter(theory == 'persuasion') |> map_robust()

# choice and persuasion
choice_persuasion_model <- dat |> filter(theory == 'choice architecture & persuasion') |> map_robust()

# psychology + Persuasion
psychology_persuasion_model <- dat |> filter(theory == 'persuasion & psychology') |> map_robust()

# Persuasion (Health)
health_model <- dat |> filter(str_detect(secondary_theory, 'health')) |> map_robust()

# Persuasion (Environment)
environment_model <- dat |> filter(str_detect(secondary_theory, 'environment')) |> map_robust()

# Persuasion (Animal Welfare)
animal_model <- dat |> filter(str_detect(secondary_theory, 'animal')) |> map_robust()

# red and processed meat model
rpmc_model <- RPMC |> map_robust()