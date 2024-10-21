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

meta_result_formatter <-function(model){
  model |>
    mutate(
      formatted = sprintf("%.4f%s (%.4f)", Delta,
                          case_when(is.na(pval)~"",
                                    as.numeric(pval) < 0.001 ~ "***",
                                    as.numeric(pval) < 0.01 ~ "**",
                                    as.numeric(pval) < 0.05 ~ "*",
                                    TRUE ~ ""),
                          se)) |> 
    pull(formatted)
}