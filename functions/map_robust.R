map_robust <- function(x, model = "CORR") {
  # Same function as before, but with additional error checks
  tryCatch({
    format_pval <- function(p) {
      if (is.na(p)) {
        NA
      } else if (p < 0.0001) {
        "< .0001"
      } else {
        formatted_p <- formatC(p, format = "f", digits = 4)
        if (p < 1) {
          gsub("^0\\.", ".", formatted_p)
        } else {
          formatted_p
        }
      }
    }
    
    if (length(unique(x$unique_study_id)) == 1) {
      Delta <- round(mean(x$d), 3)
      se <- round(mean(x$se_d),3)
      pval <- NA
      return(tibble::tibble(N_interventions = nrow(x),
                            N_studies = length(unique(x$unique_study_id)),
                            Delta = Delta, se = se, pval = pval))
    } else {
      if (model == "CORR" || model == "HIER") {
        result <- robumeta::robu(formula = d ~ 1, data = x, 
                                 studynum = unique_study_id, 
                                 var.eff.size = var_d, modelweights = model)
        output <- data.frame(
          N_interventions = result$M,
          N_studies = result$N,
          Delta = round(result$reg_table$b.r, 4),
          se = round(result$reg_table$SE, 4),
          pval = format_pval(result$reg_table$prob)) |> 
          tibble::as_tibble()
      } else if (model == "RMA") {
        result <- metafor::rma(yi = d, vi = var_d, data = x)
        output <- data.frame(
          N_interventions = nrow(x),
          N_studies = length(unique(x$unique_study_id)),
          Delta = round(result$b, 4),
          se = round(result$se, 4),
          pval = format_pval(result$pval)) |> 
          tibble::as_tibble()
      } else {
        stop("Invalid model specified. Choose 'CORR', 'HIER', or 'RMA'.")
      }
      
      return(output)
    }
  }, error = function(e) {
    warning("Error in map_robust: ", e$message)
    return(tibble::tibble(N_interventions = NA, N_studies = NA, Delta = NA, se = NA, pval = NA))
  })
}
