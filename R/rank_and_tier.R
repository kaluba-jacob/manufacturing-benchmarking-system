# ============================================================
# rank_and_tier.R
# Assigns overall and per-dimension ranks
# and classifies firms into Leader / Follower / Laggard tiers
# ============================================================

rank_and_tier <- function(data, leader_pct = 0.2, laggard_pct = 0.2) {
  
  ranked <- data %>%
    mutate(
      # Overall rank (1 = best performing firm)
      rank_overall = rank(-score_composite, na.last = "keep", ties.method = "min"),
      
      # Per-dimension ranks
      rank_green = rank(-score_green, na.last = "keep", ties.method = "min"),
      rank_digital = rank(-score_digital, na.last = "keep", ties.method = "min"),
      rank_rd = rank(-score_rd, na.last = "keep", ties.method = "min"),
      rank_efficiency = rank(-score_efficiency, na.last = "keep", ties.method = "min"),
      
      # Tier classification: Top 20% = Leader, Bottom 20% = Laggard, middle 60% = Follower
      tier = case_when(
        score_composite >= quantile(score_composite, 1 - leader_pct, na.rm = TRUE) ~ "Leader",
        score_composite <= quantile(score_composite, laggard_pct, na.rm = TRUE) ~ "Laggard",
        TRUE ~ "Follower"
      ),
      
      tier = factor(tier, levels = c("Leader", "Follower", "Laggard"))
    )
  
  return(ranked)
}

ranked_2023 <- rank_and_tier(scored_2023)
table(ranked_2023$tier)