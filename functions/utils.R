bold_labels <- function(x) {
  ifelse(x == "RE Estimate", "<b>RE Estimate</b>", x)
}

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

round_to <- function(x, accuracy, f = round) {
  f(x / accuracy) * accuracy
}
# handy shortcut 
mr <- meta_result_formatter

# something for first descriptive table
summarize_to_tibble <- function(data, condition, group_col_name, sort_desc = TRUE) {
  result <- data |>
    mutate({{ group_col_name }} := case_when(!!!condition)) |>  # Apply the condition to create the grouping variable
    group_by({{ group_col_name }}) |>
    summarise(study_count = n_distinct(unique_study_id)) |>
    mutate(Category = as.character({{ group_col_name }}), `Number of Studies` = study_count, .keep = "none")
  
  if (sort_desc) {
    result <- result |>
      arrange(desc(`Number of Studies`))  # Sort by Number of Studies if sort_desc is TRUE
  }
  
  return(result)
}
