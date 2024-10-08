#' Calculate Cohen's D or Glass's $\Delta$
#'
#' This function converts raw effect sizes into Cohen's D or Glass's $\Delta$,
#' based on the measure of sample variance for standardization.
#' 
#' All calculations derived from Cooper, Hedges, and Valentine (2009), except  
#' for difference in proportions, which, to the best of our knowledge, Don Green
#' came up with while we were working on _Prejudice Reduction: Progress and Challenges_. 
#' That estimator treats events as draws from a Bernoulli distribution (see
#' below for details).
#' See https://meta-analysis.com/download/Meta-analysis%20Converting%20among%20effect%20sizes.pdf
#' for more information on calculating effect sizes.

#' @param stat_type Category of statistical result reported or derived from the paper.
#' Possible values: "d_i_d" (difference in differences), "d_i_m" (difference in means),
#' "d_i_p" (difference in proportions), "d" (reporting of change of SDs in text),
#' "unspecified null", "reg_coef" (regression coefficient), "t_test" (t test),
#' "f_test" (f test), "odds_ratio" (odds ratio), "log_odds_ratio" (log odds ratio),
#' or "z" (z test")
#' @param stat Unstandardized effect size.
#' @param sample_sd Standard deviation of the relevant sample (preferably of the control group).
#' @param n_t Treatment group sample size.
#' @param n_c Control group sample size.
#'
#' @return Cohen's D or Glass's $\Delta$ value.
#'
d_calc <- function(stat_type, stat, sample_sd, n_t, n_c) {
  #' Calculate Cohen's D or Glass's $\Delta$ based on effect size and sample SD
  if (stat_type == "d_i_d" || stat_type == "d_i_m" || stat_type == "reg_coef" ||
      stat_type == "beta") {
    d <- round(stat / sample_sd, digits = 5)
  } else if (stat_type == "d") {
    #' Directly use the reported change of SDs
    d <- stat
  } else if (stat_type == "unspecified_null" || 
             stat_type == "unspecified null") {
    #' Set an 'unspecified null' result to a default small value
    d <- 0.01
  } else if (stat_type == "t_test") {
    #' Calculate Cohen's D for t test
    d <- round(stat * sqrt((n_t + n_c) / (n_t * n_c)), digits = 5)
  } else if (stat_type == "f_test") {
    #' Calculate Cohen's D for f test
    d <- round(sqrt((stat * (n_t + n_c)) / (n_t * n_c)), digits = 5)
  } else if (stat_type == "eta_squared") {
    #' Calculate Cohen's D for eta_squared
    d <- round(sqrt(stat) / sqrt(1 - stat), digits = 5)
  } else if (stat_type == "odds_ratio") {
    #' Calculate Cohen's D for odds ratio
    d <- log(stat) * sqrt(3) / pi
  } else if (stat_type == "log_odds_ratio") {
    #' Calculate Cohen's D for log odds ratio
    d <- stat * sqrt(3) / pi
  } else if (stat_type == 'd_i_p') {
    #' Calculate Glass's Delta for difference in proportions
    #' "SD" as an input is a misnomer here; input the _proportion_ of the incident
    #' in the control group as the variance estimate, and then this calculator
    #' treats that as draws from a bernoulli distribution. Variance ouf Bernoulli
    #' is $p(1-p)$; so the estimator in total is 
    #'  $$\Delta = \frac{p_{1} - p_{2}}{\sqrt{p_{2} * (1 - p_{2)}}}$$
    d = stat / (sqrt(sample_sd * (1 - sample_sd)))
  } else if (stat_type == "z") {
    d = stat / sqrt(n_t + n_c)
  } else {
    #' Default value if stat_type is unrecognized
    d <- NA
  }
  
  return(d)
}
