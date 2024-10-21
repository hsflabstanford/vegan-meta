forest_data <- dat |> 
  split(dat[c("unique_paper_id", "theory")]) |>  
  map( ~if (nrow(.x) > 0) forest_meta_function(.x)) |> 
  bind_rows() |> 
  mutate(study_name = paste(author, year)) |>
  select(-c(author, year)) |>
  select(study_name, everything()) |> 
  add_row(study_name = "RE Estimate", 
          theory = NA,
          estimate = model$reg_table$b.r, 
          se = model$reg_table$SE,
          var = model$VR.r,
          ci.lb = model$reg_table$CI.L,
          ci.ub = model$reg_table$CI.U) |> 
  mutate(
    theory = factor(theory, levels = c("Choice Architecture", "Persuasion", 
                                       "Psychology", "Persuasion & Psychology")),
    precision = 1 / var) |>
  arrange(theory, desc(estimate)) |>  # Sort by theory and precision
  mutate(study_name = fct_inorder(study_name),
         combined_label = fct_inorder(paste(study_name, theory, sep = " | ")))

# Plot with reversed y-axis to make Choice Architecture appear at the top
forest_plot <- forest_data |> 
  ggplot(aes(x = estimate, y = fct_rev(combined_label))) +
  geom_point(data = subset(forest_data, study_name == "RE Estimate"), 
             size = 5, shape = 18, color = 'black') +  
  geom_errorbarh(data = subset(forest_data, study_name == "RE Estimate"), 
                 aes(xmin = ci.lb, xmax = ci.ub), 
                 height = .1, color = 'black') +  
  geom_point(data = subset(forest_data, study_name != "RE Estimate"), 
             aes(size = scales::rescale(precision, to = c(0.5, 3)),
                 color = theory), shape = 1) +  
  geom_errorbarh(data = subset(forest_data, study_name != "RE Estimate"), 
                 aes(xmin = ci.lb, xmax = ci.ub, color = theory),
                 height = .1) +
  geom_vline(xintercept = 0, color = "black", alpha = .5) +
  geom_vline(xintercept = model$reg_table$b.r, 
             color = 'black', lty = 'dashed') +
  theme_minimal() +
  theme(axis.text.y = element_markdown()) +  
  scale_y_discrete(labels = function(x) {
    x <- gsub(" \\| .*", "", x) 
    ifelse(x == "RE Estimate", "<b>RE Estimate</b>", x)}) +
  scale_x_continuous(name = expression(paste("Glass's", " ", Delta))) +
  labs(color = "Theory", 
  caption = 
  "Forest plot for MAP redutction studies. Each point corresponds to a fixed effects 
  meta-analysis for each paper. Papers employing multiple theoretical approaches
  are represented once per theory. Dot size is inversely proportional to variance. 
  Points are sorted within theory by effect size. A random effects meta-analysis 
  for the entire dataset is plotted at the bottom. The black line demarcates Delta = 0,
  and the dotted line is the observed overall effect.") +
  ylab(NULL) +
  guides(size = "none") +
  ggtitle("MAP reduction forest plot") +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        legend.title = element_text(size = 15),
        legend.text = element_text(size = 12),
        axis.line = element_line(colour = "black"),
        plot.caption = element_text(hjust = 0))

