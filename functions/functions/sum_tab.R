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
#'
#' @examples
#' # Assume `my_data` is a data frame containing a column named "theory"
#' my_data |> sum_tab(theory)
#'
#' @importFrom dplyr pull
#' @importFrom rlang !! enquo

sum_tab <- function(data, var_name) {
  var_name <- enquo(var_name)
  table(data |> pull(!!var_name))
}

