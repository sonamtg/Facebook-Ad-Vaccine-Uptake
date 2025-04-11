# Load required libraries
library(tidyverse)
library(randomizr) # For random assignment
library(here) # Path for reproducible work

# Set random seed for reproducibility (generated using random.org)
# Ensures same results each time code runs
seed <- 32055016
set.seed(32055016)

# Set total participants to 5000
total_particip <- 5000

# Define the labels as I will be using them multiple times later
educ_levels <- c("Less than HS", "HS", "Some college", "College", "More than college")
fb_freq <- c("Daily", "Weekly", "Monthly", "Rarely")
gender <- c("Male", "Female", "Non-binary")

# Create baseline survey data
baseline_surv <- tibble(
  # Create unique IDs for each participant
  # Chose a starting ID = 135780 and increases sequentally after that
  unique_id = 135780:(135780 + total_particip - 1),

  # Random survey dates between May 1-15, 2021
  baseline_date = sample(seq(ymd("2021-05-01"), ymd("2021-05-15"), by = "day"),
                         size = total_particip, replace = TRUE),

  # Generate age distribution (right-skewed gamma distribution)
  # Few older people in the survey and the avg age is 40
  # Min Age = 18 and Max Age = 90
  age = round(rgamma(total_particip, shape = 6, rate = 0.15)) %>%
    pmax(18) %>%
    pmin(90)) %>%
  mutate(
    # Gender distribution varies by age group
    gender = case_when(
      age <= 25 ~ sample(gender,
                         prob = c(0.44, 0.46, 0.10),
                         size = n(), replace = TRUE),
      age > 25 & age <= 40 ~ sample(gender,
                         prob = c(0.45, 0.50, 0.05),
                         size = n(), replace = TRUE),
      TRUE ~ sample(gender,
                    prob = c(0.48, 0.515, 0.005),
                    size = n(), replace = TRUE)
    ),

    # Race distribution approximating US demographics
    race = sample(c("White", "Hispanic", "Black", "Asian", "Other"),
                  prob = c(0.5, 0.25, 0.13, 0.08, 0.04),
                  size = n(), replace = TRUE),

    # Geographic region distribution
    location = sample(c("Northeast", "Midwest", "West", "South"),
                      prob = c(0.23, 0.22, 0.30, 0.25),
                      size = n(), replace = TRUE),

    # Education level varies by age group
    education = case_when(
      age <= 25 ~ sample(educ_levels, prob = c(0.1, 0.3, 0.25, 0.31, 0.04),
                         size = n(), replace = TRUE),
      age > 25 & age <= 40 ~ sample(educ_levels, prob = c(0.15, 0.26, 0.24, 0.27, 0.08),
                         size = n(), replace = TRUE),
      TRUE ~ sample(educ_levels, prob = c(0.18, 0.28, 0.20, 0.29, 0.05),
                    size = n(), replace = TRUE)
    ),

    # Marriage probability increases with age
    married = case_when(
      age <= 25 ~ rbinom(n(), 1, 0.15),
      age > 25 & age <= 40 ~ rbinom(n(), 1, 0.74),
      TRUE ~ rbinom(n(), 1, 0.82)
    ),

    # COVID-19 concern levels (1-5 scale) and label
    covid_concern_num = sample(1:5, prob = c(0.1, 0.21, 0.32, 0.26, 0.11),
                               size = n(), replace = TRUE),
    covid_concern_label = case_when(
      covid_concern_num == 1 ~ "Not concerned",
      covid_concern_num == 2 ~ "Slightly concerned",
      covid_concern_num == 3 ~ "Moderately concerned",
      covid_concern_num == 4 ~ "Very concerned",
      covid_concern_num == 5 ~ "Extremely concerned"
    ),

    # Vaccine trust varies by education level
    vaccine_trust = case_when(
      education %in% c("Less than HS", "HS") ~
        sample(c("No trust", "Neutral", "Trust"),
               prob = c(0.33, 0.50, 0.17),  # Lower trust
               size = n(), replace = TRUE),

      education == "Some college" ~
        sample(c("No trust", "Neutral", "Trust"),
               prob = c(0.25, 0.45, 0.30),  # Moderate trust
               size = n(), replace = TRUE),

      education %in% c("College", "More than college") ~
        sample(c("No trust", "Neutral", "Trust"),
               prob = c(0.15, 0.40, 0.45),  # Higher trust
               size = n(), replace = TRUE),

      TRUE ~ sample(c("No trust", "Neutral", "Trust"),
                    size = n(), replace = TRUE)  # Fallback
    ),

    # Base vaccination probability by age
    base_prob = case_when(
      age >= 65 ~ 0.18,
      age <= 25 ~ 0.10,
      age > 25 & age < 65 ~ 0.12
    ),

    # Education effect on vaccination probability
    educ_eff = case_when(
      education %in% c("College", "More than college") ~ 0.07,
      education == "Some college" ~ 0.03,
      TRUE ~ 0
    ),

    # Trust effect on vaccination probability
    trust_eff = case_when(
      vaccine_trust == "Trust" ~ 0.05, # Positive effect
      vaccine_trust == "No trust" ~ -0.03,  # Negative effect
      TRUE ~ 0 # Neutral
    ),

    # Combine probabilities (capped at 15%)
    prob_vax = pmin(base_prob + educ_eff + trust_eff, 0.15),
    vaccinated = rbinom(n(), 1, prob_vax), # Simulate vaccination status

    # Recent COVID exposure (18% probability)
    recent_expos = rbinom(n(), 1, 0.18),

    # Facebook usage frequency by age
    # 25-40 age group are the most active on FB on a daily and weekly basis
    fb_active = case_when(
      age <= 25 ~ sample(fb_freq, prob = c(0.18, 0.33, 0.25, 0.24),
                         size = n(), replace = TRUE),
      age > 25 & age <= 40 ~ sample(fb_freq, prob = c(0.37, 0.34, 0.18, 0.11),
                         size = n(), replace = TRUE),
      TRUE ~ sample(fb_freq, prob = c(0.11, 0.32, 0.19, 0.38),
                    size = n(), replace = TRUE)
    )) %>%

  # Remove intermediate calculation columns
  select(-c(base_prob, educ_eff, trust_eff, prob_vax))

# Save baseline data to CSV file
write_csv(baseline_surv, here("data", "raw", "baseline_survey.csv"))
