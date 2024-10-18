# this section is complex and brittle. optional TODO: make it general & robust

# Figure 1
plot_dat <- dat |> 
  mutate(lower_bound = d - (1.96 * se_d),
         upper_bound = d + (1.96 * se_d)) |>
  select(author, year, d, se_d, lower_bound, upper_bound, theory) |> 
  add_row(author = "RE Estimate", year = NA, d = model$Delta, 
          lower_bound = model$Delta - (1.96 * model$se),
          upper_bound = model$Delta + (1.96 * model$se), 
          theory = 'NA') |>
  mutate(study_name = if_else(author == "RE Estimate", 
                              "RE Estimate", paste0(author, " ", year))) |>
  select(study_name, d, se_d, lower_bound, upper_bound, theory)

# Get unique study names excluding "RE Estimate"
unique_papers <- unique(plot_dat$study_name[plot_dat$study_name != "RE Estimate"])

# Append "RE Estimate" to the end of the list
ordered_levels <- c(unique_papers, "RE Estimate")

# Set this order to study_name
plot_dat$study_name <- reorder(factor(plot_dat$study_name, levels = ordered_levels), desc(plot_dat$se_d))

forest_plot <- plot_dat |> ggplot(aes(x = d, y = study_name)) +
  geom_point(data = subset(plot_dat, study_name == "RE Estimate"), 
             size = 5, shape = 18) + # shape = 5 for a transparent diamond 
  geom_point(data = subset(plot_dat, study_name != "RE Estimate"), 
             aes(color = theory), size = 3, shape = 18) +
  geom_errorbarh(data = subset(plot_dat, study_name != "RE Estimate"), 
                 aes(xmin = lower_bound, xmax = upper_bound, color = theory),
                 height = .1) +
  geom_vline(xintercept = 0, color = "black", alpha = .5) +
  geom_vline(xintercept = model$Delta, 
             color = 'black', lty = 'dashed') +
  theme_minimal() +
  theme(axis.text.y = element_markdown()) +  # Apply HTML formatting to y-axis text
  scale_y_discrete(labels = bold_labels) +    # Use custom function for y-axis labels
  scale_x_continuous(name = expression(paste("Glass's", " ", Delta))) +
  labs(color = "Theory") +
  ylab("Study") +
  ggtitle("MAP reduction forest plot") +
  theme(plot.title = element_text(hjust = 0.5,
                                  face = "bold"),
        legend.title = element_text(size = 15),
        legend.text = element_text(size = 12),
        axis.line = element_line(colour = "black")) 

# Supplementary Figure 
supplementary_figure <- dat |> 
  ggplot(aes(x = se_d, y = d)) +
  geom_point(size = 2, aes(color = theory, shape = pub_status)) + 
  stat_smooth(method = 'lm', se = FALSE, lty = 'dotted') +
  scale_color_manual(values = c("Psychology" = "blue",
                                "Persuasion & Psychology" = "red",
                                "Choice Architecture" = "green",
                                "Persuasion" = "purple"))+
  scale_shape_manual(values = c("Advocacy Organization" = 16,  # Use appropriate shapes
                                "Journal article" = 17,
                                "Thesis" = 15,
                                "Preprint" = 18),
                     labels = c("advocacy_org" = "Advocacy organization",
                                "Journal article" = "Journal article",
                                "Thesis" = "Thesis")) +
  labs(x = "Standard Error", y = "Effect Size", color = "Approach", shape = "Publication venue") +
  ggtitle("Figure S1: Test for publication bias") +
  theme_minimal()
