#' Create a formatted table using kable and optionally add a footnote
#'
#' This function generates a table using `kable` from the `knitr` package, styled with `kableExtra`.
#' It allows the inclusion of a footnote about significance levels if required.
#'
#' @param data A data frame containing the data to be displayed in the table.
#' @param format The format of the output table, default is "latex".
#' @param booktabs Logical, whether to use booktabs style in LaTeX tables.
#' @param escape Logical, whether to escape LaTeX special characters in the output.
#' @param caption The caption for the table.
#' @param label The label for the table, used for referencing.
#' @param footnote Logical, whether to include a footnote for significance levels.
#'
#' @importFrom knitr kable
#' @importFrom kableExtra kable_styling footnote
#' @return A kableExtra object representing the styled table.
#' @export
#'
#' @examples
#' data <- tibble::tibble(
#'   Approach = c("A", "B"),
#'   "N (Studies)" = c(100, 150),
#'   "Effect Size" = c(0.2, 0.3)) |>
#' meta_table_maker(data, caption = "Example Table", 
#' label = "tab:example", footnote = TRUE)
meta_table_maker <- function(data, format = "latex", booktabs = TRUE, escape = FALSE,
                             caption = "", label = "", footnote = FALSE) {
  table <- knitr::kable(data, format = format, booktabs = booktabs, escape = escape, 
                        caption = caption, label = label) |>
    kableExtra::kable_styling(latex_options = "hold_position")

  if (footnote) {
    table <- table |>
      kableExtra::footnote(
        general_title = "",
        general = "* p $<$ 0.05, ** p $<$ 0.01, *** p $<$ 0.001.",
        escape = FALSE
      )
  }
  
  return(table)
}
