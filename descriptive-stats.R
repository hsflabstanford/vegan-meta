# Data preparation and basic statistics
paper_dat <- dat |> group_by(unique_paper_id) |>  slice(1) |>  ungroup()

# Decade Analysis
decade_tab <- paper_dat |> count(decade)
first_decade_papers <- as.numeric(decade_tab$n[decade_tab$decade == "2000s"])
second_decade_papers <- as.numeric(decade_tab$`n`[decade_tab$decade == "2010s"])
third_decade_papers <- as.numeric(decade_tab$`n`[decade_tab$decade == "2020s"])

# Publication Type Analysis
doi_tab <- paper_dat |> count(pub_status)
published_papers <- as.numeric(doi_tab$`n`[doi_tab$pub_status == "publication"])
preprint_papers <- as.numeric(doi_tab$`n`[doi_tab$pub_status == "preprint"])
other_papers <- as.numeric(doi_tab$`n`[doi_tab$pub_status == "dissertation_or_tech_report"])

# Non-DOI Paper Analysis
non_doi_paper_stats <- paper_dat |> filter(pub_status != "publication") |> count(venue)
dissertation_papers <- as.numeric(non_doi_paper_stats$`n`[non_doi_paper_stats$venue == "dissertation"])
advocacy_papers <- as.numeric(non_doi_paper_stats$`n`[non_doi_paper_stats$venue == "advocacy org publication"])

# Venue Analysis
venue_counts <- sort(table(paper_dat$venue), decreasing = T)
num_venues <- length(venue_counts)
most_common_venue <- noquote(names(sort(venue_counts, decreasing = TRUE)[1]))
most_common_venue_count <- max(venue_counts)

# Correcting Journal Article Counts
journal_article_counts <- paper_dat |> 
  filter(pub_status == "publication") |> 
  count(venue) |> 
  arrange(desc(n))

# Cluster Assigned Analysis
cluster_sample_stats <- dat |> 
  filter(cluster_assigned == "Y") |> 
  summarise(n = n(),
            median = median(total_sample, na.rm = TRUE), 
            min = min(total_sample, na.rm = TRUE), 
            max = max(total_sample, na.rm = TRUE))

# Non-Clustered Sample Size Statistics
non_cluster_sample_stats <- dat |> 
  filter(cluster_assigned == "N") |> 
  summarise(n = n(),
            median = median(total_sample, na.rm = TRUE), 
            min = min(total_sample, na.rm = TRUE), 
            max = max(total_sample, na.rm = TRUE))

# Intervention Types Count
intervention_types_counts <- dat |> 
  summarise(cafeteria_or_restaurant = sum(cafeteria_or_restaurant_based == "Y", na.rm = TRUE),
            multi_component = sum(multi_component == "Y", na.rm = TRUE),
            leaflet_count = sum(leaflet == "Y", na.rm = TRUE),
            video_count = sum(video == "Y", na.rm = TRUE),
            internet_based = sum(internet == "Y", na.rm = TRUE))

# Emotional Activation
emotional_activation_stats <- dat |> 
  summarise(emotional_activated = sum(emotional_activation == "Y", na.rm = TRUE), 
            emotional_not_activated = sum(emotional_activation == "N", na.rm = TRUE))

# Pre-Analysis Plan Stats
pre_analysis_plan_stats <- dat |> 
  summarise(pre_analysis_yes = sum(public_pre_analysis_plan != "N", na.rm = TRUE),
            pre_analysis_no = sum(public_pre_analysis_plan == "N", na.rm = TRUE))

# Open Data Stats
open_data_stats <- dat |> 
  summarise(open_data_yes = sum(open_data != "N", na.rm = TRUE),
            open_data_no = sum(open_data == "N", na.rm = TRUE))

# where do studies take place and with whom?
country_dat <- dat |> sum_tab(country)
pop_dat <- dat |> sum_tab(population)
# delay 
median_delay <- median(dat$delay)
range_delay <- range(dat$delay)

### outcome types
self_report_count <- dat |> sum_tab(self_report)

self_report_outcomes <- dat |> filter(self_report == "Y") |> 
  select(author, year, title, outcome, outcome_category) 

self_report_outcome_table <- self_report_outcomes |> sum_tab(outcome_category)

servings_portions_meals_count <- sum(str_detect(self_report_outcomes$outcome_category, "servings|portions|meals"))

days_count <- sum(str_detect(self_report_outcomes$outcome_category, "days"))
weight_loss_count <- sum(str_detect(self_report_outcomes$outcome_category, "weight"))
