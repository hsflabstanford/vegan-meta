#' Generate a meta forest plot using ggplot2
#'
#' This function generates a meta forest plot using ggplot2 based on the provided data and category variable.
#'
#' @param data A dataframe containing the data for plotting.
#' @param category_var The variable used for color categorization in the plot.
#' @param title The title of the plot (default is "Vegan meta forest plot").
#' 
#' @return A ggplot2 object representing the meta forest plot.
#'
#' @import ggplot2
#' @importFrom rlang ensym enexpr
#' @importFrom purrr |> 
#' @importFrom stringr str_detect
#' @importFrom metafor map_robust
#' @importFrom gridExtra unit
#' @importFrom scales scale_x_continuous scale_y_discrete
#' @importFrom grid grid.draw
#' @importFrom gridExtra arrangeGrob
#' @importFrom ggplot2 ggplot aes geom_point geom_errorbarh geom_vline scale_x_continuous scale_y_discrete 
#' @importFrom ggplot2 ggtitle theme_minimal theme element_text labs
#'
#' @examples
#' # Load necessary libraries
#' library(ggplot2)
#' library(rlang)
#' library(purrr)
#' library(stringr)
#' library(metafor)
#'
#' # Example usage
#' dat <- data.frame(
#'   study_name = c("Study 1", "Study 2", "Study 3"),
#'   d = c(0.1, 0.2, 0.3),
#'   se_d = c(0.05, 0.06, 0.07),
#'   category_var = c("A", "B", "A")
#' )
#' gg_meta_plot(dat, category_var)
#'
gg_meta_plot <- function(data, category_var, title = "Vegan meta forest plot") {
  # Ensure that category_var is a symbol
  convert_underscore_to_space <- function(string) {
    gsub("_", " ", string)
  }
  category_var <- ensym(category_var)
  
  # Convert underscores to spaces in the legend title
  category_label <- convert_underscore_to_space(as.character(rlang::enexpr(category_var)))
  
  # Use !! to force evaluation of category_var within dplyr verbs
  plot <- data |>
    ggplot(aes(y = study_name, x = d, 
               xmin = d - (1.96 * se_d),
               xmax = d + (1.96 * se_d))) + 
    geom_point(size = 1, aes(color = !!category_var)) +
    geom_errorbarh(height = .1, aes(color = !!category_var)) +
    geom_vline(xintercept = 0, color = "black", alpha = .5) +
    geom_vline(xintercept = (data |> map_robust())$Delta, 
               color = 'black', lty = 'dashed') +
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
