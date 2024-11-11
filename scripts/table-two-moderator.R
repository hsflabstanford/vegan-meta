# -------------------------------
# 1. Create moderator variables
# -------------------------------

# Assuming 'dat' and 'RPMC' are already defined and loaded

# Create all moderator variables in one mutate call
dat <- dat |> 
  mutate(
    population_group = case_when(
      str_detect(population, regex("university", ignore_case = TRUE)) ~ "University students and staff",
      str_detect(population, regex("adult", ignore_case = TRUE)) ~ "Adults",
      str_detect(population, regex("young", ignore_case = TRUE)) ~ "Adolescents",
      str_detect(population, regex("all ages", ignore_case = TRUE)) ~ "All ages",
      TRUE ~ NA_character_
    ),
    region_group = case_when(
      str_detect(country, regex("United States|Canada", ignore_case = TRUE)) ~ "North America",
      str_detect(country, regex("United Kingdom|Denmark|Germany|Italy|Netherlands|Sweden", ignore_case = TRUE)) ~ "Europe",
      str_detect(country, regex("worldwide|United States, United Kingdom, Canada, Australia, and other", ignore_case = TRUE)) ~ "Multi-region",
      str_detect(country, regex("Iran|Thailand", ignore_case = TRUE)) ~ "Asia + Australia",
      country == 'Asia' ~ "Asia + Australia",
      TRUE ~ NA_character_
    ),
    decade_group = case_when(
      decade == "2000s" ~ "2000s",
      decade == "2010s" ~ "2010s",
      decade == "2020s" ~ "2020s",
      TRUE ~ NA_character_
    ),
    delivery_group = case_when(
      str_detect(delivery_method, regex("article|op-ed|leaflet|flyer|printed booklet|mailed|lecture", ignore_case = TRUE)) ~ "Educational materials",
      str_detect(delivery_method, regex("video", ignore_case = TRUE)) ~ "Video",
      str_detect(delivery_method, regex("in-cafeteria", ignore_case = TRUE)) ~ "In-cafeteria",
      str_detect(delivery_method, regex("online|internet|text|email", ignore_case = TRUE)) ~ "Online",
      str_detect(delivery_method, regex("dietary consultation", ignore_case = TRUE)) ~ "Dietary consultation",
      TRUE ~ NA_character_
    )
  )

# -------------------------------
# 2. RPMC subset
# -------------------------------

# RPMC target difference
merged_dat <- full_join(dat, RPMC) |>
  mutate(meat_group = if_else(inclusion_exclusion == 0, 
                              "Meat and animal products", 
                              "Red and processed meat"))

# -------------------------------
# 3. Process each moderator group
# -------------------------------

# 3.1. Outcome Group (Red Meat Group)
red_meat_results <- process_group(merged_dat, "meat_group", ref_level = "Meat and animal products")

# 3.2. Population Group
population_results <- process_group(dat, "population_group", ref_level = "University students and staff")

# 3.3. Region Group
region_results <- process_group(dat, "region_group", ref_level = "North America")

# 3.4. Publication Decade Group
decade_results <- process_group(dat, "decade_group", ref_level = "2000s")

# 3.5. Delivery Methods Group
delivery_results <- process_group(dat, "delivery_group", ref_level = "Educational materials")

# -------------------------------
# 4. Calculate row indices for grouping
# -------------------------------

# Calculate the starting and ending row indices for each group
start_row_outcome <- 1
end_row_outcome <- start_row_outcome + nrow(red_meat_results) - 1

start_row_population <- end_row_outcome + 1
end_row_population <- start_row_population + nrow(population_results) - 1

start_row_region <- end_row_population + 1
end_row_region <- start_row_region + nrow(region_results) - 1

start_row_decade <- end_row_region + 1
end_row_decade <- start_row_decade + nrow(decade_results) - 1

start_row_delivery <- end_row_decade + 1
end_row_delivery <- start_row_delivery + nrow(delivery_results) - 1

# -------------------------------
# 5. Combine all moderator results and format for publication
# ------------------------------- 

# Bind the moderator results
moderator_table <- bind_rows(
  red_meat_results,         
  population_results,
  region_results,
  decade_results,
  delivery_results) |>
  kbl(
    booktabs = TRUE, 
    col.names = c("Study Characteristic", "N (Studies)", "N (Estimates)", 
                  "SMD", "95\\% CIs", "Subset $p$ val", "Moderator $p$ val"), 
    caption = "Moderator Analysis Results",  
    label = "table_two", 
    align = 'l',
    escape = FALSE
  ) |>
  kable_styling(full_width = FALSE, latex_options = "hold_position") |>
  pack_rows("Outcome", start_row_outcome, end_row_outcome, bold = TRUE, italic = FALSE) |>
  pack_rows("Population", start_row_population, end_row_population, bold = TRUE, italic = FALSE) |>
  pack_rows("Region", start_row_region, end_row_region, bold = TRUE, italic = FALSE) |>
  pack_rows("Publication Decade", start_row_decade, end_row_decade, bold = TRUE, italic = FALSE) |>
  pack_rows("Method of Delivery", start_row_delivery, end_row_delivery, bold = TRUE, italic = FALSE) |>
  add_footnote("Moderation analyses by differences in outcomes, population, region, decade of publication, and delivery method. The first p value column tests the hypothesis that the subset of studies with a given characteristic is significantly different than an SMD of zero. The second compares effects within a given group, with the top category set to reference.", 
               notation = "none")
