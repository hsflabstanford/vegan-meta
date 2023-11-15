#' Glass's Delta calculator

#' This function turns raw effect sizes into Cohen's D or Glass's $\Delta$,
#' depending on what measure of sample variance you use for standardization.
#' 
#' Cohen's D is standardized based on the variance estimate of the _entire_
#' sample, i.e. from treatment and control group SDs combined; Glass's $\Delta$
#' instead divides the raw effect by the standard deviation of the control
#' group only.
#' 
#' All calculations derived from Cooper, Hedges, and Valentine (2009), except 
#' for difference in proportions, which, to the best of our knowledge, Don Green
#' came up with while we were working on _Prejudice Reduction: Progress and Challenges_. 
#' We elaborate more on this estimator in the paper's appendix.
#' See https://meta-analysis.com/download/Meta-analysis%20Converting%20among%20effect%20sizes.pdf
#' for more information on calculating effect sizes.
#' 
#' If a given paper reports that effects were "not significant," that there was
#' "no effect," etc., but didn't provide enough details to calculate d/$\Delta$,
#' we recorded the result as an 'unspecified null', and here we convert all such
#' results to 0.01.

#' The function takes four inputs
#' @param stat_type the category of statistical result either reported in or derived from 
#' the paper.
#' @param stat the unstandardized effect size
#' @param sample_sd the standard deviation of the relevant sample (whenever possible, 
#' that of the control group)
#' @param n_t treatment group sample size
#' @param n_c control group sample size

d_calc <- function(stat_type , stat, sample_sd , n_t, n_c){
  # difference in differences
  if (stat_type == "d_i_d") { 
    d <- round(stat / sample_sd, digits = 3)
  }
  # difference in means
  else if (stat_type == "d_i_m") {
    d <- round(stat / sample_sd, digits = 3)
  }
  # difference in proportions
  else if (stat_type == "d_i_p") {
    d <- round(stat / sample_sd, digits = 3)
  }
  # reporting of change of SDs in text:
  else if (stat_type == "d") {
    d <- stat
  }
  
  else if (stat_type == "unspecified null") {
    d <- 0.01
  }
  
  # regression coefficient
  else if (stat_type == "reg_coef") {
    d <- round(stat / sample_sd, digits = 3)
  }
  
  # t test
  else if (stat_type == "t_test") {
    d <- round(stat * sqrt( (n_t + n_c ) / (n_t * n_c) ) , digits = 3)
  }
  # f.test
  else if (stat_type == "f_test") {
    d <- round(sqrt((stat * (n_t + n_c) ) / (n_t * n_c) ), digits = 3)
  }
  
  # odds ratio
  else if (stat_type == "odds_ratio") {
    d <- log(stat) * sqrt(3) / pi
  }
  
  # log odds ratio
  else if (stat_type == "log_odds_ratio") {
    d <- stat * sqrt(3) / pi
  }
  
  return(d)
}
