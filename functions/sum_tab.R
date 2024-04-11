#' Create a Frequency Table for a Variable in a Data Frame
#'
#' This function generates a frequency table for a specific variable in a dataset.
#'
#' It uses enquo() to capture the unquoted variable name and !! to unquote it
#' within the function.
#' @param data A data frame or tibble.
#' @param var_name The name of the variable/column to generate the frequency table.
#'
#' @return A table showing the frequency of each unique value in the specified variable.
#'#'
#' @importFrom dplyr pull
#' @importFrom rlang !! enquo
#' @export

sum_tab <- function(data, var_name) {
  var_name <- enquo(var_name)
  freq_table <- table(data |> pull(!!var_name))
  return(freq_table)
}
