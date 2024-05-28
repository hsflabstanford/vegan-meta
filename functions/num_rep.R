#' Convert single-digit numbers to words
#'
#' This function checks a numeric input. If the input is a single-digit number (0 to 9),
#' it converts the number to the corresponding word. If the input has two or more digits,
#' the function returns the number as is.
#'
#' @param num A numeric value to be checked and potentially converted.
#' @return A character string representing the word for single-digit numbers or the number itself for two or more digits.
#' @examples
#' convert_number_to_word(3)
#' convert_number_to_word(12)
#' convert_number_to_word(0)
#' @export
num_rep <- function(num) {
  if (!is.numeric(num)) {
    stop("Input must be numeric.")
  }
  
  # Create a vector of words for single-digit numbers
  words <- c("zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine")
  
  # Check if the number is a single digit
  if (num >= 0 && num <= 9 && num %% 1 == 0) {
    cat(words[num + 1]) # Print the corresponding word without quotes
  } else {
    cat(as.character(num)) # Print the number without quotes
  }
}
