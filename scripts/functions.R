#' functions
source('./functions/d_calc.R')
source('./functions/map_robust.R')
source('./functions/meta_result_formatter.R')
source('./functions/meta_table_maker.R')
source('./functions/study_count.R')
source('./functions/sum_tab.R')
source('./functions/sum_lm.R')
source('./functions/var_d_calc.R')
source('./functions/utils.R')

# and one package copied directly from plyr to avoid conflicts between 
# dplyr & plyr
round_any = function(x, accuracy, f=round){f(x/ accuracy) * accuracy}
