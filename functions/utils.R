# little ones 
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
# noting that I haven't figured out what to do with this one yet
# but the problem I'm trying to solve is that R objects in the text
# generally return integers (or whatever), but the grammatical conventions
# of using integers vs spelled out numbers depend on the place in the text
convert_number_to_words <- function(number) {
  if (number >= 0) {
    return(english(number))
  } else {
    return(as.character(number))
  }
}
