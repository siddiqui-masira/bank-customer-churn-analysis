# Bank Customer Churn Analysis

SQL + Excel project analyzing customer attrition patterns for a bank, uncovering the behavioral and demographic factors that drive churn and building a risk scorecard to flag at-risk customers before they leave.

## 📁 Project Structure

| File | Description |
|---|---|
| `BankChurners_Data.csv` | Raw dataset — 10,000+ customers with demographics, account activity, and churn status |
| `bank_churn_analysis.sql` | Full SQL workflow: data cleaning, validation, and 15 analytical queries |
| `bank_customer_churn_analysis.xlsx` | Excel dashboard with pivot tables and visualizations |
| `bank_customer_churn_analysis.xlsm` | Macro-enabled version of the dashboard |
| `Bank_Churn_Report.docx` | Written report summarizing methodology, findings, and recommendations |

## 🎯 Objective

Identify which customers are most likely to churn and why — using transaction behavior, engagement patterns, and demographics — so the bank can prioritize retention efforts on the right segments.

## 🔍 Approach

**1. Data Cleaning & Validation (SQL)**
- Checked for duplicate customers (none found)
- Flagged missing/unknown values across `Education_Level`, `Marital_Status`, and `Income_Category`
- Standardized `Attrition_Flag` labels to `Churned` / `Retained`
- Validated numeric fields (age, credit limit, transaction counts) for realistic ranges

**2. Exploratory & Segmentation Analysis (SQL)**
- Measured overall churn rate and breakdowns by gender, income, card type, education, and age group
- Compared spending, credit usage, and engagement between churned vs. retained customers
- Analyzed inactivity, service contact frequency, and product holdings as churn predictors

**3. Risk Scorecard**
- Built a weighted scoring model combining inactivity, low product count, low transaction count, low utilization, service complaints, and declining spend to classify customers into **High / Medium / Low** risk tiers

**4. Dashboard & Reporting (Excel)**
- Visualized churn rates by segment in an interactive pivot-based dashboard
- Summarized findings and actionable recommendations in the written report

## 📊 Key Findings

- **Overall churn rate: 16.07%** (83.93% retained vs. 16.07% churned)
- **Engagement is the #1 driver of churn** — customers with under 20 transactions/year churn at a dramatically higher rate than active users
- **Inactivity compounds risk** — the more months a customer goes inactive within a year, the more likely they are to churn
- **Fewer products = higher churn** — customers holding fewer relationship products (accounts/cards) churn significantly more than multi-product customers
- **Spending behavior matters** — churned customers show lower average transaction amounts, lower transaction counts, and a bigger Q4-vs-Q1 spend decline
- **Contact frequency is a warning sign** — customers who contacted the bank 5–6 times in a year had the highest churn rate, suggesting unresolved service issues
- **Credit usage** — churned customers carry a lower average credit utilization ratio despite similar credit limits
- **Card tier** — Blue cardholders (the majority segment) account for most churn; Gold/Platinum holders churn less
- **Demographics play a smaller but notable role**: women churn slightly more than men (17.36% vs. 14.62%), the 46–60 age group churns most (16.62%), and Doctorate-level customers show the highest churn by education (21.06%)
- **High-value customers do churn** — a segment of customers spending over $10,000/year still left, representing avoidable revenue loss

## 🧮 Risk Scorecard Logic

Each customer is scored using weighted flags:

| Condition | Points |
|---|---|
| Inactive 3+ months in the year | +2 |
| Contacted bank 4+ times in the year | +2 |
| Holds 2 or fewer products | +2 |
| 40 or fewer transactions in the year | +2 |
| Credit utilization ratio ≤ 0.1 | +1 |
| Spend change (Q4 vs Q1) ≤ 0.6 | +1 |

**Score ≥ 6 → High Risk | Score ≥ 3 → Medium Risk | Below → Low Risk**

## 🛠️ Tools Used

- **SQL** — data cleaning, segmentation, risk scoring
- **Excel** — PivotTables, dashboard visualization, macro-enabled reporting

## 📈 Dashboard Preview


## 💡 Recommendations

- Prioritize retention outreach for **High Risk** customers flagged by the scorecard, especially those inactive 3+ months with low product holdings
- Investigate service quality — customers contacting support 5–6 times/year churn most, pointing to unresolved complaints as a churn trigger
- Encourage product cross-sell (a second/third product) for single-product customers, since product count is one of the strongest retention factors
- Re-engagement campaigns for low-frequency card users (<20 transactions/year), the highest-risk behavioral segment
- Monitor high-value customers proactively — some $10K+ spenders still churned, representing preventable revenue loss

## 📄 Full Report

See [`Bank_Churn_Report.docx`](./Bank_Churn_Report.docx) for the complete write-up.
