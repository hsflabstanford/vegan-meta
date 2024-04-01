#' Generate a meta forest plot using ggplot2
#'
#' This function generates a meta forest plot using ggplot2 based on the provided data and category variable.
#'
#' @param data A dataframe containing the data for plotting.
#' @param category_var The variable used for color categorization in the plot. uses 'theory' by default.
#' @param title The title of the plot (default is "Vegan meta forest plot").
#' 
#' @return A ggplot2 object representing the meta forest plot.
#'
#' @importFrom ggplot2 ggplot aes geom_point geom_errorbarh geom_vline scale_x_continuous scale_y_discrete 
#' @importFrom ggplot2 ggtitle theme_minimal theme element_text labs
#' @importFrom rlang ensym enexpr
#' @importFrom stringr str_detect
#' @importFrom metafor map_robust
#' @importFrom gridExtra unit
#' @importFrom scales scale_x_continuous scale_y_discrete
#' @importFrom grid grid.draw
#' @importFrom gridExtra arrangeGrob
#'
#' @examples
#' # Load necessary libraries
#' library(ggplot2)
#' library(rlang)
#' library(purrr)
#' library(stringr)
#' library(metafor)
#'
gg_meta_plot <- function(data, category_var = theory, 
                         title = "Vegan meta forest plot") {
  if (!"study_name" %in% names(data)) {
    # If study_name not detected, create it
    data$study_name <- reorder(as.factor(paste0(data$author, " ", data$year)), desc(data$se_d))
  }
    
  # Ensure that category_var is a symbol
  convert_underscore_to_space <- function(string) {
    gsub("_", " ", string)
  }
  category_var <- ensym(category_var)
  
  # Convert underscores to spaces in the legend title
  category_label <- convert_underscore_to_space(as.character(rlang::enexpr(category_var)))
  # add overall delta estimate
  delta <- map_robust(data)$Delta[1]

  #. build first portion, the studies
  # Use !! to force evaluation of category_var within dplyr verbs
  plot <- data |>
    ggplot(aes(y = study_name, x = d, 
               xmin = d - (1.96 * se_d),
               xmax = d + (1.96 * se_d))) + 
    geom_point(size = 1, aes(color = !!category_var)) +
    geom_errorbarh(height = .1, aes(color = !!category_var)) +
    geom_vline(xintercept = 0, color = "black", alpha = .5) +
    geom_vline(xintercept = (data |> map_robust())$Delta, 
               color = 'black', lty = 'dashed')
  
  # build second portion, the random effects model
  min_y <- min(ggplot_build(plot)$data[[1]]$y)
  max_y <- max(ggplot_build(plot)$data[[1]]$y)
  plot <- plot + 
    geom_point(y = min_y - 1 , x = delta, size = 3, shape = 5) + 
    coord_cartesian(ylim = c(min_y - 1.5, max_y), clip = "off")
    
    # build third portion, aesthetics
    plot <- plot + 
      scale_x_continuous(name = expression(paste("Glass's", " ", Delta))) +
    scale_y_discrete() +
    ylab("Study") +
    ggtitle(title) + 
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5,
                                    face = "bold"),
          legend.title = element_text(size = 15),
          legend.text = element_text(size = 12)) +
    labs(color = category_label)
  
  return(plot)
}
dat |> gg_meta_plot()
