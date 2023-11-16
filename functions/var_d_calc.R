#' Calculate Variance of Cohen's D or Glass's $\Delta$
#' 
#' This function computes the variance of Cohen's D or Glass's $\Delta$ based on the provided effect size
#' and sample sizes, following the equation from Cooper, Hedges, and Valentine (2009).
#'
#' @param d Standardized effect size calculated using `d_calc.R`.
#' @param n_t Treatment sample size.
#' @param n_c Control group sample size.
#' @return Variance of Cohen's D or Glass's $\Delta$.
#'

var_d_calc <- function(d, n_t, n_c) {
  # Calculate unstandardized variance of d
  ust_var_d <- ((n_t + n_c) / (n_t * n_c)) + ((d^2) / (2 * (n_t + n_c)))
  
  # Calculate Hedge's g correction factor
  hedge_g <- 1 - (3 / ((4 * (n_t + n_c - 2)) - 1))
  
  # Calculate variance of Cohen's D or Glass's Delta
  result <- round((hedge_g^2) * ust_var_d, digits = 3)
  return(result)
}
