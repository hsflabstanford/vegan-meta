extract_model_results <- function(data = dat, approach_name = "Overall") {
  
  # Run the robumeta::robu model on the provided data
  model <- robumeta::robu(
    formula = d ~ 1,
    data = data,
    studynum = unique_study_id,
    var.eff.size = var_d,
    modelweights = 'CORR',
    small = TRUE
  )
  
  # Construct the results tibble directly
  tibble(
    Approach = approach_name,
    N_studies = length(unique(model$X.full$study)),
    N_estimates = nrow(model$data.full),
    Delta = round(model$reg_table$b.r, 2),
    SE = round(model$reg_table$SE, 2),
    CI = paste0("[", round(model$reg_table$CI.L, 2), ", ", round(model$reg_table$CI.U, 2), "]"),
    p_val = sub("^0\\.", ".", format(round(model$reg_table$prob, 3), scientific = FALSE)),
    tau = round(sqrt(model$mod_info$tau.sq), 3)  # Ensures 'tau' is a scalar
  )
}
