# -------------------------------
# 0. Libraries, Data, and Functions
# -------------------------------
library(dplyr, warn.conflicts = FALSE)
library(stringr)
library(kableExtra, warn.conflicts = FALSE)
library(flextable)
source('./scripts/load-data.R')
source('./scripts/functions.R')

# -------------------------------
# 1. Create Moderator Variables
# -------------------------------

# (Assuming 'dat' and 'RPMC' are already defined and loaded)
dat <- dat |> 
  mutate(
    population_group = case_when(
      str_detect(population, regex("university", ignore_case = TRUE)) ~ "University students/staff",
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
# 2. RPMC Subset and Data Merging
# -------------------------------
merged_dat <- full_join(dat, RPMC) |>
  mutate(meat_group = if_else(inclusion_exclusion == 0, 
                              "Meat and animal products", 
                              "Red and processed meat"))

# -------------------------------
# 3. Process Each Moderator Group
# -------------------------------
red_meat_results     <- process_group(merged_dat, "meat_group", ref_level = "Meat and animal products")
population_results   <- process_group(dat, "population_group", ref_level = "University students/staff")
region_results       <- process_group(dat, "region_group", ref_level = "North America")
decade_results       <- process_group(dat, "decade_group", ref_level = "2000s")
delivery_results     <- process_group(dat, "delivery_group", ref_level = "Educational materials")

# -------------------------------
# 4. Combine All Moderator Results
# -------------------------------
# For the PDF branch we use the results as-is and let kableExtra add grouping rows.
# For the Word branch we’ll insert extra grouping header rows.
moderator_table_raw <- bind_rows(
  red_meat_results,         
  population_results,
  region_results,
  decade_results,
  delivery_results
)

# -------------------------------
# 5. Output Formatting
# -------------------------------
if (!word) {
  # PDF/LaTeX output using kableExtra
  # (Note: row indices for grouping were computed in your original code;
  # here we assume that red_meat_results comes first, then population, etc.)
  
  # Calculate group row indices:
  start_row_outcome    <- 1
  end_row_outcome      <- start_row_outcome + nrow(red_meat_results) - 1
  start_row_population <- end_row_outcome + 1
  end_row_population   <- start_row_population + nrow(population_results) - 1
  start_row_region     <- end_row_population + 1
  end_row_region       <- start_row_region + nrow(region_results) - 1
  start_row_decade     <- end_row_region + 1
  end_row_decade       <- start_row_decade + nrow(decade_results) - 1
  start_row_delivery   <- end_row_decade + 1
  end_row_delivery     <- start_row_delivery + nrow(delivery_results) - 1
  
  moderator_table <- moderator_table_raw |>
    kbl(
      booktabs = TRUE, 
      col.names = c("Study Characteristic", "N (Studies)", "N (Estimates)", 
                    "SMD", "95\\% CIs", 
                    "Subset $p$ value", 
                    "Moderator $p$ value"),
      caption = "Moderator Analysis Results",  
      label = "table_S1",
      align = "llllllll",
      escape = FALSE,
      centering = TRUE) |>
    kable_styling(
      full_width = FALSE,
      latex_options = "hold_position", 
      position = "left") |>
    column_spec(6, width = "2 cm") |>
    column_spec(7, width = "2 cm") |>
    pack_rows("Outcome", start_row_outcome, end_row_outcome, bold = TRUE, italic = FALSE) |>
    pack_rows("Population", start_row_population, end_row_population, bold = TRUE, italic = FALSE) |>
    pack_rows("Region", start_row_region, end_row_region, bold = TRUE, italic = FALSE) |>
    pack_rows("Publication Decade", start_row_decade, end_row_decade, bold = TRUE, italic = FALSE) |>
    pack_rows("Method of Delivery", start_row_delivery, end_row_delivery, bold = TRUE, italic = FALSE) |>
    add_footnote("Moderation analyses by differences in outcomes, population, region, decade of publication, and delivery method. The first $p$ value column tests the hypothesis that the subset of studies with a given characteristic is significantly different from an SMD of zero. The second compares effects within a given category to the reference category for that moderator. N/A $p$ values were not calculated due to an insufficient number of qualifying studies.", 
                 escape = FALSE, 
                 notation = "none")
  
} else {
    # Helper function: rename raw moderator results and convert all columns to character
    rename_mod <- function(df) {
      df |>
        rename(
          `Study Characteristic` = Moderator,
          `N (Studies)`          = N_Studies,
          `N (Estimates)`        = N_Estimates,
          SMD                    = Delta,
          `95% CIs`              = CI,
          `Subset p value`       = p_val,
          `Moderator p value`    = p_val_ref
        ) |>
        mutate(across(everything(), as.character))
    }
    
    red_meat_results2     <- rename_mod(red_meat_results)
    population_results2   <- rename_mod(population_results)
    region_results2       <- rename_mod(region_results)
    decade_results2       <- rename_mod(decade_results)
    delivery_results2     <- rename_mod(delivery_results)
    
    # Replace any HTML-coded "ref" with plain "ref" in the p value columns
    red_meat_results2 <- red_meat_results2 |>
      mutate(
        `Subset p value` = ifelse(grepl("ref", `Subset p value`, ignore.case = TRUE), "ref", `Subset p value`),
        `Moderator p value` = ifelse(grepl("ref", `Moderator p value`, ignore.case = TRUE), "ref", `Moderator p value`)
      )
    population_results2 <- population_results2 |>
      mutate(
        `Subset p value` = ifelse(grepl("ref", `Subset p value`, ignore.case = TRUE), "ref", `Subset p value`),
        `Moderator p value` = ifelse(grepl("ref", `Moderator p value`, ignore.case = TRUE), "ref", `Moderator p value`)
      )
    region_results2 <- region_results2 |>
      mutate(
        `Subset p value` = ifelse(grepl("ref", `Subset p value`, ignore.case = TRUE), "ref", `Subset p value`),
        `Moderator p value` = ifelse(grepl("ref", `Moderator p value`, ignore.case = TRUE), "ref", `Moderator p value`)
      )
    decade_results2 <- decade_results2 |>
      mutate(
        `Subset p value` = ifelse(grepl("ref", `Subset p value`, ignore.case = TRUE), "ref", `Subset p value`),
        `Moderator p value` = ifelse(grepl("ref", `Moderator p value`, ignore.case = TRUE), "ref", `Moderator p value`)
      )
    delivery_results2 <- delivery_results2 |>
      mutate(
        `Subset p value` = ifelse(grepl("ref", `Subset p value`, ignore.case = TRUE), "ref", `Subset p value`),
        `Moderator p value` = ifelse(grepl("ref", `Moderator p value`, ignore.case = TRUE), "ref", `Moderator p value`)
      )
    
    # Create header rows for each moderator group using the desired column names
    header_outcome <- tibble(
      `Study Characteristic` = "Outcome",
      `N (Studies)`          = "",
      `N (Estimates)`        = "",
      SMD                    = "",
      `95% CIs`              = "",
      `Subset p value`       = "",
      `Moderator p value`    = ""
    )
    header_population <- tibble(
      `Study Characteristic` = "Population",
      `N (Studies)`          = "",
      `N (Estimates)`        = "",
      SMD                    = "",
      `95% CIs`              = "",
      `Subset p value`       = "",
      `Moderator p value`    = ""
    )
    header_region <- tibble(
      `Study Characteristic` = "Region",
      `N (Studies)`          = "",
      `N (Estimates)`        = "",
      SMD                    = "",
      `95% CIs`              = "",
      `Subset p value`       = "",
      `Moderator p value`    = ""
    )
    header_decade <- tibble(
      `Study Characteristic` = "Publication Decade",
      `N (Studies)`          = "",
      `N (Estimates)`        = "",
      SMD                    = "",
      `95% CIs`              = "",
      `Subset p value`       = "",
      `Moderator p value`    = ""
    )
    header_delivery <- tibble(
      `Study Characteristic` = "Method of Delivery",
      `N (Studies)`          = "",
      `N (Estimates)`        = "",
      SMD                    = "",
      `95% CIs`              = "",
      `Subset p value`       = "",
      `Moderator p value`    = ""
    )
    
    # Bind the header rows and renamed results in the desired order
    final_table <- bind_rows(
      header_outcome,
      red_meat_results2,
      header_population,
      population_results2,
      header_region,
      region_results2,
      header_decade,
      decade_results2,
      header_delivery,
      delivery_results2
    )
    
    # Build the flextable from the final table, set the caption to include "Table 2"
    moderator_table <- flextable(final_table) |>
      set_caption("Table 2: Moderator Analysis Results") |>
      theme_booktabs() |>
      autofit() |>
      add_footer_lines("Moderation analyses. The first p value column tests the hypothesis that the subset of studies with a given characteristic is significantly different than an SMD of zero. The second compares effects within a category to the reference for that moderator. N/A p values were not calculated due to an insufficient number of qualifying studies.") |>
      padding(part = "footer", padding.bottom = 12)
    
    # Bold the group header rows in the first column
    moderator_table <- moderator_table |>
      bold(i = ~ `Study Characteristic` %in% c("Outcome", "Population", "Region", "Publication Decade", "Method of Delivery"),
           j = 1, bold = TRUE, part = "body")
    
    # Bold cells in the p value columns that equal "ref"
    moderator_table <- moderator_table |>
      bold(i = which(final_table$`Subset p value` == "ref"), j = "Subset p value", bold = TRUE, part = "body") |>
      bold(i = which(final_table$`Moderator p value` == "ref"), j = "Moderator p value", bold = TRUE, part = "body")
    
    # Adjust header labels: remove math-mode for Subset p value and force a line break in Moderator p value header
    moderator_table <- set_header_labels(moderator_table,
                                         `Subset p value` = "Subset p value",
                                         `Moderator p value` = "Moderator p\nvalue")
    
    moderator_table
}
