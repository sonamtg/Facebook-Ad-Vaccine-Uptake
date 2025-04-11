library(tidyverse)
library(here)

base_assign_end_merged <- read_csv(here("data", "raw", "endline_survey.csv")) %>%
  left_join(read_csv(here("data", "raw", "baseline_survey.csv")), by = "unique_id") %>%
  mutate(treatment_responder = ifelse(vaccinated == 0 & vaccinated_endline == 1 & assignment %in% c("Reason", "Emotion"), 1, 0)) %>%
  write_csv(here("data", "cooked", "merged_baseline_assignment_endline.csv"))


base_assign_end_merged %>%
  filter(vaccinated == 0) %>%
  group_by(assignment) %>%
  summarize(n = n(),
            conversion_rate = mean(vaccinated_endline),
            se = sqrt(conversion_rate * (1 - conversion_rate) / n)) %>%
  ungroup() %>%
  # The percentage of unvaccinated people in the control group got vaccinated by endline without any intervention
  mutate(control_rate = conversion_rate[assignment == "Control"],
         campaign_uplift = conversion_rate - control_rate,
         ci_lower = conversion_rate - 1.96*se,
         ci_upper = conversion_rate + 1.96*se
  ) %>%
  write_csv(here("data", "cooked", "campaign_effectiveness_summary.csv"))

base_assign_end_merged %>%
  filter(vaccinated == 0) %>%
  group_by(assignment, covid_concern_label) %>%
  summarize(conversion = mean(vaccinated_endline)) %>%
  ungroup() %>%
  write_csv(here("data", "cooked", "conversion_rate_by_covid_concern.csv"))

base_assign_end_merged %>%
  filter(vaccinated == 0) %>%
  group_by(assignment, age_group = cut(age, breaks = c(18, 30, 45, 65, 90), include.lowest = TRUE)) %>%
  summarize(conversion = mean(vaccinated_endline)) %>%
  ungroup() %>%
  write_csv(here("data", "cooked", "conversion_rate_by_age.csv"))

base_assign_end_merged %>%
  group_by(assignment) %>%
  summarize(`Vaccination Rate (Baseline)` = mean(vaccinated),
            `Vaccination Rate (Endline)` = mean(vaccinated_endline),
            `Vaccination Rate Change (Absolute)` = `Vaccination Rate (Endline)` - `Vaccination Rate (Baseline)`,
            `Vaccination Rate Change (Relative)` = `Vaccination Rate Change (Absolute)` / `Vaccination Rate (Baseline)`) %>%
  ungroup() %>%
  write_csv(here("data", "cooked", "vax_rates_all_particip.csv"))

base_assign_end_merged %>%
  filter(vaccinated == 0) %>%  # Focus on initially unvaccinated
  group_by(Group = assignment) %>%
  summarize(`Baseline Unvax` = n(),  # Count of unvaccinated at baseline
            `Newly Vax (Endline)` = sum(vaccinated_endline),  # Count who converted
            `Conversion Rate` = mean(vaccinated_endline)) %>% # Proportion converted
  ungroup() %>%
  write_csv(here("data", "cooked", "vax_rates_initially_unvax.csv"))
