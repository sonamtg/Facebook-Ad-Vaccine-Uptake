library(tidyverse)
library(randomizr)

# For reproducibility
set.seed(123)

# Set total participants to 5000
tot_part <- 5000

# Random assignment: 1/3 receive the first ad (reason), 1/3 the second ad (emotions), and 1/3 none (control group).
rand_assig <- c(1/3, 1/3, 1/3)

baseline_surv <- tibble(
  unique_id = 135780: (135780 + tot_part-1),
  # The mean age is 40 with a light right skew
  age = round(rgamma(tot_part, shape = 6, rate = 0.15)) %>%
    pmax(18) %>%
    pmin(90),

  gender = ifelse(age <= 25, sample(c("Male", "Female", "Non-binary"), prob = c(0.44, 0.46, 0.10),
                                    size = tot_part, replace = TRUE),
                  ifelse(age > 25 & age <= 40, sample(c("Male", "Female", "Non-binary"), prob = c(0.45, 0.50, 0.05),
                                                      size = tot_part, replace = TRUE),
                         sample(c("Male", "Female", "Non-binary"), prob = c(0.48, 0.515, 0.005),
                                size = tot_part, replace = TRUE))),

  race = sample(c("White", "Hispanic", "Black", "Asian", "Other"), prob = c(0.5, 0.25, 0.13, 0.08, 0.04),
                size = tot_part, replace = TRUE),

  location = sample(c("Northeast", "Midwest", "West", "South"), prob = c(0.23, 0.22, 0.30, 0.25),
                    size = tot_part, replace = TRUE),

  education = ifelse(age <= 25, sample(c("Less than HS", "HS", "Some college", "College", "More than college"), prob = c(0.1, 0.3, 0.25, 0.31, 0.04),
                                       size = tot_part, replace = TRUE),
                     ifelse(age > 25 & age <= 40, sample(c("Less than HS", "HS", "Some college", "College", "More than college"), prob = c(0.15, 0.26, 0.24, 0.27, 0.08),
                                                         size = tot_part, replace = TRUE),
                            sample(c("Less than HS", "HS", "Some college", "College", "More than college"), prob = c(0.18, 0.28, 0.20, 0.29, 0.05),
                                   size = tot_part, replace = TRUE))),
  married = ifelse(age <= 25, rbinom(tot_part, 1, prob = 0.09),
                   ifelse(age > 25 & age <= 40, rbinom(tot_part, 1, prob = 0.74),
                          rbinom(tot_part, 1, prob = 0.82))),

  covid_concern = {
    # Generate numeric categorical values and assign probability
    vals <- sample(1:5, size = tot_part, prob = c(0.1, 0.14, 0.35, 0.3, 0.11), replace = TRUE)
    # Then convert to labels
    ifelse(vals == 1, "Not concerned",
           ifelse(vals == 2, "Slightly concerned",
                  ifelse(vals == 3, "Moderately concerned",
                         ifelse(vals == 4, "Very concerned",
                                "Extremely concerned"))))
  },

  vaccine_trust = {
    # Generate numeric categorical values and assign probability
    vals <- sample(1:3, size = tot_part, prob = c(0.21, 0.44, 0.35), replace = TRUE)
    # Then convert to labels
    ifelse(vals == 1, "No trust",
           ifelse(vals == 2, "Neutral",
                  "Trust"))
  },

  vaccinated = rbinom(tot_part, 1, prob = 0.12),

  recent_expos = rbinom(tot_part, 1, prob = 0.18),

  fb_active = ifelse(age <= 25, sample(c("Daily", "Weekly", "Monthly", "Rarely"), prob = c(0.18, 0.33, 0.25, 0.24),
                                       size = tot_part, replace = TRUE),
                     ifelse(age > 25 & age <= 40, sample(c("Daily", "Weekly", "Monthly", "Rarely"), prob = c(0.23, 0.29, 0.25, 0.23),
                                                         size = tot_part, replace = TRUE),
                            sample(c("Daily", "Weekly", "Monthly", "Rarely"), prob = c(0.11, 0.32, 0.19, 0.38),
                                   size = tot_part, replace = TRUE))),
)
