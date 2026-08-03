Phase 1: Variable Mapping & Methodology Specification

1. Analysis Scope
Core sample window: 2016–2024 (9 years)
Primary ranking cross-section: 2023 (most recent complete year)
Supplementary long-term context: 2005–2024, used only for operating efficiency and R&D long-term trend analysis
Exclusion rule: All ST/*ST/PT firm-year observations are removed from the benchmark sample
Outlier treatment: 1% winsorization (top and bottom) on all continuous performance metrics
Missing values: Industry-year median imputation for minor gaps; firms with >30% missing core metrics are dropped from ranking

2. Four Benchmark Dimensions & Variable Mapping
Dimension 1: Green Performance (Weight = 25%)

Raw Variable (Chinese)	  English Variable Name	     Direction	                 Source
碳排放强度	              carbon_intensity	         Negative (lower = better)	 Direct
碳排放量	                carbon_emission	           Negative	                   Direct
E 得分	                  esg_e_score	               Positive	                   Direct
企业绿色全要素生产率	    green_tfp   	             Positive	                   Direct
是否绿色供应链	          green_supply_chain	       Positive (binary)	         Direct

Dimension 2: Digital Capability (Weight = 25%)
Raw Variable	              English Variable Name	         Direction
数字化转型指数	            digital_transformation_index	 Positive
数字技术应用	              digital_tech_count	           Positive
具有数字化专业背景高管数量	digital_executive_count	       Positive
人工智能技术	              ai_tech	                       Positive (binary sub-component)
区块链技术	                blockchain_tech	               Positive (binary sub-component)
云计算技术	                cloud_tech	                   Positive (binary sub-component)
大数据技术	                bigdata_tech	                 Positive (binary sub-component)
Note: The four binary tech variables sum into digital_tech_count.

Dimension 3: R&D Intensity (Weight = 25%)
Raw Variable	          English Variable Name	  Direction
研发投入占营业收入比例	rd_intensity_ratio	    Positive
研发投入金额	          rd_expenditure	        Positive (size-adjusted)

Dimension 4: Operating Efficiency (Weight = 25%)

Raw Variable	                        English Variable Name	   Direction
总资产净利润率                        ROAA	roaa	             Positive
营业收入 / 固定资产净额	              asset_turnover	         Positive (calculated)
经营活动产生的现金流量净额 / 营业收入	operating_cash_ratio	   Positive (calculated)

3. Scoring Methodology
All raw indicators are normalized to 0–100 scale using min-max scaling within each year
Negative indicators (carbon intensity, emissions) are inverted so higher = better
Indicators within each dimension are averaged equally
Final composite score = weighted average of the 4 dimensions (default: 25% each)

4. Tier Classification
Market Leaders: Top 20% of composite score
Industry Followers: Middle 60%
Performance Laggards: Bottom 20%

5. Analysis Outputs Defined
Overall ranking + per-dimension rankings
Leader-Laggard performance gap (absolute and percentage)
Leader trait identification (statistical mean difference tests)
2016–2024 trend analysis for composite score and dimension gaps