# Codebook

**author**: First author of the paper
**year**: Publication year of the study
**title**: Title of the paper
**doi_or_url**: Either the Digital Object Identifier (DOI) if available, or the paper’s URL if not
**venue**: Publication source (e.g., journal name, conference)
**source**: How the study was located (e.g., database search, citation searching)
**intervention_condition**: Specific intervention coded, useful for studies with multiple interventions
**brief_description**: Brief summary of the intervention
**study_num_within_paper**: Identifier for calculating cluster-robust standard errors, referencing specific study instances within a larger paper
**outcome**: Dependent variable recorded for analysis
**n_t_post**: Post-intervention sample size for the treatment groups
**n_c_post**: Post-intervention sample size for the control group
**n_t_total_pop**: Total population for the treatment group (subjects not clusters)
**n_c_total_pop**: Total population for the control group (subjects not clusters), divided proportionally when multiple treatments are compared with a single control
**eff_type**: Type of effect used to calculate Glass’s ∆
**u_s_d**: Unstandardized effect size used for Glass’s ∆ calculation
**ctrl_sd**: Standard deviation of the dependent variable in the control group
**neg_null_pos**: Outcome in terms of direction: negative, null, or positive effect as reported by the study
**delay**: Time in days between initial treatment administration and final outcome measurement
**theory**: Guiding methodological theory or framework
**secondary_theory**: Specific theoretical content (e.g., animal welfare, environmental, health)
**self_report**: Indicator for whether data were self-reported (Y/N)
**outcome_category**: Outcome categorization (e.g., original, amount, servings)
**cafeteria_or_restaurant_or_store_based:** Indicator for whether the intervention took place in a cafeteria, restaurant, or store setting
**leaflet**: Whether the treatment was administered via a leaflet (Y/N
**xvideo**:Whether the treatment was administered via a video (Y/N)
**delivery_method**:General category of treatment administration method
**internet**: Whether the treatment was delivered over the internet (Y/N)
**cluster_assigned**: Whether the treatment was assigned at the cluster level (Y/N)
**multi_component**: Whether the treatment was a multi-component intervention (Y/N)
**delay_post_endline**: Delay after treatment ended, typically zero for cafeteria studies
**public_pre_analysis_plan**: Indicator of a public pre-analysis plan (Y/N)
**open_data**: Indicator of publicly available data (Y/N)
**emotional_activation**: Indicator of emotional activation as an intended effect of the intervention (Y/N)
**advocacy_org**: Indicator of advocacy organization involvement in materials used (Y/N)
**country**: Country or countries where the study took place
**population**: Target population for the study
**age_info_if_given**: Age group or setting of the study's participants, if specified
**inclusion_exclusion**: Indicator for inclusion/exclusion criteria, where 0 = included in main dataset, 1 = included in red/processed meat dataset, 2 = excluded (RCT issue), 3 = excluded (underpowered), 4 = excluded (no delay), 5 = substitution issue, 6 = other (notes)
**notes**: Additional notes or comments
**d**: Effect size estimate for analysis (note that this is generated when the document is knit and not in the CSV file)
**var_d**: Variance of the effect size (note that this is generated when the document is knit and not in the CSV file)
**se_d**: Standard error of the effect size (note that this is generated when the document is knit and not in the CSV file)
