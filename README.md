# Manufacturing Benchmarking System
Automated R pipeline for competitive benchmarking of Chinese listed manufacturing firms across green performance, digital capability, R&D intensity and operating efficiency.

This project delivers a reproducible end‑to‑end analytical workflow and a structured competitive intelligence report, designed to support strategic decision‑making for market entrants evaluating China’s manufacturing landscape.

---

## 📌 Project Overview
The system processes firm‑level panel data covering 2016–2024, normalises performance indicators across four core dimensions, and ranks enterprises into three competitive tiers: **Leader, Follower, Laggard**. It quantifies performance gaps, identifies leader traits, and generates publication‑ready tables and visualisations.

All raw source data remains stored locally and is never committed to the public repository — only aggregated outputs and analysis code are shared.

---

## ✨ Key Features
- **Four‑dimensional benchmarking**: green performance, digital capability, R&D intensity, operating efficiency
- **Composite scoring** via min‑max normalisation (0–100 scale) with equal weighting
- **Tier classification**: top 20% = Leaders, bottom 20% = Laggards, remainder = Followers
- **Performance gap analysis**: leader vs laggard absolute and relative gaps per dimension
- **Leader trait identification**: statistical comparison of structural and operational characteristics
- **Automated competitive intelligence report** (RMarkdown, HTML/PDF output)
- **Modular R functions**: reusable scoring, ranking, gap and trait analysis

---

## 📊 Methodology
1. **Data cleaning**: winsorisation at 5%, missing value handling, industry filtering
2. **Dimension scoring**: min‑max normalisation of underlying indicators per dimension
3. **Composite score**: arithmetic mean of the four dimension scores
4. **Ranking & tiering**: overall and dimension‑specific ranks + tier assignment
5. **Gap analysis**: average score difference between leader and laggard cohorts
6. **Output generation**: leaderboard tables, comparative charts, narrative report

---

## 📁 Repository Structure

manufacturing-benchmarking-system/
├── R/                          # Reusable benchmarking functions
│   ├── score_dimensions.R
│   ├── rank_and_tier.R
│   ├── calculate_performance_gap.R
│   └── identify_leader_traits.R
├── scripts/                    # Pipeline execution scripts
│   ├── 01_data_preparation.R
│   └── 02_benchmarking_outputs.R
├── data/                       # Local data only (not committed to GitHub)
│   ├── raw/
│   └── processed/
├── outputs/                    # Generated deliverables
│   ├── tables/                 # Leaderboards, gap summaries, trait tables (CSV)
│   └── charts/                 # Publication-quality charts (PNG, 300 DPI)
├── report/                     # Competitive intelligence report
│   └── competitive_landscape_report.Rmd
├── docs/
│   └── methodology_spec.md
├── .gitignore
├── LICENSE
└── README.md
---
## 🚀 Getting Started

### Prerequisites
- R 4.5+ and RStudio
- Required packages: `dplyr`, `ggplot2`, `readr`, `readxl`, `here`, `knitr`, `tidyr`

### Run the full pipeline
1. Place your raw dataset into `data/raw/`
2. Run `scripts/01_data_preparation.R` to clean and prepare the panel dataset
3. Run `scripts/02_benchmarking_outputs.R` to execute scoring, ranking, gap analysis and export all tables + charts
4. Knit `report/competitive_landscape_report.Rmd` to generate the final competitive intelligence report

---

## 📈 Outputs Generated
### Tables (CSV)
- Top 20 overall industry leaderboard
- Top 10 rankings per dimension
- Performance gap summary (Leader vs Laggard)
- Leader traits statistical comparison

### Charts (PNG, 300 DPI)
- Performance gap bar chart
- 2D competitive position map (Digital × Green)
- Top 10 firms score trends (2016–2024)
- Industry gap evolution over time
- Capability radar profile of top 5 leaders

### Report
- 3‑page competitive intelligence report with executive summary, industry overview, leaderboard and strategic insights

---

## 🛠️ Tech Stack
- **Language**: R
- **Data manipulation**: dplyr, tidyr
- **Visualisation**: ggplot2
- **Reporting**: RMarkdown / knitr
- **Version control**: Git + GitHub
- **Project structure**: here package for reproducible file paths

---

## 📝 Data Note
Raw firm‑level data is not included in this public repository for confidentiality reasons. The repository contains fully reproducible analysis code, methodology documentation and aggregated output results. The pipeline can be adapted to any similarly structured manufacturing firm dataset.

---

## 📄 License
MIT License — see `LICENSE` file for details.