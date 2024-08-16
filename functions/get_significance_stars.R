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
