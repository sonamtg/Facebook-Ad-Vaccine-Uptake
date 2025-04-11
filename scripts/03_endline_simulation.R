#########-------------------------------------------------###################
#########------- Endline survey simulation code ----------####################
#########-------------------------------------------------####################
#########-------------------------------------------------###################

library(tidyverse)
library(here)

seed <- 37779665
set.seed(seed)

baseline_surv <- read_csv(here("data", "raw", "baseline_survey.csv")) %>%
  select(unique_id, baseline_date, vaccinated, covid_concern_num)

assign_info <- read_csv(here("data", "raw", "treatment_assignment.csv"))

endline_surv <- left_join(baseline_surv, assign_info, by = "unique_id") %>%
  slice_sample(n = 4500) %>%
  mutate(
    # Time gap between surveys (14-28 days)
    survey_gap = 14 + rpois(n(), lambda = 7),
    endline_date = baseline_date + days(survey_gap),
    # Base probability of vaccination (for unvaccinated only)
    base_prob = ifelse(vaccinated == 1, 1,  # Already vaccinated stays 1
                       pmin(0.05 + 0.02 * covid_concern_num, 0.12)),  # Baseline for others

    # Treatment effect ONLY for unvaccinated
    # I am assuming the Emotions treatment had a bigger effect on vaccination than Reason
    prob_vaccinated = case_when(
      vaccinated == 1 ~ 1,  # No change for already vaccinated
      assignment == "Reason" ~ pmin(base_prob + 0.06, 0.95),
      assignment == "Emotions" ~ pmin(base_prob + 0.11, 0.95),
      TRUE ~ base_prob  # Control group
    ),

    # Simulate final vaccination status
    vaccinated_endline = rbinom(n(), 1, prob_vaccinated)
  ) %>%
  select(unique_id, assignment, endline_date, vaccinated_endline)

write_csv(endline_surv, here("data", "raw", "endline_survey.csv"))

