source('./scripts/libraries.R')
source('./scripts/functions.R')
source('./scripts/load-data.R')
source('./scripts/models.R')

# Table 1
meta_table <- bind_rows(
  # Overall row
  extract_model_results(approach_name = "Overall"),
  
  # Theory-specific results with proper Approach names
  bind_rows(
    extract_model_results("Choice Architecture", "theory", data = dat, approach_name = "Choice Architecture"),
    extract_model_results("Psychology", "theory", data = dat, approach_name = "Psychology"),
    extract_model_results("Persuasion", "theory", FALSE, data = dat, approach_name = "Persuasion"),
    extract_model_results("Persuasion & Psychology", "theory", data = dat, approach_name = "Persuasion & Psychology")
  ),
  
  # Type of Persuasion-specific results with proper Approach names
  bind_rows(
    extract_model_results("animal", "secondary_theory", data = dat, approach_name = "Animal Welfare"),
    extract_model_results("environment", "secondary_theory", data = dat, approach_name = "Environment"),
    extract_model_results("health", "secondary_theory", data = dat, approach_name = "Health")
  )
) |>
  kbl(booktabs = TRUE, col.names = c("Approach", "N (Studies)", "N (Interventions)", 
                                     "Delta", "95% CIs", "p value"), 
      caption = "Meta-Analysis Results", 
      label = "table_one") |>
  kable_styling(latex_options = c("striped", "hold_position", "scale_down"), font_size = 10) |>
  pack_rows(group_label = "Theory", start_row = 2, 
            end_row = 5, latex_gap_space = "0.5em", bold = TRUE) |>
  pack_rows(group_label = "Type of Persuasion", 
            start_row = 6, 
            end_row = 8, 
            latex_gap_space = "0.5em", bold = TRUE) |>
  row_spec(0, bold = TRUE, font_size = 12)  |>  
  add_footnote("Types of persuasion Ns will not total to the Ns for persuasion overall because many studies employ multiple categories of argument.")

# Table 2
# Create the moderator_table with the new columns using extract_model_results()

# table two
moderator_table <- bind_rows(
  # Population model results
  bind_rows(
    extract_model_results("university", "population", data = dat, approach_name = "University students and staff"),
    extract_model_results("adult", "population", data = dat, approach_name = "Adults"),
    extract_model_results("young", "population", data = dat, approach_name = "Adolescents"),
    extract_model_results("all ages", "population", data = dat, approach_name = "All ages")
  ),
  
  # Country/Region model results
  bind_rows(
    extract_model_results("United States|Canada", "country", data = dat, approach_name = "North America"),
    extract_model_results("United Kingdom|Denmark|Germany|Italy|Netherlands|Sweden", "country", data = dat, approach_name = "Europe"),
    extract_model_results("worldwide|United States, United Kingdom, Canada, Australia, and other", "country", data = dat, approach_name = "Multi-region"),
    extract_model_results("Iran|Thailand", "country", data = dat, approach_name = "Asia"),
    extract_model_results("Australia", "country", data = dat, approach_name = "Australia")
  ),
  
  # Decade model results
  bind_rows(
    extract_model_results("2000s", "decade", data = dat, approach_name = "2000s"),
    extract_model_results("2010s", "decade", data = dat, approach_name = "2010s"),
    extract_model_results("2020s", "decade", data = dat, approach_name = "2020s")
  ),
  
  # Publication status model results with combined 'Preprint or Thesis'
  bind_rows(
    extract_model_results("Advocacy Organization", "pub_status", data = dat, approach_name = "Nonprofit white paper"),
    extract_model_results("Journal article", "pub_status", data = dat, approach_name = "Journal article"),
    extract_model_results("Preprint|Thesis", "pub_status", data = dat, approach_name = "Preprint or Thesis")
  ),
  
  # Delivery methods model results
  bind_rows(
    extract_model_results("article|op-ed|leaflet|flyer|printed booklet|mailed", "delivery_method", data = dat, approach_name = "Printed Materials"),
    extract_model_results("video", "delivery_method", data = dat, approach_name = "Video"),
    extract_model_results("in-cafeteria", "delivery_method", data = dat, approach_name = "In-cafeteria"),
    extract_model_results("online|internet|text|email", "delivery_method", data = dat, approach_name = "Online"),
    extract_model_results("dietary consultation", "delivery_method", data = dat, approach_name = "Dietary Consultation"),
    extract_model_results("free meat alternative", "delivery_method", data = dat, approach_name = "Free Meat Alternative")
  ),
  
  # Outcome recording model results
  bind_rows(
    extract_model_results("Y", "self_report", data = dat, approach_name = "Self reported"),
    extract_model_results("N", "self_report", data = dat, approach_name = "Objectively measured")
  )
) |>
  kbl(booktabs = TRUE, 
      col.names = c("Moderator", "N (Studies)", "N (Interventions)", "Delta", "95% CIs", "p value"),
      caption = "Moderator Analysis Results", 
      label = "table_moderator_analysis") |> 
  kable_styling(latex_options = c("striped", "hold_position", "scale_down"), 
                font_size = 10) |>
  
  # Pack rows for Population (1 to 4)
  pack_rows(group_label = "Population", start_row = 1, 
            end_row = 4, latex_gap_space = "0.5em", bold = TRUE) |>
  
  # Pack rows for Region (5 to 9)
  pack_rows(group_label = "Region", start_row = 5, 
            end_row = 9, latex_gap_space = "0.5em", bold = TRUE) |>
  
  # Pack rows for Publication Decade (10 to 12)
  pack_rows(group_label = "Publication Decade", 
            start_row = 10, 
            end_row = 12, latex_gap_space = "0.5em", bold = TRUE) |>
  
  # Pack rows for Publication Status (13 to 15)
  pack_rows(group_label = "Publication Status", 
            start_row = 13, 
            end_row = 15, latex_gap_space = "0.5em", bold = TRUE) |>
  
  # Pack rows for Delivery Methods (16 to 21)
  pack_rows(group_label = "Delivery Methods", 
            start_row = 16, 
            end_row = 21, latex_gap_space = "0.5em", bold = TRUE) |>
  
  # Pack rows for Outcome Recording (22 to 23)
  pack_rows(group_label = "Outcome Recording", 
            start_row = 22, 
            end_row = 23, latex_gap_space = "0.5em", bold = TRUE) |>
  
  row_spec(0, bold = TRUE, font_size = 12)

