
round_to <- function(x, accuracy, direction = "default") {
  f <- switch(direction,
              "up" = ceiling,
              "down" = floor,
              "default" = round)
  f(x / accuracy) * accuracy
}
