forest_meta_function <- function(x) {
  result <- rma.uni(yi = x$d, vi = x$var_d, method = 'EE', slab = paste0(x$author, x$year))
  tibble(
    author = x$author[1],        
    year = x$year[1],            
    theory = x$theory[1],        
    estimate = as.numeric(result$b),
    se = result$se,
    var = result$vb,
    ci.lb = result$ci.lb,        
    ci.ub = result$ci.ub,        
  )
}
