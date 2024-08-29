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