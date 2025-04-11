library(tidyverse)
library(randomizr)
library(here)

seed <- 20332651
set.seed(seed)

# Load baseline survey data from CSV file
# Uses here() to construct platform-independent file path
baseline_surv <- read_csv(here("data", "raw", "baseline_survey.csv"))

# Create treatment assignment information
assign_info <- tibble(
  # Keep original participant IDs
  unique_id = baseline_surv$unique_id,

  # Randomly assign participants to one of three conditions:
  # "Reason", "Emotions", or "Control" groups
  # Uses complete randomization (equal probability for each condition)
  assignment = complete_ra(N = nrow(baseline_surv), conditions = c("Reason", "Emotions", "Control")))

# Verify campaign proportion
# Counts number of participants in each condition and calculates proportions
assign_info %>%
  count(assignment) %>%
  mutate(prop = n / sum(n))

# Save treatment assignments to CSV file
# Output path: data/raw/treatment_assignment.csv
write_csv(assign_info, here("data", "raw", "treatment_assignment.csv"))

