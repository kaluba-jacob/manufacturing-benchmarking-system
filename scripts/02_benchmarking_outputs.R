# ============================================================
# 02_benchmarking_outputs.R
# Phase 4: Generate leaderboard tables and comparison charts
# ============================================================

# --- 1. Load packages ---
library(dplyr)
library(ggplot2)

# --- 2. Source all benchmarking functions ---
source("R/score_dimensions.R")
source("R/rank_and_tier.R")
source("R/calculate_performance_gap.R")
source("R/identify_leader_traits.R")

# --- 3. Load clean data ---
panel_data <- readRDS("data/processed/panel_2016_2024.rds")
data_2023 <- readRDS("data/processed/cross_section_2023.rds")

cat("Data loaded. Running full benchmarking pipeline...\n")

# --- 4. Run full benchmarking pipeline ---
scored_2023 <- score_dimensions(data_2023)
ranked_2023 <- rank_and_tier(scored_2023)
gap_table <- calculate_performance_gap(ranked_2023)
traits_table <- identify_leader_traits(ranked_2023)

cat("Benchmarking complete. Generating outputs...\n")

# --- 5. Export leaderboard tables ---

# 5.1 Overall Top 20 leaderboard
top20_overall <- ranked_2023 %>%
  arrange(rank_overall) %>%
  slice(1:20) %>%
  select(
    rank_overall, stock_code, firm_name, industry,
    score_composite, score_green, score_digital, score_rd, score_efficiency,
    tier
  ) %>%
  mutate(across(where(is.numeric), round, 2))

write.csv(top20_overall, "outputs/tables/top20_overall_leaderboard.csv", row.names = FALSE)

# 5.2 Per-dimension Top 10 rankings
export_top10 <- function(data, score_col, rank_col, filename) {
  data %>%
    arrange(!!sym(rank_col)) %>%
    slice(1:10) %>%
    select(stock_code, firm_name, industry, all_of(c(score_col, rank_col))) %>%
    mutate(across(where(is.numeric), round, 2)) %>%
    write.csv(paste0("outputs/tables/", filename), row.names = FALSE)
}

export_top10(ranked_2023, "score_green", "rank_green", "top10_green.csv")
export_top10(ranked_2023, "score_digital", "rank_digital", "top10_digital.csv")
export_top10(ranked_2023, "score_rd", "rank_rd", "top10_rd.csv")
export_top10(ranked_2023, "score_efficiency", "rank_efficiency", "top10_efficiency.csv")

# 5.3 Performance gap summary
write.csv(gap_table, "outputs/tables/performance_gap_summary.csv", row.names = TRUE)

# 5.4 Leader traits summary
write.csv(traits_table, "outputs/tables/leader_traits_summary.csv", row.names = FALSE)

cat("All tables exported to outputs/tables/\n")

# --- 6. Generate comparison charts ---

# Set professional theme
theme_benchmark <- function() {
  theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(size = 11, color = "#555555"),
      axis.title = element_text(size = 11),
      legend.position = "bottom",
      panel.grid.minor = element_blank()
    )
}

# Chart 1: Leader-Laggard Performance Gap Bar Chart
gap_plot_data <- gap_table %>%
  tibble::rownames_to_column("Dimension") %>%
  select(Dimension, Leader, Laggard) %>%
  tidyr::pivot_longer(-Dimension, names_to = "Tier", values_to = "Score")

p1 <- ggplot(gap_plot_data, aes(x = reorder(Dimension, Score), y = Score, fill = Tier)) +
  geom_col(position = "dodge", width = 0.7, alpha = 0.85) +
  scale_fill_manual(values = c("Leader" = "#1a5276", "Laggard" = "#aab7b8")) +
  coord_flip() +
  labs(
    title = "Performance Gap: Market Leaders vs. Laggards",
    subtitle = "Average normalized score by dimension (0-100 scale)",
    x = "", y = "Score"
  ) +
  theme_benchmark()

ggsave("outputs/charts/chart1_performance_gap.png", p1, width = 9, height = 5, dpi = 300)

# Chart 2: 2D Competitive Map (Digital vs Green)
p2 <- ggplot(ranked_2023, aes(x = score_digital, y = score_green, color = tier)) +
  geom_point(alpha = 0.6, size = 1.5) +
  scale_color_manual(values = c("Leader" = "#196f3d", "Follower" = "#f39c12", "Laggard" = "#922b21")) +
  labs(
    title = "Competitive Position Map: Digital Capability vs. Green Performance",
    subtitle = "Each dot = one manufacturing firm (2023, n = 3,090)",
    x = "Digital Capability Score", y = "Green Performance Score",
    color = "Tier"
  ) +
  theme_benchmark()

ggsave("outputs/charts/chart2_competitive_map.png", p2, width = 9, height = 7, dpi = 300)

# Chart 3: Composite Score Trends 2016-2024 (Top 10 firms)
top10_firms <- top20_overall$stock_code[1:10]

panel_scored <- panel_data %>%
  score_dimensions() %>%
  filter(stock_code %in% top10_firms)

p3 <- ggplot(panel_scored, aes(x = year, y = score_composite, color = firm_name)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  labs(
    title = "Composite Score Trends: Top 10 Firms (2016–2024)",
    x = "Year", y = "Composite Score", color = "Firm"
  ) +
  theme_benchmark() +
  theme(legend.position = "right")

ggsave("outputs/charts/chart3_top10_trends.png", p3, width = 10, height = 6, dpi = 300)

# Chart 4: Industry-wide Gap Evolution 2016-2024
yearly_gaps <- panel_data %>%
  group_by(year) %>%
  group_split() %>%
  lapply(function(df) {
    scored <- score_dimensions(df)
    ranked <- rank_and_tier(scored)
    gaps <- calculate_performance_gap(ranked)
    gaps$year <- unique(df$year)
    gaps$dimension <- rownames(gaps)
    return(gaps)
  }) %>%
  bind_rows()

p4 <- ggplot(yearly_gaps, aes(x = year, y = absolute_gap, color = dimension)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  labs(
    title = "Performance Gap Evolution: 2016–2024",
    subtitle = "Leader-Laggard absolute score gap by dimension",
    x = "Year", y = "Absolute Gap (points)", color = "Dimension"
  ) +
  theme_benchmark()

ggsave("outputs/charts/chart4_gap_evolution.png", p4, width = 10, height = 6, dpi = 300)

# Chart 5: Radar Chart - Top 5 Firms Comparison
top5_data <- ranked_2023 %>%
  arrange(rank_overall) %>%
  slice(1:5) %>%
  select(firm_name, score_green, score_digital, score_rd, score_efficiency) %>%
  tidyr::pivot_longer(-firm_name, names_to = "dimension", values_to = "score")

p5 <- ggplot(top5_data, aes(x = dimension, y = score, group = firm_name, color = firm_name)) +
  geom_polygon(fill = NA, linewidth = 0.8) +
  geom_point(size = 2) +
  coord_radial() +
  labs(
    title = "Capability Profile: Top 5 Market Leaders",
    subtitle = "Dimension scores (0-100 scale)",
    x = "", y = "", color = "Firm"
  ) +
  theme_benchmark() +
  theme(axis.text.y = element_blank())

ggsave("outputs/charts/chart5_radar_top5.png", p5, width = 9, height = 8, dpi = 300)

cat("All 5 charts exported to outputs/charts/\n")
cat("\n=== Phase 4 Complete ===\n")

# --- 6. Generate publication-quality comparison charts ---

# Set clean professional theme
theme_benchmark <- function() {
  theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(size = 11, color = "#555555"),
      axis.title = element_text(size = 11),
      legend.position = "bottom",
      panel.grid.minor = element_blank()
    )
}

# Chart 1: Leader vs Laggard Performance Gap Bar Chart
gap_plot_data <- gap_table %>%
  tibble::rownames_to_column("Dimension") %>%
  select(Dimension, Leader, Laggard) %>%
  tidyr::pivot_longer(-Dimension, names_to = "Tier", values_to = "Score")

p1 <- ggplot(gap_plot_data, aes(x = reorder(Dimension, Score), y = Score, fill = Tier)) +
  geom_col(position = "dodge", width = 0.7, alpha = 0.85) +
  scale_fill_manual(values = c("Leader" = "#1a5276", "Laggard" = "#aab7b8")) +
  coord_flip() +
  labs(
    title = "Performance Gap: Market Leaders vs. Laggards",
    subtitle = "Average normalized score by dimension (0–100 scale)",
    x = "", y = "Score"
  ) +
  theme_benchmark()

ggsave("outputs/charts/chart1_performance_gap.png", p1, width = 9, height = 5, dpi = 300)

# Chart 2: 2D Competitive Position Map (Digital vs Green)
p2 <- ggplot(ranked_2023, aes(x = score_digital, y = score_green, color = tier)) +
  geom_point(alpha = 0.6, size = 1.5) +
  scale_color_manual(values = c("Leader" = "#196f3d", "Follower" = "#f39c12", "Laggard" = "#922b21")) +
  labs(
    title = "Competitive Position Map: Digital Capability vs. Green Performance",
    subtitle = "Each dot = one manufacturing firm (2023, n = 3,090)",
    x = "Digital Capability Score", y = "Green Performance Score",
    color = "Tier"
  ) +
  theme_benchmark()

ggsave("outputs/charts/chart2_competitive_map.png", p2, width = 9, height = 7, dpi = 300)

# Chart 3: Composite Score Trends for Top 10 Firms (2016–2024)
top10_firms <- top20_overall$stock_code[1:10]

panel_scored <- panel_data %>%
  score_dimensions() %>%
  filter(stock_code %in% top10_firms)

p3 <- ggplot(panel_scored, aes(x = year, y = score_composite, color = firm_name)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  labs(
    title = "Composite Score Trends: Top 10 Firms (2016–2024)",
    x = "Year", y = "Composite Score", color = "Firm"
  ) +
  theme_benchmark() +
  theme(legend.position = "right")

ggsave("outputs/charts/chart3_top10_trends.png", p3, width = 10, height = 6, dpi = 300)

# Chart 4: Industry-wide Performance Gap Evolution (2016–2024)
yearly_gaps <- panel_data %>%
  group_by(year) %>%
  group_split() %>%
  lapply(function(df) {
    scored <- score_dimensions(df)
    ranked <- rank_and_tier(scored)
    gaps <- calculate_performance_gap(ranked)
    gaps$year <- unique(df$year)
    gaps$dimension <- rownames(gaps)
    return(gaps)
  }) %>%
  bind_rows()

p4 <- ggplot(yearly_gaps, aes(x = year, y = absolute_gap, color = dimension)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  labs(
    title = "Performance Gap Evolution: 2016–2024",
    subtitle = "Leader–Laggard absolute score gap by dimension",
    x = "Year", y = "Absolute Gap (points)", color = "Dimension"
  ) +
  theme_benchmark()

ggsave("outputs/charts/chart4_gap_evolution.png", p4, width = 10, height = 6, dpi = 300)

# Chart 5: Radar Profile of Top 5 Market Leaders
top5_data <- ranked_2023 %>%
  arrange(rank_overall) %>%
  slice(1:5) %>%
  select(firm_name, score_green, score_digital, score_rd, score_efficiency) %>%
  tidyr::pivot_longer(-firm_name, names_to = "dimension", values_to = "score")

p5 <- ggplot(top5_data, aes(x = dimension, y = score, group = firm_name, color = firm_name)) +
  geom_polygon(fill = NA, linewidth = 0.8) +
  geom_point(size = 2) +
  coord_radial() +
  labs(
    title = "Capability Profile: Top 5 Market Leaders",
    subtitle = "Dimension scores (0–100 scale)",
    x = "", y = "", color = "Firm"
  ) +
  theme_benchmark() +
  theme(axis.text.y = element_blank())

ggsave("outputs/charts/chart5_radar_top5.png", p5, width = 9, height = 8, dpi = 300)

cat("All 5 charts exported to outputs/charts/\n")
cat("\n=== Phase 4 Complete ===\n")
