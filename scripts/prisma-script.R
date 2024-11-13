library(dplyr)
library(stringr)
source('./scripts/load-data.R') 
source('./scripts/robustness-checks.R')
source('./scripts/robustness-checks.R')
source('./functions/sum-tab.R')

excluded_data <- read.csv('../data/excluded-studies.csv') |>
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
final_paper_n <- nrow(all_papers |> filter(inclusion_exclusion == 0))
excluded_paper_n <- nrow(all_papers |> filter(inclusion_exclusion != 0))

# source Ns: primary categories
GS_search_n <- nrow(all_papers |> filter(grouped_source == 'Google Scholar'))
RP_n <- nrow(all_papers |> filter(grouped_source == 'Rethink Priorities databases'))
database_n <- GS_search_n + RP_n
registry_n <- nrow(all_papers |> filter(grouped_source == 'registry'))

# source Ns: secondary categories
website_n <- nrow(all_papers |> filter(grouped_source == 'AI search tool')) +
  nrow(all_papers |> filter(grouped_source == 'website'))
prior_review_n <-  nrow(all_papers |> filter(grouped_source == 'prior review'))
citation_n <- nrow(all_papers |> filter(grouped_source == 'snowball'))  
shared_n <- nrow(all_papers |> filter(grouped_source == 'shared by other researchers'))  
prior_knowledge_n <- nrow(all_papers |> filter(grouped_source == 'prior knowledge'))  

# check we have everything
GS_search_n + RP_n + registry_n + website_n + prior_review_n +citation_n + 
  shared_n + prior_knowledge_n

# among included studies, how many came from registries and databases
included_papers_group_conts <- all_papers |> 
  filter(inclusion_exclusion == 0) |>
  group_by(grouped_source) |> summarise(n = n()) |> 
  arrange(desc(n))

# reviews count in included text
included_review_count <- included_papers_group_conts |> 
  filter(grouped_source == "prior review") |> 
  pull(n)

