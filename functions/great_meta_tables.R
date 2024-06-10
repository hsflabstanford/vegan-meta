#' Generate a GT Table with Custom Formatting
#' Just making great meta-analysis tables! and dealing with Eddie Munster

gmt <- function(dat, title = "table XXX", subtitle = NULL, col_name, 
                col_label = "Theory", tab_source_note = NULL) {
  # Capture the column name as a quosure
  col_name <- dplyr::enquo(col_name)
  
  get_significance_stars <- function(pval) {
    sapply(pval, function(x) {
      if (is.na(x)) {
        ""
      } else if (x < .001) {
        "***"
      } else if (x < .01) {
        "**"
      } else if (x < .05) {
        "*"
      } else {
        ""
      }
    })
  }
  
  tab <- dat |>
    dplyr::mutate(pval = as.numeric(pval)) |>
    dplyr::mutate(
      stars = get_significance_stars(pval),
      `Glass's ∆ (se)` = sprintf("%.3f%s (%.3f)", Delta, stars, se)
    ) |>
    dplyr::select(!!col_name, N_unique, `Glass's ∆ (se)`) |>
    gt::gt() |>
    gt::tab_header(
      title = title,
      subtitle = subtitle
    ) |>
    gt::cols_label(
      !!col_name := col_label,
      N_unique = "N (Studies)",
      `Glass's ∆ (se)` = gt::md("Glass's ∆ (se)")
    )
  
  # Add the tab_source_note if provided
  if (!is.null(tab_source_note)) {
    if (isTRUE(tab_source_note)) {
      tab <- tab |>
        gt::tab_source_note(
          source_note = "* < 0.05, ** < 0.01, *** < 0.001."
        )
    } else {
      tab <- tab |>
        gt::tab_source_note(
          source_note = tab_source_note
        )
    }
  }
  
  return(tab)
}
