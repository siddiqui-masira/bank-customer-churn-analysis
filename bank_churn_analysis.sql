--   BANK CUSTOMER CHURN ANALYSIS USING SQL

-- Creating database and using it.

CREATE DATABASE IF NOT EXISTS bank_churn_db;
USE bank_churn_db;

-- This table holds one row per customer with 20+ details about them
SELECT * FROM bank_churners; -- Checking whether all data is imported or not. 

-- DATA CLEANING

-- i. Checking for Duplicate Customers 
SELECT CLIENTNUM,
COUNT(*) AS record_count
FROM bank_churners
GROUP BY CLIENTNUM
HAVING COUNT(*) > 1;
-- Insight: No duplicates found


-- ii. Checking for Missing or Empty Values 
SELECT
SUM(CASE WHEN Attrition_Flag IS NULL OR Attrition_Flag  = '' THEN 1 ELSE 0 END) AS missing_Attrition_Flag,
SUM(CASE WHEN Customer_Age IS NULL THEN 1 ELSE 0 END) AS missing_Customer_Age,
SUM(CASE WHEN Gender IS NULL OR Gender = '' THEN 1 ELSE 0 END) AS missing_Gender,
SUM(CASE WHEN Education_Level = 'Unknown' THEN 1 ELSE 0 END) AS unknown_Education,
SUM(CASE WHEN Marital_Status  = 'Unknown' THEN 1 ELSE 0 END) AS unknown_Marital_Status,
SUM(CASE WHEN Income_Category = 'Unknown' THEN 1 ELSE 0 END) AS unknown_Income_Category
FROM bank_churners;
/*
Insight: 
Education_Level: 1,519 rows marked 'Unknown'
Marital_Status : 749 rows marked 'Unknown'
Income_Category: 1,112 rows marked 'Unknown'
*/


-- iii. Renaming Labels to Make Them Simpler 
UPDATE bank_churners
SET Attrition_Flag = 
CASE
    WHEN Attrition_Flag = 'Attrited Customer' THEN 'Churned'
    WHEN Attrition_Flag = 'Existing Customer' THEN 'Retained'
    ELSE Attrition_Flag
END;
-- Insight: Every customer is now simply either 'Churned' or 'Retained'.


-- iv. Checking If Category Values Look Correct 
SELECT DISTINCT Card_Category FROM bank_churners ORDER BY 1;
SELECT DISTINCT Income_Category FROM bank_churners ORDER BY 1;
SELECT DISTINCT Education_Level FROM bank_churners ORDER BY 1;
SELECT DISTINCT Marital_Status  FROM bank_churners ORDER BY 1;
-- Insight: No weird entries.


-- v. Checking if Numbers Make Sense
SELECT
MIN(Customer_Age) AS min_age,
MAX(Customer_Age) AS max_age,
MIN(Credit_Limit) AS min_credit,
MAX(Credit_Limit) AS max_credit,
MIN(Total_Trans_Ct) AS min_txn_count,
MAX(Total_Trans_Ct) AS max_txn_count,
MIN(Avg_Utilization_Ratio) AS min_util,
MAX(Avg_Utilization_Ratio) AS max_util
FROM bank_churners;
-- Insight: All numbers are within realistic ranges. 


-- ANALYSIS 

-- Query 1: How Many Customers Churned vs Stayed? 
SELECT
Attrition_Flag AS Customer_Status,
COUNT(*) AS Total_Customers,
ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(), 2) AS Percentage
FROM bank_churners
GROUP BY Attrition_Flag
ORDER BY Total_Customers DESC;
-- Insight: Retained Rate: 83.93% , Churned Rate: 16.07%



-- Query 2: What Is the Exact Churn Rate? 
SELECT
COUNT(*) AS Total_Customers,
SUM(CASE WHEN Attrition_Flag = 'Churned'  THEN 1 ELSE 0 END) AS Churned_Customers,
SUM(CASE WHEN Attrition_Flag = 'Retained' THEN 1 ELSE 0 END) AS Retained_Customers,
ROUND(SUM(CASE WHEN Attrition_Flag = 'Churned' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) AS Churn_Rate_Pct
FROM bank_churners;
-- Insight: Churn Rate = 16.07%


-- Query 3: Do Men or Women Churn More? 
SELECT Gender,
COUNT(*) AS Total_Customers,
SUM(CASE WHEN Attrition_Flag = 'Churned' THEN 1 ELSE 0 END) AS Churned,
ROUND(SUM(CASE WHEN Attrition_Flag = 'Churned' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) AS Churn_Rate_Pct
FROM bank_churners
GROUP BY Gender
ORDER BY Churn_Rate_Pct DESC;
-- Insight: Female churn rate: 17.36% , Male churn rate: 14.62%


-- Query 4: Does Income Level Affect Churn? 
SELECT Income_Category,
COUNT(*) AS Total_Customers,
SUM(CASE WHEN Attrition_Flag = 'Churned' THEN 1 ELSE 0 END) AS Churned,
ROUND(SUM(CASE WHEN Attrition_Flag = 'Churned' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) AS Churn_Rate_Pct
FROM bank_churners
GROUP BY Income_Category
ORDER BY Churn_Rate_Pct DESC;
-- Insight: Both high and low income customers have higher churn rates, while mid-income segments are more stable.


-- Query 5: Does the Type of Card Matter? 
SELECT Card_Category,
COUNT(*) AS Total_Customers,
SUM(CASE WHEN Attrition_Flag = 'Churned' THEN 1 ELSE 0 END) AS Churned,
ROUND(SUM(CASE WHEN Attrition_Flag = 'Churned' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2)AS Churn_Rate_Pct
FROM bank_churners
GROUP BY Card_Category
ORDER BY Total_Customers DESC;
-- Insight: Most customers have a Blue card, and most churned customers are Blue card holders. Gold and Platinum card holders churn less.


-- Query 6: Do Churned Customers Use Less Credit? 
SELECT 
Attrition_Flag AS Customer_Status,
ROUND(AVG(Credit_Limit), 2) AS Avg_Credit_Limit,
ROUND(MIN(Credit_Limit), 2) AS Min_Credit_Limit,
ROUND(MAX(Credit_Limit), 2)  AS Max_Credit_Limit,
ROUND(AVG(Avg_Utilization_Ratio), 4) AS Avg_Utilization_Ratio
FROM bank_churners
GROUP BY Attrition_Flag;
-- Insight: Lower credit usage is strongly linked to higher churn.


-- Query 7: Do Churned Customers Spend Less? 
SELECT
Attrition_Flag AS Customer_Status,
ROUND(AVG(Total_Trans_Amt), 2) AS Avg_Transaction_Amount,
ROUND(AVG(Total_Trans_Ct), 2) AS Avg_Transaction_Count,
ROUND(AVG(Total_Amt_Chng_Q4_Q1), 4) AS Avg_Spend_Change_Q4_Q1
FROM bank_churners
GROUP BY Attrition_Flag;
-- Insight: Churned customers spent less AND made fewer transactions.


-- Query 8: Which High-Spending Customers Already Left? 
SELECT CLIENTNUM,
Customer_Age,
Gender,
Income_Category,
Card_Category,
Credit_Limit,
Total_Trans_Amt,
Attrition_Flag AS Status
FROM bank_churners
WHERE Total_Trans_Amt > 10000 AND Attrition_Flag = 'Churned'
ORDER BY Total_Trans_Amt DESC
LIMIT 20;


-- Query 9: Does Being Inactive Lead to Churning?
SELECT
Months_Inactive_12_mon AS Inactive_Months,
COUNT(*) AS Total_Customers,
SUM(CASE WHEN Attrition_Flag = 'Churned' THEN 1 ELSE 0 END) AS Churned,
ROUND(SUM(CASE WHEN Attrition_Flag = 'Churned' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) AS Churn_Rate_Pct
FROM bank_churners
GROUP BY Months_Inactive_12_mon
ORDER BY Months_Inactive_12_mon;
-- Insight: The more inactive a customer is, the more likely they are to leave.
  

-- Query 10: Does Calling the Bank More = Churning More?
SELECT
Contacts_Count_12_mon AS Contact_Count,
COUNT(*) AS Total_Customers,
SUM(CASE WHEN Attrition_Flag = 'Churned' THEN 1 ELSE 0 END) AS Churned,
ROUND(SUM(CASE WHEN Attrition_Flag = 'Churned' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) AS Churn_Rate_Pct
FROM bank_churners
GROUP BY Contacts_Count_12_mon
ORDER BY Contact_Count;
-- Insight: Customers who contacted the bank 5–6 times in a year churned the most.
  

-- Query 11: Does Holding More Products = Staying Longer?
SELECT
Total_Relationship_Count AS Products_Held,
COUNT(*) AS Total_Customers,
SUM(CASE WHEN Attrition_Flag = 'Churned' THEN 1 ELSE 0 END) AS Churned,
ROUND(SUM(CASE WHEN Attrition_Flag = 'Churned' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) AS Churn_Rate_Pct
FROM bank_churners
GROUP BY Total_Relationship_Count
ORDER BY Total_Relationship_Count;
-- Insight: Customers with less products churn more


-- Query 12: Do Low-Activity Customers Churn More?
SELECT 
CASE
	WHEN Total_Trans_Ct >= 80 THEN 'High Frequency (80+ txns)'
	WHEN Total_Trans_Ct >= 50 THEN 'Medium Frequency (50–79 txns)'
	WHEN Total_Trans_Ct >= 20 THEN 'Low Frequency (20–49 txns)'
	ELSE 'Dormant (<20 txns)'
END AS Transaction_Segment,
COUNT(*) AS Total_Customers,
SUM(CASE WHEN Attrition_Flag = 'Churned' THEN 1 ELSE 0 END) AS Churned,
ROUND(SUM(CASE WHEN Attrition_Flag = 'Churned' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) AS Churn_Rate_Pct
FROM bank_churners
GROUP BY Transaction_Segment
ORDER BY Churn_Rate_Pct DESC;
-- Insight: Customers who barely use their card (<20 transactions/year) have very high churn rate.


-- Query 13: Which Education Level Churn More?
SELECT Education_Level,
COUNT(*) AS Total_Customers,
SUM(CASE WHEN Attrition_Flag = 'Churned' THEN 1 ELSE 0 END) AS Churned,
ROUND(SUM(CASE WHEN Attrition_Flag = 'Churned' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) AS Churn_Rate_Pct
FROM bank_churners
GROUP BY Education_Level
ORDER BY Churn_Rate_Pct DESC;
-- Insight: Doctorate: 21.06% 


-- Query 14: Which Age Group Churns the Most? 
SELECT
CASE
	WHEN Customer_Age BETWEEN 18 AND 30 THEN '18–30 (Young Adults)'
	WHEN Customer_Age BETWEEN 31 AND 45 THEN '31–45 (Mid Career)'
	WHEN Customer_Age BETWEEN 46 AND 60 THEN '46–60 (Pre-Retirement)'
	ELSE '60+ (Seniors)'
END AS Age_Group,
COUNT(*) AS Total_Customers,
SUM(CASE WHEN Attrition_Flag = 'Churned' THEN 1 ELSE 0 END) AS Churned,
ROUND(SUM(CASE WHEN Attrition_Flag = 'Churned' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) AS Churn_Rate_Pct
FROM bank_churners
GROUP BY Age_Group
ORDER BY Churn_Rate_Pct DESC;
-- Insight: 46–60 (Pre-Retirement) age grp churn more (16.62%)


-- Query 15: Who Is Most Likely to Churn? (Risk Scorecard)
SELECT CLIENTNUM,
Customer_Age,
Gender,
Income_Category,
Card_Category,
Total_Trans_Ct,
Months_Inactive_12_mon,
Contacts_Count_12_mon,
Total_Relationship_Count,
Avg_Utilization_Ratio,

-- Calculating the total risk score
(
	CASE WHEN Months_Inactive_12_mon >= 3 THEN 2 ELSE 0 END +
	CASE WHEN Contacts_Count_12_mon >= 4 THEN 2 ELSE 0 END +
	CASE WHEN Total_Relationship_Count <= 2 THEN 2 ELSE 0 END +
	CASE WHEN Total_Trans_Ct <= 40 THEN 2 ELSE 0 END +
	CASE WHEN Avg_Utilization_Ratio <= 0.1 THEN 1 ELSE 0 END +
	CASE WHEN Total_Amt_Chng_Q4_Q1 <= 0.6 THEN 1 ELSE 0 END
) AS Churn_Risk_Score,

-- Assigning a Risk Label based on that score
CASE
	WHEN (
            CASE WHEN Months_Inactive_12_mon >= 3 THEN 2 ELSE 0 END +
            CASE WHEN Contacts_Count_12_mon >= 4 THEN 2 ELSE 0 END +
            CASE WHEN Total_Relationship_Count <= 2 THEN 2 ELSE 0 END +
            CASE WHEN Total_Trans_Ct <= 40 THEN 2 ELSE 0 END +
            CASE WHEN Avg_Utilization_Ratio <= 0.1 THEN 1 ELSE 0 END +
            CASE WHEN Total_Amt_Chng_Q4_Q1 <= 0.6 THEN 1 ELSE 0 END) >= 6 THEN 'HIGH RISK'
	WHEN (
            CASE WHEN Months_Inactive_12_mon >= 3 THEN 2 ELSE 0 END +
            CASE WHEN Contacts_Count_12_mon >= 4 THEN 2 ELSE 0 END +
            CASE WHEN Total_Relationship_Count <= 2 THEN 2 ELSE 0 END +
            CASE WHEN Total_Trans_Ct <= 40 THEN 2 ELSE 0 END +
            CASE WHEN Avg_Utilization_Ratio <= 0.1 THEN 1 ELSE 0 END +
            CASE WHEN Total_Amt_Chng_Q4_Q1 <= 0.6 THEN 1 ELSE 0 END
) >= 3 THEN 'MEDIUM RISK'
	ELSE 'LOW RISK'
END AS Risk_Tier,

Attrition_Flag AS Actual_Status
FROM bank_churners
ORDER BY Churn_Risk_Score DESC
LIMIT 50;
-- Insight: This risk scorecard helps identify high-risk customers before they churn, enabling targeted retention strategies.
