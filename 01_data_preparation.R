# ============================================================
# 01_data_preparation.R
# Phase 2: Data Cleaning & Standardization
# Core sample: 2016-2024
# ============================================================

# --- 1. Load required packages ---
# Install first time only:
# install.packages(c("readxl", "dplyr", "tidyr", "stringr"))

library(readxl)
library(dplyr)
library(tidyr)
library(stringr)

# --- 2. Import raw data ---
raw_data <- read_excel("data/raw/data2.xlsx", sheet = "Sheet1")

# Quick check
cat("Raw data loaded:", nrow(raw_data), "observations,", ncol(raw_data), "columns\n")
cat("Year range:", min(raw_data$year, na.rm = TRUE), "-", max(raw_data$year, na.rm = TRUE), "\n")

# --- 3. Rename columns to standardized English names ---
clean_data <- raw_data %>%
  rename(
    stock_code = `证券代码`,
    firm_id = id,
    firm_name = `证券简称`,
    list_date = `上市日期`,
    list_year = `上市年份`,
    year = year,
    industry = `所属行业`,
    ownership_concentration1 = `股权集中指标1`,
    ownership_concentration4 = `股权集中指标4`,
    customer_concentration = `客户集中度`,
    supplier_concentration = `供应商集中度`,
    supply_chain_concentration = `供应链集中度`,
    leverage = `资产负债率`,
    carbon_reduction = `碳减排量`,
    carbon_emission = `碳排放量`,
    carbon_emission_dup = `碳排放`,
    carbon_intensity = `碳排放强度`,
    ownership_type = `产权性质`,
    is_st = `是否发生ST或ST或PT`,
    roaa = `总资产净利润率ROAA`,
    asset_growth = `总资产增长率B`,
    retained_earnings = `留存收益`,
    capital_expenditure = `资本支出`,
    hhi_a = HHIA,
    hhi_b = HHIB,
    hhi_c = HHIC,
    hhi_d = HHID,
    rd_expenditure = `研发投入金额`,
    rd_intensity_ratio = `研发投入占营业收入比例`,
    fixed_assets = `固定资产净额`,
    revenue = `营业收入`,
    operating_cash_flow = `经营活动产生的现金流量净额`,
    ai_tech = `人工智能技术`,
    blockchain_tech = `区块链技术`,
    cloud_tech = `云计算技术`,
    bigdata_tech = `大数据技术`,
    digital_tech_count = `数字技术应用`,
    list_board = `上市板块`,
    founding_date = `成立日期`,
    province = `所在省份`,
    city = `所在地级市`,
    district = `所在县级市`,
    industry_name_b = `行业名称B`,
    industry_code_b = `行业代码B`,
    digital_transformation_index = `数字化转型指数`,
    esg_overall_rating = `综合评级`,
    esg_overall_score = `综合得分`,
    esg_e_rating = `E评级`,
    esg_e_score = `E得分`,
    esg_s_rating = `S评级`,
    esg_s_score = `S得分`,
    esg_g_rating = `G评级`,
    esg_g_score = `G得分`,
    green_executive_ratio = `环保背景高管的比例`,
    internal_control_rating = `内部控制指数评级`,
    internal_control_score = `内部控制指数评分`,
    green_tfp = `企业绿色全要素生产率`,
    digital_executive_count = `具有数字化专业背景高管数量`,
    env_regulation_intensity = `环境规制强度`,
    green_supply_chain_year = `绿色供应链统计年度`,
    green_supply_chain = `是否绿色供应链`,
    province_code = `省份代码`,
    digital_economy_index = `数字经济指数`,
    is_heavy_pollution = `是否重污染`,
    is_high_tech = `是否高技术制造业`
  )

# --- 4. Apply sample filters ---
clean_data <- clean_data %>%
  # Core analysis window: 2016-2024
  filter(year >= 2016) %>%
  # Remove ST/*ST/PT firms
  filter(is_st == 0)

cat("After filtering (2016-2024, non-ST):", nrow(clean_data), "observations\n")
cat("Firms in sample:", length(unique(clean_data$stock_code)), "\n")

# --- 5. Engineer derived performance metrics ---
clean_data <- clean_data %>%
  mutate(
    # Operating efficiency metrics
    asset_turnover = revenue / fixed_assets,
    operating_cash_ratio = operating_cash_flow / revenue,
    
    # Ensure digital tech count is numeric
    digital_tech_count = as.numeric(digital_tech_count),
    
    # Replace Inf / -Inf with NA (caused by zero division)
    across(c(asset_turnover, operating_cash_ratio), 
           ~ ifelse(is.infinite(.x), NA, .x))
  )

# --- 6. Apply 1% winsorization to all continuous performance metrics ---
winsorize <- function(x, prob = 0.01) {
  q_low <- quantile(x, prob, na.rm = TRUE)
  q_high <- quantile(x, 1 - prob, na.rm = TRUE)
  x[x < q_low] <- q_low
  x[x > q_high] <- q_high
  return(x)
}

# List of variables to winsorize
perf_vars <- c(
  "carbon_intensity", "carbon_emission", "esg_e_score", "green_tfp",
  "digital_transformation_index", "digital_tech_count", "digital_executive_count",
  "rd_expenditure", "rd_intensity_ratio",
  "roaa", "asset_turnover", "operating_cash_ratio",
  "leverage", "revenue", "fixed_assets"
)

clean_data <- clean_data %>%
  group_by(year) %>%
  mutate(across(all_of(perf_vars), winsorize)) %>%
  ungroup()

cat("Winsorization applied to", length(perf_vars), "variables\n")

# --- 7. Save clean analysis datasets ---

# Full panel dataset (2016-2024)
saveRDS(clean_data, "data/processed/panel_2016_2024.rds")

# Latest year cross-section (2023) for ranking
cross_section_2023 <- clean_data %>%
  filter(year == 2023)

saveRDS(cross_section_2023, "data/processed/cross_section_2023.rds")

cat("\n=== Phase 2 Complete ===\n")
cat("Panel dataset saved: data/processed/panel_2016_2024.rds\n")
cat("Cross-section (2023) saved: data/processed/cross_section_2023.rds\n")
cat("Firms in 2023 sample:", nrow(cross_section_2023), "\n")