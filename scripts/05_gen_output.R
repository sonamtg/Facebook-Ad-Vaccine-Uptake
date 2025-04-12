library(tidyverse)
library(gt)
library(webshot2)
library(here)

# 1st Plot: Conversion Rates by Campaign Group
# - Bar plot showing vaccination conversion rates for each treatment group
# - Includes 95% confidence intervals and exact percentage labels

# Load campaign effectiveness summary data
camp_effect_summ <- read_csv(here("data", "cooked", "campaign_effectiveness_summary.csv"))

# Create bar plot of conversion rates
conv_rate_by_camp_plot <- camp_effect_summ %>%
  ggplot(aes(x = assignment, y = conversion_rate, fill = assignment)) +
  geom_col() +
  # Add an error bar to show the SE of the conversion rate
  geom_errorbar(aes(ymin = conversion_rate - 1.96*se,
                    ymax = conversion_rate + 1.96*se),
                width = 0.25,
                linewidth = 0.7,
                color = "black") +
  # Text to show the conversion rate value on top of the bar
  geom_text(aes(label = scales::percent(conversion_rate, accuracy = 0.1)),
            vjust = -0.5) +
  # Format y-axis as percentages with dynamic upper limit
  scale_y_continuous(
    labels = scales::percent,
    limits = c(0, max(effectiveness$conversion_rate + 2*effectiveness$se) * 1.1),
    expand = expansion(mult = c(0, 0.05))) + # Remove padding at bottom
      labs(
                title = "Vaccination Conversion by Campaign",
                subtitle = "Among initially unvaccinated participants (95% CIs)",
                x = NULL,            # Cleaner than empty string
                y = "Endline vaccination rate",
                fill = "Campaign"
              ) +
              theme_minimal(base_size = 12) +
              theme(
                # Remove redundant legend
                legend.position = "none",
                panel.grid.major.x = element_blank(),  # Cleaner x-axis
                # Centered title
                plot.title = element_text(face = "bold", hjust = 0.5),
                # Centered subtitle
                plot.subtitle = element_text(hjust = 0.5, color = "grey40")
              )

# Save the Conversion Rates by Campaign Group plot
ggsave(
  filename = here::here("outputs", "figures", "conversion_rates_by_campaign.png"),
  bg = "white",
  plot = conv_rate_by_camp_plot,
  width = 6,
  height = 4,
  dpi = 300
)

# 2nd Plot: Causal Effect of Campaigns on Vaccination
# - Bar plot showing the additional vaccination percentage gained from each campaign
# - Compared to the control group baseline
vax_uplift_plot <- camp_effect_summ %>%
  filter(assignment != "Control") %>%
  ggplot(aes(x = assignment, y = campaign_uplift, fill = assignment)) +
  geom_col(width = 0.6) +
  # Add error bars for uplift estimates
  geom_errorbar(aes(ymin = campaign_uplift - 1.96*se,
                    ymax = campaign_uplift + 1.96*se),
                width = 0.15) +
  # Label bars with uplift percentages
  geom_text(aes(label = str_c("+", scales::percent(campaign_uplift, accuracy = 0.1))),
            vjust = -0.5) +
  labs(title = "Causal Effect of Campaigns on Vaccination",
       subtitle = "Uplift over control group",
       x = "",
       y = "Percentage Point Increase") +
  # Format y-axis with "+" signs for positive values
  scale_y_continuous(labels = scales::percent_format(prefix = "+")) +
  theme_minimal() +
  theme(legend.position = "none") # Remove redundant legend

# Save uplift plot
ggsave(
  filename = here("outputs", "figures", "vaccination_uplift.png"),
  bg = "white",
  plot = vax_uplift_plot,
  width = 6,
  height = 4,
  dpi = 300
)

# 3rd Plot: Conversion Rates by COVID Concern Level
# - Grouped bar plot showing how treatment effects vary by baseline concern
conv_rate_covid <- read_csv(here("data", "cooked", "conversion_rate_by_covid_concern.csv"))

# Bar plot to show how vaccination rate differs by COVID Concern level
conv_rate_covid_plot <- conv_rate_covid %>%
  ggplot(aes(x = covid_concern_label, y = conversion, fill = assignment)) +
  # Side-by-side bars for each treatmen
  geom_col(position = "dodge") +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Conversion Rates by COVID Concern",
       x = "COVID Concern Label",
       y = "Vaccination Rate") +
  # Custom color scheme for treatment groups
  scale_fill_manual(values = c("Control" = "grey",
                               "Reason" = "purple",
                               "Emotions" = "darkorange")) +
  theme_minimal()

# Save COVID concern plot
ggsave(filename = here("outputs", "figures", "conversion_rate_by_concern.png"),
       plot = conv_rate_covid_plot,
       bg = "white",
       width = 8,
       height = 5,
       dpi = 300)

# 4th Plot: Conversion Rates by Age Group
# - Grouped bar plot showing treatment effects across different age brackets
conv_rate_age <- read_csv(here("data", "cooked", "conversion_rate_by_age.csv"))

# Bar plot to show how vaccination rate differs by Age Group
conv_rate_age_plot <- conv_rate_age %>%
  ggplot(aes(x = age_group, y = conversion, fill = assignment)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Conversion Rates by Age Group",
       x = "Age Group",
       y = "Vaccination Rate") +
  # Consistent color scheme with the COVID Concern plot
  scale_fill_manual(values = c("Control" = "grey",
                               "Reason" = "purple",
                               "Emotions" = "darkorange")) +
  theme_minimal()

# Save age group plot
ggsave(
  filename = here("outputs", "figures", "conversion_rate_by_age.png"),
  bg = "white",
  plot = conv_rate_age_plot,
  width = 8,
  height = 5,
  dpi = 300)

# Table 1: Vaccination Rates for All Participants
# - Formatted table showing baseline vs endline vaccination rates
# - Includes absolute and relative changes
vax_rates_all_particip <- read_csv(here("data", "cooked", "vax_rates_all_particip.csv"))

vax_rates_all_particip_tbl <- vax_rates_all_particip %>%
  gt() %>%
  # Format all columns as percentages with 1 decimal place
  fmt_percent(columns = everything(), decimals = 1) %>%
  # Add title and subtitle
  tab_header(
    title = "Vaccination Rates: Before vs After Campaign",
    subtitle = "Among all participants"
  ) %>%
  # Rename column header
  cols_label(
    assignment = "Campaign"
  ) %>%
  # Center-align all columns
  cols_align(align = "center") %>%
  # Bold column headers
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_column_labels()
  )

# Save the vaccination rates table (all participants)
gtsave(
  data = vax_rates_all_particip_tbl,
  filename = here("outputs", "tables", "vaccination_rates_all.png"),
  zoom = 2  # Improves resolution
)

# Table 2: Vaccination Campaign Effectiveness Among Initially Unvaccinated Participants
# - Focused results for the target population (baseline unvaccinated)
# - Shows counts and conversion rates
vax_rates_init_unvax <- read_csv(here("data", "cooked", "vax_rates_initially_unvax.csv"))

vax_rates_init_unvax_tbl <- vax_rates_init_unvax%>%
  gt() %>%
  # Format counts with thousands separatorss
  fmt_number(columns = c(`Baseline Unvax`, `Newly Vax (Endline)`),
             decimals = 0, use_seps = TRUE) %>%
  # Format conversion rate as percentage
  fmt_percent(columns = `Conversion Rate`, decimals = 1) %>%
  # Add title and subtitle
  tab_header(
    title = "Vaccination Campaign Effectiveness",
    subtitle = "Among initially unvaccinated participants") %>%
  # Center-align all columns
  cols_align(align = "center") %>%
  # Bold column headers
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_column_labels())

# Save the vaccination campaign effectiveness table (initially unvaccinated)
gtsave(
  data = vax_rates_init_unvax_tbl,
  filename = here("outputs", "tables", "vaccination_rates_initial_unvax.png"),
  zoom = 2)
