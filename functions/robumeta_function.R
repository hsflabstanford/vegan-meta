# nicely report a metafor or robumeta object with optional suffix to denote which model

# in case yi's have been transformed, applies function .transformation to put Mhat and its CI on interpretable scale (e.g., set .transformation = function(x) exp(x) if yi's are log-RRs)

# **Shat and its CI will NOT be transformed

report_meta = function(.mod,
                       
                       .mod.type = "rma",  # "rma" or "robu"
                       
                       .transformation = function(x) x, 
                       
                       .transformed.scale.name = "",  # e.g., "RR" if you set .transformation = exp
                       
                       .analysis.label = "" ) {
  
  
  
  if ( !is.null(.mod) ) {
    
    
    
    
    
    if ( .mod.type == "rma" ) {
      
      tau.CI = tau_CI(.mod)
      
      .res = data.frame( .transformation(.mod$b),
                         
                         .transformation(.mod$ci.lb),
                         
                         .transformation(.mod$ci.ub),
                         
                         
                         
                         .mod$pval,
                         
                         
                         
                         sqrt(.mod$tau2),
                         
                         tau.CI[1],
                         
                         tau.CI[2] )
      
    }
    
    
    
    
    
    if ( .mod.type == "robu" ) {
      
      
      
      # catch possibility that tau.sq is NULL, which should only happen if
      
      #  you passed userweights to robu
      
      tau = ifelse( is.null(.mod$mod_info$tau.sq),
                    
                    NA,
                    
                    sqrt(.mod$mod_info$tau.sq) )
      
      
      
      .res = data.frame( .transformation(.mod$b.r),
                         
                         .transformation(.mod$reg_table$CI.L),
                         
                         .transformation(.mod$reg_table$CI.U),
                         
                         
                         
                         
                         
                         .mod$reg_table$prob,
                         
                         
                         
                         tau,
                         
                         NA,
                         
                         NA )
      
    }
    
    
    
  } else {
    
    .res = data.frame( rep(NA, 6) )
    
  }
  
  
  
  # rename columns
  
  names(.res) = c("Mhat", "MLo", "MHi", "MPval",
                  
                  "Shat", "SLo", "SHi")
  
  
  
  .res = .res %>% add_column(.before = 1,
                             
                             Analysis = .analysis.label)
  
  
  
  .res$MhatScale = .transformed.scale.name
  
  
  
  
  
  # names(.res) = paste( c("Mhat", "MLo", "MHi", "MPval",
  
  #                        "Shat", "SLo", "SHi"), .suffix, sep = "" )
  
  row.names(.res) = NULL
  
  
  
  #return( list(stats = .res) )
  
  
  
  return( .res )
  
}
