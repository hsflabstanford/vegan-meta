#' Variance of $\Delta$ calculator
#' 
#' This function calculates variance of Cohen's D or Glass's $\Delta$. 
#' The equation comes from Cooper, Hedges, and Valentine (2009).
#' @param d the standardized effect size calculated with `d_calc.R`
#' @param n_t treatment sample size
#' @param n_c control group sample size

var_d_calc <- function(d, n_t, n_c) {
  
  ust_var_d <- ((n_t + n_c) / (n_t * n_c)) +
    ((d^2) / (2 * (n_t + n_c)))
  
  hedge_g <- 1 - (3 / (4*(n_t + n_c - 2 ) - 1))
  
  return(round((hedge_g^2) * ust_var_d, digits = 3))
}
