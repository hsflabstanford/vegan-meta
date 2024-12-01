# supplementary data
library(googlesheets4)
library(googledrive)
library(readr)
library(dplyr)

drive_auth()
drive_download(as_id('1mPCt7HuK7URvuWcsMQokQCOGnSold-TS0NyC1EZniJk'),
              path = './data/MAP-reduction-data.csv',
              overwrite = TRUE)

read_sheet(ss = "1mPCt7HuK7URvuWcsMQokQCOGnSold-TS0NyC1EZniJk",
           sheet = "robustness-data") |>
  write_csv('./data/robustness-data.csv')

read_sheet(ss = "1mPCt7HuK7URvuWcsMQokQCOGnSold-TS0NyC1EZniJk",
           sheet = "red-and-processed-meat") |>
  write_csv('./data/rpmc-data.csv')

read_sheet('1mPCt7HuK7URvuWcsMQokQCOGnSold-TS0NyC1EZniJk',
                               sheet = 'excluded-studies') |>
  select(author,	year,	title,	doi_or_url,	source,	exclusion_reason) |>
  write_csv('./data/excluded-studies.csv')

read_sheet('1mPCt7HuK7URvuWcsMQokQCOGnSold-TS0NyC1EZniJk',
           sheet = 'review-of-reviews') |>
  select(Author, Year, Title, DOI_or_URL) |>
  write_csv('./data/review-of-reviews.csv')
