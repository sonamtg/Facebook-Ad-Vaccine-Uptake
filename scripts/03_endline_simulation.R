library(tidyverse)
library(here)

seed <- 37779665
set.seed(seed)

# Load and prepare baseline survey data
# Keep only needed columns
baseline_surv <- read_csv(here("data", "raw", "baseline_survey.csv")) %>%
  select(unique_id, baseline_date, vaccinated, covid_concern_num)

# Load treatment assignment information
assign_info <- read_csv(here("data", "raw", "treatment_assignment.csv"))

# Create endline survey data by joining necessary baseline info and treatment info
endline_surv <- left_join(baseline_surv, assign_info, by = "unique_id") %>%
  # Randomly sample 4500 participants for endline
  slice_sample(n = 4500) %>%
  mutate(
    # Simulate time between surveys (14-28 days using Poisson distribution)
    survey_gap = 14 + rpois(n(), lambda = 7),
    # Calculate endline date by adding gap to baseline date
    endline_date = baseline_date + days(survey_gap),

    # Base vaccination probability for unvaccinated participants:
    # - Minimum 5% probability
    # - Increases with COVID concern level (+2% per level)
    # - Individual unforeseen randomness
    # - Capped at 12% maximum baseline probability
    # Base probability with individual random effects
    base_prob = ifelse(vaccinated == 1,
                       1,  # Already vaccinated stays vaccinated
                       pmin(0.05 + 0.02 * covid_concern_num + rnorm(n(), mean = 0, sd = 0.015), 0.12)),

    # Add treatment effects to probability (ONLY for unvaccinated):
    prob_vaccinated = case_when(
      vaccinated == 1 ~ 1,  # No change for already vaccinated
      assignment == "Reason" ~ pmin(base_prob + 0.06, 0.95), # +6% effect
      assignment == "Emotions" ~ pmin(base_prob + 0.11, 0.95), # +11% effect (stronger)
      TRUE ~ base_prob  # Control group gets no treatment effect
    ),

    # Simulate final vaccination status using binomial distribution
    vaccinated_endline = rbinom(n(), 1, prob_vaccinated)
  ) %>%
  # Keep only essential columns for output
  select(unique_id, assignment, endline_date, vaccinated_endline)

# Save endline survey data to CSV file
write_csv(endline_surv, here("data", "raw", "endline_survey.csv"))

