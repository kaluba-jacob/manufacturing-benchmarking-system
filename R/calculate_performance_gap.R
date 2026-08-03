# ============================================================
# calculate_performance_gap.R
# Computes Leader vs. Laggard performance gaps
# for composite score and each dimension
# ============================================================

calculate_performance_gap <- function(data) {
  
  # Calculate mean scores by tier
  gap_table <- data %>%
    group_by(tier) %>%
    summarise(
      composite = mean(score_composite, na.rm = TRUE),
      green = mean(score_green, na.rm = TRUE),
      digital = mean(score_digital, na.rm = TRUE),
      rd = mean(score_rd, na.rm = TRUE),
      efficiency = mean(score_efficiency, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    t() %>%
    as.data.frame()
  
  # Clean up output
  colnames(gap_table) <- gap_table[1, ]
  gap_table <- gap_table[-1, ]
  gap_table <- sapply(gap_table, as.numeric)
  rownames(gap_table) <- c("Composite", "Green", "Digital", "R&D", "Efficiency")
  
  # Calculate gap metrics
  gap_df <- as.data.frame(gap_table) %>%
    mutate(
      absolute_gap = Leader - Laggard,
      pct_gap_vs_laggard = (Leader - Laggard) / Laggard * 100
    )
  
  gap_df <- round(gap_df, 2)
  
  return(gap_df)
}

library(dplyr)
# Calculate performance gaps
gap_results <- calculate_performance_gap(ranked_2023)
print(gap_results)