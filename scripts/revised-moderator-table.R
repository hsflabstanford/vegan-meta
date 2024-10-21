
# Create all moderator variables in one mutate call
dat <- dat |> mutate(
  population_group = case_when(
    str_detect(population, regex("university", ignore_case = TRUE)) ~ "University students and staff",
    str_detect(population, regex("adult", ignore_case = TRUE)) ~ "Adults",
    str_detect(population, regex("young", ignore_case = TRUE)) ~ "Adolescents",
    str_detect(population, regex("all ages", ignore_case = TRUE)) ~ "All ages",
    TRUE ~ NA_character_),
  region_group = case_when(
    str_detect(country, regex("United States|Canada", ignore_case = TRUE)) ~ "North America",
    str_detect(country, regex("United Kingdom|Denmark|Germany|Italy|Netherlands|Sweden", ignore_case = TRUE)) ~ "Europe",
    str_detect(country, regex("worldwide|United States, United Kingdom, Canada, Australia, and other", ignore_case = TRUE)) ~ "Multi-region",
    str_detect(country, regex("Iran|Thailand", ignore_case = TRUE)) ~ "Asia + Australia",
    country == 'Asia' ~ "Asia + Australia",
    TRUE ~ NA_character_),
  decade_group = case_when(
    decade == "2000s" ~ "2000s",
    decade == "2010s" ~ "2010s",
    decade == "2020s" ~ "2020s",
    TRUE ~ NA_character_),
  delivery_group = case_when(
    str_detect(delivery_method, regex("article|op-ed|leaflet|flyer|printed booklet|mailed|lecture", 
                                      ignore_case = TRUE)) ~ "Educational materials",
    str_detect(delivery_method, regex("video", ignore_case = TRUE)) ~ "Video",
    str_detect(delivery_method, regex("in-cafeteria", ignore_case = TRUE)) ~ "In-cafeteria",
    str_detect(delivery_method, regex("online|internet|text|email", ignore_case = TRUE)) ~ "Online",
    str_detect(delivery_method, regex("dietary consultation", ignore_case = TRUE)) ~ "Dietary consultation",    TRUE ~ NA_character_))

# RPMC target difference
merged_dat <- full_join(dat, RPMC) |>
  mutate(meat_target = if_else(inclusion_exclusion == 0, "MAP", "Red and Processed Meat"))
# Check for unmatched data in the new variables and throw an error if found

# Population Group Check
if (any(is.na(dat$population_group))) {
  unmatched_rows <- which(is.na(dat$population_group))
  stop("Error: Some entries in 'population' could not be classified into 'population_group'. Unmatched rows: ", paste(unmatched_rows, collapse = ", "))
} # and so on for different categories


# Process Population Group
population_levels <- c("University students and staff", "Adults", "Adolescents", "All ages")
ref_level_population <- "University students and staff"
population_results <- process_group(dat, "population_group", population_levels, ref_level_population)

# Process Region Group
region_levels <- c("North America", "Europe", "Multi-region", "Asia + Australia")
ref_level_region <- "North America"
region_results <- process_group(dat, "region_group", region_levels, ref_level_region)

# Red Meat Group
red_meat_levels <- c("")
# Process Publication Decade Group
decade_levels <- c("2000s", "2010s", "2020s")
ref_level_decade <- "2000s"
decade_results <- process_group(dat, "decade_group", decade_levels, ref_level_decade)

# Process Delivery Methods Group
delivery_levels <- c("Educational materials", "Video", "In-cafeteria", "Online", "Dietary consultation")
ref_level_delivery <- "Educational materials"
delivery_results <- process_group(dat, "delivery_group", delivery_levels, ref_level_delivery)

moderator_table <- bind_rows(
  population_results,
  region_results,
  decade_results,
  delivery_results
)
# Remove entries with zero studies
moderator_table <- moderator_table |> filter(N_Studies > 0)

# Calculate the starting and ending row indices for each group
start_row_population <- 1
end_row_population <- nrow(population_results)
start_row_region <- end_row_population + 1
end_row_region <- start_row_region + nrow(region_results) - 1
start_row_decade <- end_row_region + 1
end_row_decade <- start_row_decade + nrow(decade_results) - 1
start_row_delivery <- end_row_decade + 1
end_row_delivery <- start_row_delivery + nrow(delivery_results) - 1

# Order the table by Group and then by the order of levels defined
# moderator_table <- moderator_table |>
#   mutate(
#     Moderator = factor(Moderator, levels = c(population_levels, region_levels, decade_levels, delivery_levels)),
#     Group = factor(Group, levels = c("Population", "Region", "Publication Decade", "Delivery Methods"))
#   ) |>
#   arrange(Group, Moderator)

# Format the table
revised_moderator_table <- moderator_table |>
  kbl(booktabs = TRUE, 
      col.names = c("Stucy Characteristic", "N (Studies)", "N (Estimates)", 
                    "Delta", "95\\% CIs", "subset p value", "moderator p value"), 
      caption = "Moderator Analysis Results", label = "table_two", escape = FALSE) |>
  kable_styling(full_width = FALSE) |>
  pack_rows("Population", start_row_population, end_row_population, bold = TRUE, italic = FALSE)|>
  pack_rows("Region", start_row_region, end_row_region, bold = TRUE, italic = FALSE) |>
  pack_rows("Publication Decade", start_row_decade, end_row_decade, bold = TRUE, italic = FALSE) |>
   pack_rows("Delivery Methods", start_row_delivery, end_row_delivery, bold = TRUE, italic = FALSE) |>
  add_footnote(
    "[a really good foontote]",
    notation = "none"
  )


