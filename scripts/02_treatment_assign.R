library(tidyverse)
library(randomizr)
library(here)

seed <- 20332651
set.seed(seed)

baseline_surv <- read_csv(here("data", "raw", "baseline_survey.csv"))


assign_info <- tibble(unique_id = baseline_surv$unique_id,
                      assignment = complete_ra(N = nrow(baseline_surv), conditions = c("Reason", "Emotions", "Control")))

# Verify campaign proportion
assign_info %>%
  count(assignment) %>%
  mutate(prop = n / sum(n))

write_csv(assign_info, here("data", "raw", "treatment_assignment.csv"))

