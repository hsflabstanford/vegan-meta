#' Prints the core results from summary(lm(y~x)) in a neat table
#' 
#' This function translates summary(lm()) into a function that can be piped to,
#' e.g. `dat |> filter(some_var) |> sum_lm()`
#' or `dat |> split(~some_var) |> map(sum_lm)`,
#' and prints out the results in a neat, easy-to-transcribe table.
#' 

sum_lm <- function(dataset = dat, y = d, x = se_d, coefs_only = T, dgts = 5) {
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    message("Install dplyr before you run this function.")
    return(invisible())
  }
  y <- dplyr::enexpr(y)
  x <- dplyr::enexpr(x)
  print_obj <- summary(lm(formula = as.formula(paste(y, '~', x)), 
                          data = dataset))
  if (coefs_only) round(print_obj$coefficients, digits = dgts)
  
  else print_obj
}
