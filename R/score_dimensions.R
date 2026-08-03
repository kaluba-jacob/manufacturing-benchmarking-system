# ============================================================
# score_dimensions.R
# Normalizes raw indicators and calculates 4 benchmark dimension scores
# plus overall composite score using min-max scaling
# ============================================================

score_dimensions <- function(data, weights = c(green = 0.25,
                                               digital = 0.25,
                                               rd = 0.25,
                                               efficiency = 0.25)) {
  
  # Helper: min-max normalize to 0-100 scale
  normalize <- function(x) {
    if (all(is.na(x))) return(x)
    rng <- range(x, na.rm = TRUE)
    if (diff(rng) == 0) return(rep(50, length(x)))
    (x - rng[1]) / diff(rng) * 100
  }
  
  # Helper: invert negative indicators (lower = better becomes higher = better)
  invert <- function(x) {
    100 - x
  }
  
  scored <- data %>%
    mutate(
      # --- Dimension 1: Green Performance ---
      green_carbon_intensity = invert(normalize(carbon_intensity)),
      green_carbon_emission = invert(normalize(carbon_emission)),
      green_esg_e = normalize(esg_e_score),
      green_tfp = normalize(green_tfp),
      green_supply_chain = normalize(green_supply_chain),
      
      score_green = rowMeans(cbind(green_carbon_intensity,
                                   green_carbon_emission,
                                   green_esg_e,
                                   green_tfp,
                                   green_supply_chain),
                             na.rm = TRUE),
      
      # --- Dimension 2: Digital Capability ---
      digital_index = normalize(digital_transformation_index),
      digital_tech = normalize(digital_tech_count),
      digital_exec = normalize(digital_executive_count),
      
      score_digital = rowMeans(cbind(digital_index,
                                     digital_tech,
                                     digital_exec),
                               na.rm = TRUE),
      
      # --- Dimension 3: R&D Intensity ---
      rd_amount = normalize(rd_expenditure),
      rd_ratio = normalize(rd_intensity_ratio),
      
      score_rd = rowMeans(cbind(rd_amount, rd_ratio), na.rm = TRUE),
      
      # --- Dimension 4: Operating Efficiency ---
      eff_roaa = normalize(roaa),
      eff_turnover = normalize(asset_turnover),
      eff_cash = normalize(operating_cash_ratio),
      
      score_efficiency = rowMeans(cbind(eff_roaa,
                                        eff_turnover,
                                        eff_cash),
                                  na.rm = TRUE),
      
      # --- Overall Composite Score ---
      score_composite = score_green * weights["green"] +
        score_digital * weights["digital"] +
        score_rd * weights["rd"] +
        score_efficiency * weights["efficiency"]
    )
  
  return(scored)
}

library(dplyr)
# Load clean 2023 data
data_2023 <- readRDS("data/processed/cross_section_2023.rds")

# Run the scoring function
scored_2023 <- score_dimensions(data_2023)

# Check results
cat("Composite score range:", round(range(scored_2023$score_composite, na.rm = TRUE), 2), "\n")
cat("Average composite score:", round(mean(scored_2023$score_composite, na.rm = TRUE), 2), "\n")

