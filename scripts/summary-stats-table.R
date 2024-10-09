
# Summarize data for different categories in the specified order

# Population summary
population_summary <- summarize_to_tibble(
  dat,
  condition = list(
    str_detect(dat$population, "university") ~ "University students and staff",
    str_detect(dat$population, "adult") ~ "Adults", 
    str_detect(dat$population, "young") ~ "Young people",
    str_detect(dat$population, "all ages") ~ "All ages",
    TRUE ~ 'Other'
  ),
  group_col_name = population_group
)

decade_summary <- summarize_to_tibble(
  dat,
  condition = list(
    TRUE ~ as.character(dat$decade)),
  group_col_name = decade,
  sort_desc = FALSE  # Disable sorting for decades
)

# Publication status summary
publication_status_summary <- summarize_to_tibble(
  dat,
  condition = list(
    str_detect(dat$pub_status, "Advocacy Organization") ~ "Advocacy Organization",
    str_detect(dat$pub_status, "Journal article") ~ "Journal article",
    str_detect(dat$pub_status, "Preprint") ~ "Preprint",
    str_detect(dat$pub_status, "Thesis") ~ "Thesis",
    TRUE ~ 'Other'
  ),
  group_col_name = pub_status
)

# Delivery methods summary
delivery_summary <- dat |>
  mutate(
    Printed_materials = str_detect(delivery_method, "article|op-ed|leaflet|flyer|printed booklet|mailed"),
    Video = str_detect(delivery_method, "video"),
    In_cafeteria = str_detect(delivery_method, "in-cafeteria"),
    Online = str_detect(delivery_method, "online|internet|text|email"),
    Dietary_consultation = str_detect(delivery_method, "dietary consultation"),
    Lecture = str_detect(delivery_method, "lecture"),
    Free_Meat_Alternative = str_detect(delivery_method, "free meat alternative")
  ) |>
  pivot_longer(cols = c(Printed_materials, Video, In_cafeteria, Online, 
                        Dietary_consultation, Lecture, Free_Meat_Alternative),
               names_to = "delivery_group", values_to = "is_used") |>
  filter(is_used) |>
  group_by(delivery_group) |>
  summarise(study_count = n_distinct(unique_study_id)) |>
  mutate(Category = gsub("_", " ", delivery_group), `Number of Studies` = study_count, .keep = "none") |>
  arrange(desc(`Number of Studies`))

# 2. Combine all summaries into one table in the specified order: Population, Dates, Status, Delivery Methods
combined_summary <- bind_rows(
  population_summary,
  decade_summary,
  publication_status_summary,
  delivery_summary
)

# 3. Create the table with sub-headers and adjustments
# Create the table without the footnote function to avoid nested environments
summary_stats_table <- combined_summary |>
  kbl(booktabs = TRUE, col.names = c("Study Characteristic", "Number of Studies")) |>
  kable_styling(latex_options = c("striped", "hold_position", "scale_down"),
                font_size = 10) |>
  pack_rows("Population", 1, nrow(population_summary), latex_gap_space = "0.5em",
            bold = TRUE) |>
  pack_rows("Publication Decade", nrow(population_summary) + 1,
            nrow(population_summary) + nrow(decade_summary),
            latex_gap_space = "0.5em", bold = TRUE) |>
  pack_rows("Publication Status", nrow(population_summary) +
              nrow(decade_summary) + 1, nrow(population_summary) +
              nrow(decade_summary) + nrow(publication_status_summary),
            latex_gap_space = "0.5em", bold = TRUE) |>
  pack_rows("Delivery Methods", nrow(population_summary) +
              nrow(decade_summary) + nrow(publication_status_summary) + 1,
            nrow(combined_summary), latex_gap_space = "0.5em", bold = TRUE) |>
  row_spec(0, bold = TRUE, font_size = 12)  |>
  row_spec(c(2, nrow(population_summary) + 2, nrow(population_summary)
             + nrow(decade_summary) + 2, nrow(population_summary) +
               nrow(decade_summary) + nrow(publication_status_summary) + 2),
           bold = FALSE)


