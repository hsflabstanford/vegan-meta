source('./scripts/libraries.R')
source('./scripts/load-data.R') 
source('./scripts/robustness-checks.R')
source('./scripts/robustness-checks.R')
source('./functions/sum-tab.R')

excluded_data <- read.csv('./data/excluded-studies.csv') |>
  select(-exclusion_reason) |> 
  mutate(inclusion_exclusion = 8)

all_papers <- full_join(
  dat |> select(author, year, title, source, inclusion_exclusion),
  RPMC |> select(author, year, title, source, inclusion_exclusion)
) |>
  full_join(robust_dat |> select(author, year, title, source, inclusion_exclusion)) |>
  full_join(excluded_data |> select(author, year, title, source, inclusion_exclusion)) |>
  group_by(title) |> 
  slice(1) |> ungroup() |>
  mutate(grouped_source = case_when(
    str_detect(source, ".*snowball search") ~ 'snowball',
    str_detect(source, ".*prior review") ~ 'prior review',
    str_detect(source, ".*Google Scholar") ~ 'Google Scholar',
    str_detect(source, ".*meat-lime.vercel.app") |
      str_detect(source, ".*RP systematic search") ~ 'Rethink Priorities databases',
    str_detect(source, ".*registry") ~ 'registry',
    str_detect(source, ".*AI search tool") ~ 'AI search tool',
    str_detect(source, ".*website") ~ 'website',
    str_detect(source, ".*prior knowledge") ~ 'prior knowledge',
    str_detect(source, ".*shared") ~ 'shared by other researchers',
    TRUE ~ "ERROR"))

# included/excluded (counting RPM studies as 'excluded')
final_paper_n <- nrow(all_papers |> filter(inclusion_exclusion == 0)); print(final_paper_n)
excluded_paper_n <- nrow(all_papers |> filter(inclusion_exclusion != 0))

# source Ns: primary categories
GS_search_n <- nrow(all_papers |> filter(grouped_source == 'Google Scholar')); print(GS_search_n)
RP_n <- nrow(all_papers |> filter(grouped_source == 'Rethink Priorities databases')); print(RP_n)
database_n <- GS_search_n + RP_n; print(database_n)
registry_n <- nrow(all_papers |> filter(grouped_source == 'registry')); print(registry_n)

records_screened <- database_n + registry_n; print(records_screened)

# source Ns: secondary categories
website_n <- nrow(all_papers |> filter(grouped_source == 'AI search tool')) +
  nrow(all_papers |> filter(grouped_source == 'website')); print(website_n)
prior_review_n <-  nrow(all_papers |> filter(grouped_source == 'prior review')); print(prior_review_n)
citation_n <- nrow(all_papers |> filter(grouped_source == 'snowball')); print(citation_n)
shared_n <- nrow(all_papers |> filter(grouped_source == 'shared by other researchers')); print(shared_n)
prior_knowledge_n <- nrow(all_papers |> filter(grouped_source == 'prior knowledge')); print(prior_knowledge_n)

reports_sought <- website_n + prior_review_n + citation_n + shared_n + prior_knowledge_n; print(reports_sought)

# check we have everything
GS_search_n + RP_n + registry_n + website_n + prior_review_n +citation_n + 
  shared_n + prior_knowledge_n == nrow(all_papers)

# among included studies, how many came from registries and databases
included_papers_group_conts <- all_papers |> 
  filter(inclusion_exclusion == 0) |>
  group_by(grouped_source) |> summarise(n = n()) |> 
  arrange(desc(n)); print(sum(included_papers_group_conts$n))

included_papers_group_conts |> 
  mutate(category = case_when(
    grouped_source %in% c("Google Scholar", "Rethink Priorities databases", "registry") ~ "Databases & Registries",
    TRUE ~ "Other Sources"
  )) |> 
  group_by(category) |> 
  summarise(total_n = sum(n), .groups = "drop")

# reviews count in included text
included_review_count <- included_papers_group_conts |> 
  filter(grouped_source == "prior review") |> 
  pull(n)

# final cells

# Manually define the correct "Reports assessed for eligibility" values
reports_assessed <- tibble(
  category = c("Databases & Registries", "Other Sources"),
  assessed_n = c(records_screened, reports_sought)  # 130 and 857
)

# Merge with included papers to compute reports excluded
included_papers_summary <- tibble(
  category = c("Databases & Registries", "Other Sources"),
  included_n = c(sum(included_papers_group_conts |> 
                       filter(grouped_source %in% 
                                c("Google Scholar", "Rethink Priorities databases", "registry")) |> 
                       pull(n)), sum(included_papers_group_conts |>
                       filter(!grouped_source %in% 
                                c("Google Scholar", "Rethink Priorities databases", "registry")) |> 
                         pull(n)))) |>  
  left_join(reports_assessed, by = "category") |> 
  mutate(reports_excluded = assessed_n - included_n); print(included_papers_summary)

included_studies <- max(dat$unique_study_id); print(included_studies)
      