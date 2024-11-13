# -------------------------------
# 1. Forest Data Preparation
# -------------------------------

# Load necessary libraries

# Assuming 'dat' and 'model' are already defined and loaded

# Step 1.1: Split Data by 'unique_paper_id' and 'theory'
forest_data <- dat |> 
  split(dat[c("unique_paper_id", "theory")]) |>  
  map(~ if (nrow(.x) > 0) forest_meta_function(.x)) |>  # Apply meta-analysis function
  bind_rows() |>  # Combine all meta-analysis results into a single dataframe
  
  # Step 1.2: Create 'study_name' by concatenating 'author' and 'year'
  mutate(study_name = paste(author, year)) |>
  
  # Step 1.3: Reorganize columns
  select(-c(author, year)) |>  # Remove 'author' and 'year' columns
  select(study_name, everything()) |>  # Reorder columns to have 'study_name' first
  
  # Step 1.4: Add a row for Pooled estimate
  add_row(
    study_name = "Pooled estimate", 
    theory = NA,
    estimate = model$reg_table$b.r, 
    se = model$reg_table$SE,
    var = model$VR.r,
    ci.lb = model$reg_table$CI.L,
    ci.ub = model$reg_table$CI.U
  ) |> 
  
  # Step 1.5: Factorize 'theory' and Calculate 'precision'
  mutate(
    theory = factor(theory, levels = c("Choice Architecture", "Persuasion", 
                                       "Psychology", "Persuasion & Psychology")),
    precision = 1 / var  # Precision is the inverse of variance
  ) |>
  
  # Step 1.6: Arrange Data for Plotting
  arrange(theory, desc(estimate)) |>  # Sort by 'theory' and descending 'estimate'
  
  # Step 1.7: Factorize 'study_name' and Create 'combined_label' for Plotting
  mutate(
    study_name = fct_inorder(study_name),
    combined_label = fct_inorder(paste(study_name, theory, sep = " | "))
  )

# -------------------------------
# 2. Forest Plot Creation
# -------------------------------

# Create the Forest Plot
forest_plot <- forest_data |> 
  
  # Initialize ggplot with aesthetic mappings
  ggplot(aes(x = estimate, y = fct_rev(combined_label))) +
  
  # Step 2.1: Add Points for Pooled estimate
  geom_point(
    data = subset(forest_data, study_name == "Pooled estimate"), 
    size = 5, 
    shape = 18, 
    color = 'black',
    show.legend = FALSE) +  
  
  # Step 2.2: Add Error Bars for Pooled estimate
  geom_errorbarh(
    data = subset(forest_data, study_name == "Pooled estimate"), 
    aes(xmin = ci.lb, xmax = ci.ub), 
    height = 0.1, 
    color = 'black',
    show.legend = FALSE
  ) +  
  
  # Step 2.3: Add Points for Individual Studies
  geom_point(
    data = subset(forest_data, study_name != "Pooled estimate"), 
    aes(
      size = scales::rescale(precision, to = c(0.5, 3)),  # Scale precision for point size
      color = theory  # Color by 'theory'
    ), 
    shape = 1  # Hollow circles
  ) +  
  
  # Step 2.4: Add Error Bars for Individual Studies
  geom_errorbarh(
    data = subset(forest_data, study_name != "Pooled estimate"), 
    aes(xmin = ci.lb, xmax = ci.ub, color = theory),
    height = 0.1
  ) +
  
  # Step 2.5: Add Reference Lines
  geom_vline(xintercept = 0, color = "black", alpha = 0.5) +  # Line at Delta = 0
  geom_vline(
    xintercept = model$reg_table$b.r, 
    color = 'black', 
    lty = 'dashed'
  ) +  # Dashed line for observed overall effect
  
  # Step 2.6: Apply Minimal Theme and Customize
  theme_minimal() +
  theme(
    axis.text.y= ggtext::element_markdown(),  # Allow markdown in y-axis labels
    plot.title = element_text(hjust = 0.5, face = "bold"),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10),
    axis.line = element_line(colour = "black"),
    plot.caption = element_text(hjust = 0)
  ) +  
  
  # Step 2.7: Customize Y-axis Labels
  scale_y_discrete(labels = function(x) {
    x <- gsub(" \\| .*", "", x)  # Remove theory from label
    ifelse(x == "Pooled estimate", "<b>Pooled estimate</b>", x)  # Bold Pooled estimate label
  }) +
  
  # Step 2.8: Customize X-axis
  scale_x_continuous(name = "SMD") +
  
  # Step 2.9: Add Labels and Captions
  labs(color = "Theory", y = NULL) + # Remove Y-axis label
  
  # Step 2.10: Adjust Legends and Guides
  scale_color_manual(
    values = c("red", "green", "blue", "purple")) +
  guides(size = "none") + # remove size legend so it doesn't appear in caption
  guides(color = guide_legend(nrow = 2, byrow = TRUE)) +
  # Step 2.11: Put legend at the bottom so the graph can be wider
  theme(
    legend.position = "bottom")
