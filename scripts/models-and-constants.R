# Model
model <- robumeta::robu(formula = d ~ 1, data = dat, studynum = unique_study_id, 
                        var.eff.size = var_d, modelweights = 'CORR', small = TRUE)


# key results 
overall_results <- extract_model_results()

rpmc_results <- RPMC |> extract_model_results()

choice_results <- dat |> filter(theory == 'Choice Architecture') |> extract_model_results() 

persuasion_results <- dat |> filter(theory == 'Persuasion') |> extract_model_results() 

psych_results <- dat |> filter(theory == 'Psychology') |> extract_model_results()

psych_persuasion_results <- dat |> filter(theory == 'Persuasion & Psychology') |> extract_model_results() 

animal_welfare_results <- dat |> filter(str_detect(secondary_theory, 'animal welfare')) |> extract_model_results() 

environment_results <- dat |> filter(str_detect(secondary_theory, 'environment')) |> extract_model_results() 

health_results <- dat |> filter(str_detect(secondary_theory, 'health')) |> extract_model_results() 

# constants
num_papers <- as.numeric(max(dat$unique_paper_id))
num_studies <- as.numeric(max(dat$unique_study_id))
num_interventions <- as.numeric(nrow(dat))

n_total <- noquote(format(round_to(x = sum(dat$n_c_total_pop) + sum(dat$n_t_total_pop), 
                                   accuracy = 1000, direction = "down"),
                          big.mark = ",", scientific = FALSE))

decade_tab <- dat |> group_by(unique_paper_id) |>  slice(1) |>  ungroup() |> count(decade)

RPMC_papers <- as.numeric(max(RPMC$unique_paper_id))
RPMC_studies <- as.numeric(max(RPMC$unique_study_id))