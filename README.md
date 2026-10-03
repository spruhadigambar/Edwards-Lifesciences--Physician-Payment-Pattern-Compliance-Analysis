# Payment Trends & Concentration: Edwards Lifesciences
[Edwards Lifesciences Project.ipynb](https://github.com/user-attachments/files/33003789/Edwards.Lifesciences.Project.ipynb)

A data-driven look at Edwards Lifesciences payment patterns from 2021-2025, combining Python, SQL, and Power BI to uncover key trends and insights.

## Project Overview

This project analyzes physician and healthcare-provider payment data associated with Edwards Lifesciences from 2021 to 2025.

The analysis focuses on payment trends, payment reasons, recipient concentration, product categories, geographic patterns, and high-value transactions.

## Objective

To understand how payment patterns changed over time and identify areas where concentrated, high-value, or changing payment activity may warrant further review.

## Tools Used

- Python – Data cleaning, validation and exploratory analysis
- SQL Server – Data validation and analytical queries
- Power BI – Dashboard and data visualization
- DAX – Measures and year-over-year analysis

## Dataset

Source: CMS Open Payments – General Payments Data  
Period: 2021–2025  
Records: 291,383  
Final columns: 31

## Analysis Performed

### Python
- Cleaned and combined five yearly datasets
- Handled missing values and data types
- Analyzed payment trends and distributions
- Examined recipient and payment concentration
- Analyzed products and geographic patterns
- Identified high-value payment patterns
- Performed year-over-year recipient analysis

### SQL
- Validated record completeness and uniqueness
- Analyzed yearly payment totals
- Examined payment reasons and recipient concentration
- Analyzed products, specialties and geographic distribution
- Identified recipient-level payment patterns

### Power BI
Created an interactive dashboard to explore:
- Total payment value
- Payment count
- Average payment
- Year-over-year payment changes
- Payment reasons
- Recipient patterns
- Product and geographic trends

## Key Findings

- 291,383 payment records were analyzed across 2021–2025.
- Total payment value across the dataset was approximately $95.77 million.
- Payment records increased from 35,317 in 2021 to 72,174 in 2025.
- The top 10 identified recipients accounted for 37.60% of total payment value.
- Consulting Fees represented the highest total payment value among payment reasons.
- Some payment categories had relatively few transactions but substantially higher individual payment amounts.
