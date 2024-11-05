source('./scripts/load-data.R') # if needed
source('./scripts/robustness-checks.R')
source('./scripts/robustness-checks.R')

excluded_data <- read.csv('./data/excluded-studies.csv') |>
  select(-exclusion_reason) |> 
  mutate(inclusion_exclusion = 8)

all_papers <- full_join(
  dat |> select(author, year, title, source, inclusion_exclusion),
  RPMC |> select(author, year, title, source, inclusion_exclusion),
  robust_dat |> select(author, year, title, source, inclusion_exclusion),
  excluded_data |> select(author, year, title, source, inclusion_exclusion)) |>
  group_by(title) |> slice(1)
