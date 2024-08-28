#' Generate LaTeX Comment
#'
#' This function outputs a LaTeX comment, which will only be recognized when generating PDF documents.
#' It does nothing if the output format is HTML.
#'
#' @param comment_text The text to be included in the LaTeX comment.
#' 
#' @return A LaTeX comment that will be inserted in the document.
#' @export
latex_comment <- function(comment_text) {
  if (knitr::is_latex_output()) {
    cat(paste0("% ", comment_text, "\n"))
  }
}