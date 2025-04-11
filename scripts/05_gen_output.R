library(tidyverse)
library(gt)
library(webshot2)
library(here)

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
  scale_y_continuous(
    labels = scales::percent,
    # Make the upper limit dynamic
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
                plot.title = element_text(face = "bold", hjust = 0.5),
                plot.subtitle = element_text(hjust = 0.5, color = "grey40")
              )

ggsave(
  filename = here::here("outputs", "figures", "conversion_rates_by_campaign.png"),
  bg = "white",
  plot = conv_rate_by_camp_plot,
  width = 6,
  height = 4,
  dpi = 300
)


vax_uplift_plot <- camp_effect_summ %>%

  ggplot(aes(x = assignment, y = campaign_uplift, fill = assignment)) +
  geom_col(width = 0.6) +
  geom_errorbar(aes(ymin = campaign_uplift - 1.96*se,
                    ymax = campaign_uplift + 1.96*se),
                width = 0.15) +
  geom_text(aes(label = str_c("+", scales::percent(campaign_uplift, accuracy = 0.1))),
            vjust = -0.5) +
  labs(title = "Campaign Effectiveness: Vaccination uplift over control",
       x = "",
       y = "Percentage Point Increase") +
  scale_y_continuous(labels = scales::percent_format(prefix = "+")) +
  theme_minimal() +
  theme(legend.position = "none")


ggsave(
  filename = here::here("outputs", "figures", "vaccination_uplift.png"),
  bg = "white",
  plot = vax_uplift_plot,
  width = 6,    # Width in inches (adjust for your needs)
  height = 4,   # Height in inches
  dpi = 300     # High resolution for publications
)


conv_rate_covid <- read_csv(here("data", "cooked", "conversion_rate_by_covid_concern.csv"))

conv_rate_covid_plot <- conv_rate_covid %>%
  ggplot(aes(x = covid_concern_label, y = conversion, fill = assignment)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Conversion Rates by COVID Concern",
       x = "COVID Concern Label",
       y = "Vaccination Rate") +
  scale_fill_manual(values = c("Control" = "grey",
                               "Reason" = "purple",
                               "Emotions" = "darkorange")) +
  theme_minimal()

ggsave(filename = here::here("outputs", "figures", "conversion_rate_by_concern.png"),
       plot = conv_rate_covid_plot,
       bg = "white",
       width = 8,
       height = 5,
       dpi = 300)

conv_rate_age <- read_csv(here("data", "cooked", "conversion_rate_by_age.csv"))


conv_rate_age_plot <- conv_rate_age %>%
  ggplot(aes(x = age_group, y = conversion, fill = assignment)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Conversion Rates by Age Group",
       x = "Age Group",
       y = "Vaccination Rate") +
  scale_fill_manual(values = c("Control" = "grey",
                               "Reason" = "purple",
                               "Emotions" = "darkorange")) +
  theme_minimal()

ggsave(
  filename = here::here("outputs", "figures", "conversion_rate_by_age.png"),
  bg = "white",
  plot = conv_rate_age_plot,
  width = 8,
  height = 5,
  dpi = 300)

vax_rates_all_particip <- read_csv(here("data", "cooked", "vax_rate_all_particip.csv"))

vax_rates_all_particip_tbl <- vax_rates_all_particip %>%
  gt() %>%
  fmt_percent(columns = everything(), decimals = 1) %>%
  tab_header(
    title = "Vaccination Rates: Before vs After Campaign",
    subtitle = "Among all participants"
  ) %>%
  cols_label(
    assignment = "Campaign"
  ) %>%
  cols_align(align = "center") %>%
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_column_labels()
  )

# Save as PNG
gtsave(
  data = vax_rates_all_particip_tbl,
  filename = here::here("outputs", "tables", "vaccination_rates_all.png"),
  zoom = 2  # Improves resolution
)

vax_rates_init_unvax <- read_csv(here("data", "cooked", "vax_rates_initially_unvax.csv"))


vax_rates_init_unvax_tbl <- vax_rates_init_unvax%>%
  gt() %>%
  fmt_number(columns = c(`Baseline Unvax`, `Newly Vax (Endline)`),
             decimals = 0, use_seps = TRUE) %>%
  fmt_percent(columns = `Conversion Rate`, decimals = 1) %>%
  tab_header(
    title = "Vaccination Campaign Effectiveness",
    subtitle = "Among initially unvaccinated participants") %>%
  cols_align(align = "center") %>%
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_column_labels())

# Save as PNG
gtsave(
  data = vax_rates_init_unvax_tbl,
  filename = here::here("outputs", "tables", "vaccination_rates_initial_unvax.png"),
  zoom = 2)
