library(dplyr)
library(stringr)
source('./scripts/load-data.R') # if needed
source('./scripts/robustness-checks.R')
source('./scripts/robustness-checks.R')

excluded_data <- read.csv('./data/excluded-studies.csv') |>
  select(-exclusion_reason) |> 
  mutate(inclusion_exclusion = 8)

all_papers <- full_join(
  dat |> select(author, year, title, source, inclusion_exclusion),
  RPMC |> select(author, year, title, source, inclusion_exclusion)) |>
  full_join(robust_dat |> select(author, year, title, source, inclusion_exclusion)) |>
  full_join(excluded_data |> select(author, year, title, source, inclusion_exclusion)) |>
  group_by(title) |> slice(1) |>
  mutate(grouped_source = 
           str_detect(source, "snowball") ~ 'snowball search',
         str_detect(source, 'prior review') ~ 'prior review',
         str_detect(source, 'other') ~ 'other',
         str_detect(source, 'database search') ~ 'database search',
         str_detect(source, 'registry') ~ 'registry',
         str_detect(source, 'AI search tool') ~ 'AI search tool',
         TRUE ~ "NAAAA")
         
