map_robust <- function(x, model = "CORR") {
  # Same function as before, but with additional error checks
  tryCatch({
    format_pval <- function(p) {
      if (is.na(p)) {
        return(NA)
      } else if (p < 0.0001) {
        return("< .0001")
      } else {
        formatted_p <- formatC(p, format = "f", digits = 4)
        if (p < 1) {
          return(gsub("^0\\.", ".", formatted_p))
        } else {
          return(formatted_p)
        }
      }
    }

    round_to <- function(x, accuracy, f = round) {
      f(x / accuracy) * accuracy
    }

    calculate_n_total <- function(data) {
      summarise(data, n_total = round_to(sum(n_t_total_pop + n_c_total_pop), 100, floor)) |>
        pull(n_total)
    }

    N_total <- calculate_n_total(x)

    if (length(unique(x$unique_study_id)) == 1) {
      Delta <- round(mean(x$d), 3)
      se <- round(mean(x$se_d), 3)
      pval <- NA
      output <- tibble(
        N_interventions = nrow(x),
        N_studies = length(unique(x$unique_study_id)),
        N_subjects = N_total,
        Delta = Delta,
        se = se,
        pval = pval
      )
    } else {
      if (model == "CORR" || model == "HIER") {
        result <- robumeta::robu(formula = d ~ 1, data = x, 
                                 studynum = unique_study_id, 
                                 var.eff.size = var_d, 
                                 modelweights = model)
        output <- tibble(
          N_interventions = result$M,
          N_studies = result$N,
          N_subjects = N_total,
          Delta = round(result$reg_table$b.r, 4),
          se = round(result$reg_table$SE, 4),
          pval = format_pval(result$reg_table$prob)
        )
      } else if (model == "RMA") {
        result <- metafor::rma(yi = d, vi = var_d, data = x)
        output <- tibble(
          N_interventions = nrow(x),
          N_studies = length(unique(x$unique_study_id)),
          N_subjects = N_total,
          Delta = round(result$b, 4),
          se = round(result$se, 4),
          pval = format_pval(result$pval)
        )
      } else {
        stop("Invalid model specified. Choose 'CORR', 'HIER', or 'RMA'.")
      }
    }
    
    return(output)
  }, error = function(e) {
    message("Error: ", e$message)
    return(NULL)
  })
}

 