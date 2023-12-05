#' Count the Number of Studies in a Dataset or Subset
#' 
#' This function simplifies the process of counting the number of studies in a dataset
#' or a subset by avoiding repetitive use of `summarise('N (studies)' = n_distinct(unique_study_id))`.
#' 
#' @param dat The dataset or subset.
#' @return A tibble with the count of distinct studies.
#'
study_count <- function(dat) {
  result <- dat %>%
    summarise('N (studies)' = n_distinct(unique_study_id))
  
  return(result)
}
