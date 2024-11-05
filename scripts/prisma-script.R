library(dplyr)
library(stringr)
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
    str_detect(source, "snowball search") ~ 'snowball',
    str_detect(source, 'prior review') ~ 'prior review',
    str_detect(source, 'other') ~ 'other',
    str_detect(source, 'database search') ~ 'database',
    str_detect(source, 'registry') ~ 'registry',
    str_detect(source, 'AI search tool') ~ 'AI search tool',
    str_detect(source, 'website') ~ 'website',
    TRUE ~ "HELLO"))

# included/excluded (counting RPM studies as 'excluded')
final_paper_n <- nrow(all_papers |> filter(inclusion_exclusion == 0))
excluded_paper_n <- nrow(all_papers |> filter(inclusion_exclusion != 0))

# source Ns: primary categories
database_n <- nrow(all_papers |> filter(grouped_source == 'database'))
registry_n <- nrow(all_papers |> filter(grouped_source == 'registry'))

# source Ns: secondary categories
website_n <- nrow(all_papers |> filter(grouped_source == 'AI search tool')) +
  nrow(all_papers |> filter(grouped_source == 'website'))
prior_review_n <-  nrow(all_papers |> filter(grouped_source == 'prior review'))
citation_n <- nrow(all_papers |> filter(grouped_source == 'snowball'))  
other_n <- nrow(all_papers |> filter(grouped_source == 'other'))

# check we have everything
database_n + registry_n + prior_review_n +citation_n + other_n + website_n == nrow(all_papers)

# among included studies, how many came from registries and databases
all_papers |> filter(inclusion_exclusion == 0) |> sum_tab(grouped_source) 

# look at 'other' category
all_papers |> filter(grouped_source == 'other') |> select(author, year, source) |> print(n = 50)

