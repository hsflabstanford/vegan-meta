# Create the moderator table with dynamic row indexing
moderator_table <- bind_rows(
  # Population model results
  population_model_results <- bind_rows(
    extract_model_results("university", "population", data = dat, 
                          approach_name = "University students and staff", second_p_value = TRUE),
    extract_model_results("adult", "population", data = dat, 
                          approach_name = "Adults", second_p_value = TRUE),
    extract_model_results("young", "population", data = dat, 
                          approach_name = "Adolescents", second_p_value = TRUE),
    extract_model_results("all ages", "population", data = dat, 
                          approach_name = "All ages", second_p_value = TRUE)
  ),
  
  # Country/Region model results
  country_model_results <- bind_rows(
    extract_model_results("United States|Canada", "country", data = dat, 
                          approach_name = "North America", second_p_value = TRUE),
    extract_model_results("United Kingdom|Denmark|Germany|Italy|Netherlands|Sweden", "country", data = dat, 
                          approach_name = "Europe", second_p_value = TRUE),
    extract_model_results("worldwide|United States, United Kingdom, Canada, Australia, and other", "country", data = dat, 
                          approach_name = "Multi-region", second_p_value = TRUE),
    extract_model_results("Iran|Thailand", "country", data = dat, 
                          approach_name = "Asia", second_p_value = TRUE),
    extract_model_results("Australia", "country", data = dat, 
                          approach_name = "Australia", second_p_value = TRUE)
  ),
  
  # Decade model results
  decade_model_results <- bind_rows(
    extract_model_results("2000s", "decade", data = dat, 
                          approach_name = "2000s", second_p_value = TRUE),
    extract_model_results("2010s", "decade", data = dat, 
                          approach_name = "2010s", second_p_value = TRUE),
    extract_model_results("2020s", "decade", data = dat, 
                          approach_name = "2020s", second_p_value = TRUE)
  ),
  
  # Publication status model results
  pub_status_model_results <- bind_rows(
    extract_model_results("Advocacy Organization", "pub_status", data = dat, 
                          approach_name = "Nonprofit white paper", second_p_value = TRUE),
    extract_model_results("Journal article", "pub_status", data = dat, 
                          approach_name = "Journal article", second_p_value = TRUE),
    extract_model_results("Preprint|Thesis", "pub_status", data = dat, 
                          approach_name = "Preprint or Thesis", second_p_value = TRUE)
  ),
  
  # Delivery methods model results
  delivery_model_results <- bind_rows(
    extract_model_results("article|op-ed|leaflet|flyer|printed booklet|mailed", "delivery_method", data = dat, 
                          approach_name = "Printed Materials", second_p_value = TRUE),
    extract_model_results("video", "delivery_method", data = dat, 
                          approach_name = "Video", second_p_value = TRUE),
    extract_model_results("in-cafeteria", "delivery_method", data = dat, 
                          approach_name = "In-cafeteria", second_p_value = TRUE),
    extract_model_results("online|internet|text|email", "delivery_method", data = dat, 
                          approach_name = "Online", second_p_value = TRUE),
    extract_model_results("dietary consultation", "delivery_method", data = dat, 
                          approach_name = "Dietary Consultation", second_p_value = TRUE),
    extract_model_results("free meat alternative", "delivery_method", data = dat, 
                          approach_name = "Free Meat Alternative", second_p_value = TRUE)
  ),
  
  # Outcome recording model results
  outcome_model_results <- bind_rows(
    extract_model_results("Y", "self_report", data = dat, 
                          approach_name = "Self reported", second_p_value = TRUE),
    extract_model_results("N", "self_report", data = dat, 
                          approach_name = "Objectively measured", second_p_value = TRUE)
  )
) |>
  kbl(booktabs = TRUE, 
      col.names = c("Moderator", "N (Studies)", "N (Estimates)", 
                    "Delta", "95% CIs", "p value", "second p value"), 
      caption = "Moderator Analysis Results", 
      label = "table_two") |>
  # Now calculate dynamic row indices using nrow()
  pack_rows(group_label = "Population", 
            start_row = 1, end_row = nrow(population_model_results), 
            latex_gap_space = "0.5em", bold = TRUE) |>
  pack_rows(group_label = "Region", 
            start_row = nrow(population_model_results) + 1, 
            end_row = nrow(population_model_results) + nrow(country_model_results), 
            latex_gap_space = "0.5em", bold = TRUE) |>
  pack_rows(group_label = "Publication Decade", 
            start_row = nrow(population_model_results) + nrow(country_model_results) + 1, 
            end_row = nrow(population_model_results) + nrow(country_model_results) + nrow(decade_model_results), 
            latex_gap_space = "0.5em", bold = TRUE) |>
  pack_rows(group_label = "Publication Status", 
            start_row = nrow(population_model_results) + nrow(country_model_results) + nrow(decade_model_results) + 1, 
            end_row = nrow(population_model_results) + nrow(country_model_results) + nrow(decade_model_results) + nrow(pub_status_model_results), 
            latex_gap_space = "0.5em", bold = TRUE) |>
  pack_rows(group_label = "Delivery Methods", 
            start_row = nrow(population_model_results) + nrow(country_model_results) + nrow(decade_model_results) + nrow(pub_status_model_results) + 1, 
            end_row = nrow(population_model_results) + nrow(country_model_results) + nrow(decade_model_results) + nrow(pub_status_model_results) + nrow(delivery_model_results), 
            latex_gap_space = "0.5em", bold = TRUE) |>
  pack_rows(group_label = "Outcome Recording", 
            start_row = nrow(population_model_results) + nrow(country_model_results) + nrow(decade_model_results) + nrow(pub_status_model_results) + nrow(delivery_model_results) + 1, 
            end_row = nrow(population_model_results) + nrow(country_model_results) + nrow(decade_model_results) + nrow(pub_status_model_results) + nrow(delivery_model_results) + nrow(outcome_model_results), 
            latex_gap_space = "0.5em", bold = TRUE) |>
  add_footnote("I'm going to need a good footnote for this complex table!", 
               notation = "none")
