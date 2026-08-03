# ============================================================
# identify_leader_traits.R
# Runs statistical tests to identify firm characteristics
# that significantly differentiate Leaders from non-Leaders
# ============================================================

identify_leader_traits <- function(data) {
  
  # Create binary leader flag
  data <- data %>%
    mutate(is_leader = ifelse(tier == "Leader", 1, 0))
  
  # List of firm characteristics to test
  trait_vars <- c(
    "leverage", "asset_growth", "ownership_concentration1",
    "customer_concentration", "supplier_concentration",
    "hhi_a", "internal_control_score",
    "digital_executive_count", "green_executive_ratio",
    "ownership_type", "is_high_tech", "is_heavy_pollution"
  )
  
  # Calculate means and run t-tests
  results <- data.frame()
  
  for (var in trait_vars) {
    
    # Skip if variable doesn't exist or is not numeric
    if (!var %in% colnames(data)) next
    if (!is.numeric(data[[var]])) next
    
    leader_vals <- data[[var]][data$is_leader == 1]
    non_leader_vals <- data[[var]][data$is_leader == 0]
    
    mean_leader <- mean(leader_vals, na.rm = TRUE)
    mean_nonleader <- mean(non_leader_vals, na.rm = TRUE)
    
    # Welch's t-test
    t_test <- try(t.test(leader_vals, non_leader_vals), silent = TRUE)
    
    if (inherits(t_test, "try-error")) {
      p_val <- NA
    } else {
      p_val <- t_test$p.value
    }
    
    diff_pct <- (mean_leader - mean_nonleader) / mean_nonleader * 100
    
    row <- data.frame(
      variable = var,
      mean_leader = round(mean_leader, 3),
      mean_nonleader = round(mean_nonleader, 3),
      difference_pct = round(diff_pct, 2),
      p_value = round(p_val, 4),
      significant = ifelse(p_val < 0.05, "Yes", "No")
    )
    
    results <- rbind(results, row)
  }
  
  # Sort by absolute difference magnitude
  results <- results[order(-abs(results$difference_pct)), ]
  
  return(results)
}

library(dplyr)
# Identify leader traits
traits_results <- identify_leader_traits(ranked_2023)
print(traits_results)