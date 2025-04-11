#00_run.R script

# Set to 0 or 1 to only run some of the scripts from the 00_run.R script (see the example below).

# Run script for example project

# PACKAGES ------------------------------------------------------------------
library(here)

# PRELIMINARIES -------------------------------------------------------------
# Control which scripts run
run_01_baseline_simulation   <- 1
run_02_treatment_assign      <- 1
run_03_endline_simulation    <- 1
run_04_merge_and_process     <- 1
run_05_gen_output            <- 1

# RUN SCRIPTS ---------------------------------------------------------------

# Create the baseline survey dataset
if (run_01_baseline_simulation) source(here("scripts", "01_baseline_simulation.R"), encoding = "UTF-8")
# INPUTS:
#   None (generates synthetic data)
# OUTPUTS
#  here("data", "raw", "baseline_survey.csv") # Baseline survey data

# Creates a datset with information on the random assignments
if (run_02_treatment_assign) source(here("scripts", "02_treatment_assign.R"), encoding = "UTF-8")
# INPUTS
#  here("data", "raw", "baseline_survey.csv") # 01_baseline_simulation.R
# OUTPUTS
#  here("data", "raw", "treatment_assignment.csv")) # Dataset with user id and assignment

# Creates the endline survey data with only the necessary columns
if (run_03_endline_simulation) source(here("scripts", "03_endline_simulation.R"), encoding = "UTF-8")
# INPUTS
#  here("data", "raw", "baseline_survey.csv") # 01_baseline_simulation.R
#  here("data", "raw", "treatment_assignment.csv") # Dataset with user id and assignment
# OUTPUTS
#  here("data", "raw", "endline_survey.csv") # Dataset with user id, assignment, endline vaccination and endline survey date

# Create a merged dataset and different summarized datasets for figures and tables
if (run_04_merge_and_process) source(here("scripts", "04_merge_and_process.R"), encoding = "UTF-8")
# INPUTS
#  here("data", "raw", "endline_survey.csv") # 03_endline_simulation.R
# OUTPUTS
#  here("data", "cooked", "merged_baseline_assignment_endline.csv") # Merged dataset with all columns from the baseline, assignment, and endline
#  here("data", "cooked", "campaign_effectiveness_summary.csv") # Campaign effectiveness summary
#  here("data", "cooked", "conversion_rate_by_covid_concern.csv") # Vaccination conversion rate by COVID concern
#  here("data", "cooked", "conversion_rate_by_age.csv") # Vaccination conversion rate by age group
#  here("data", "cooked", "vax_rates_all_particip.csv") # Vaccination rates that includes all participants
#  here("data", "cooked", "vax_rates_initially_unvax.csv") # Vaccination rates that includes unvaccinated people only

# Create figures and tables
if (run_05_gen_output) source(here("scripts", "05_gen_output.R"), encoding = "UTF-8")
# INPUTS
#  here("data", "cooked", "campaign_effectiveness_summary.csv")
#  here("data", "cooked", "conversion_rate_by_covid_concern.csv")
#  here("data", "cooked", "conversion_rate_by_age.csv")
#  here("data", "cooked", "vax_rate_all_particip.csv")
#  here("data", "cooked", "vax_rates_initially_unvax.csv")
# OUTPUTS
#  here("outputs", "figures", "conversion_rates_by_campaign.png")
#  here("outputs", "figures", "vaccination_uplift.png")
#  here("outputs", "figures", "conversion_rate_by_concern.png")
#  here("outputs", "figures", "conversion_rate_by_age.png")
#  here("outputs", "tables", "vaccination_rates_all.png")
#  here("outputs", "tables", "vaccination_rates_initial_unvax.png")


