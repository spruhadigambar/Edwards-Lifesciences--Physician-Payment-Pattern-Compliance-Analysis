use edwards_lifesciences
-- Create table edwards_payments
create table edwards_payments (
    Change_Type varchar(50),
    Recipient_Type varchar(50),
    Teaching_Hospital_ID bigint,
    Teaching_Hospital_Name varchar(200),
    Recipient_Profile_ID bigint,
    Recipient_NPI bigint,
    Recipient_City varchar(100),
    Recipient_State varchar(50),
    Recipient_Zip_Code varchar(20),
    Recipient_Primary_Type varchar(500),
    Recipient_Specialty varchar(1000),
    Recipient_License_State varchar(50),
    Total_Amount_of_Payment decimal(18,2)
        check (Total_Amount_of_Payment >= 0),
    Date_of_Payment date not null,
    Number_of_Payments_Included_in_Total_Amount int,
    Form_of_Payment varchar(300),
    Reason_for_Payment varchar(500) NOT NULL,
    City_of_Travel varchar(100),
    State_of_Travel varchar(50),
    Country_of_Travel varchar(100),
    Third_Party_Payment_Recipient_Indicator varchar(20),
    [Context/Comment] varchar(3000),
    Payment_Record_ID bigint,
    Related_Product_Indicator varchar(20),
    Covered_or_Noncovered varchar(50),
    Indicate_Drug_or_Biological_or_Device varchar(100),
    Product_Category varchar(1000),
    Product_Name varchar(1000),
    Product_ID bigint,
    Program_Year int,
    Recipient_Name varchar(500),

    constraint PK_Payment_Record_ID primary key (Payment_Record_ID),

    constraint CK_Total_Amount_of_Payment check (Total_Amount_of_Payment>=0)

);
--The table is create and datatypes are assigned. The ID columns have lengthy ID hence BIGINT is used instead of INT just to be safe.
-- Constraints are given to three columns: Primary key constraint is given because Payment_Record_ID has unique values and can be used to identify each record uniquely.
-- Check constraint is given to total amount column because we dont want any negative values in amount column.
-- AS we have unique payment record for each row we have date of payment for each row hence not null constraint is given for validation.
--constraints names are also assigned so in future if we want to make any changes or drop the constraint we know the name.

ALTER TABLE edwards_payments
ALTER COLUMN Third_Party_Payment_Recipient_Indicator VARCHAR(100);

--2. Bulk Insert data into the created table
bulk insert edwards_payments
from "C:\Users\spruh\Downloads\edwards_payments_cleaned.csv"
with(
    format = 'CSV',
    firstrow = 2,
    fieldquote = '"',
    tablock
    )

--Data Validation and Understanding
--Goal: Make sure the SQL dataset is reliable before analysing it
--Q1. Is the imported dataset complete, unique, and valid?
--i)
select count(*) from edwards_payments --total number of records

--ii)
select payment_record_id, count(*)
from edwards_payments
group by payment_record_id
having count(*)>1
--there are no duplicate payment_record_ids 

--iii) 
select payment_record_id
from edwards_payments
where Payment_Record_ID is null
--there are no null values in primary key. hence each record can be uniquely identified.


--Q2. Give me an overview of Edwards Lifesciences' payment activity between 2021 and 2025. What stands out?
--i)
select sum(Total_Amount_of_Payment) as total_payment
from edwards_payments
--total payment 95774964.90

--ii) 
select round(avg(total_amount_of_payment),2) as avg_payment
from edwards_payments
--avg payment 328.69

--iii)
select program_year, sum(total_amount_of_payment) as total_payment
from edwards_payments
group by Program_Year
order by total_payment desc
--maximum payment was done in 2024 with least in 2022

--iv)
select count(payment_record_id)
from edwards_payments
--total transactions 291383 in 5 years

--v)
select top 1 total_amount_of_payment, program_year, reason_for_payment
from edwards_payments
order by total_amount_of_payment desc
--max payment across all years was of 4000000.00 in 2021 for acquisitions

--vi)
with yearly_payment as(
select program_year, sum(total_amount_of_payment) as total_payment
from edwards_payments
group by program_year
)
select program_year,
       total_payment, 
       lag(total_payment) over(order by program_year) as previous_year,
       round((total_payment - lag(total_payment) over(order by program_year))/lag(total_payment) over(order by program_year) * 100, 2) as yoy_change
from yearly_payment
order by program_year
--Yoy Change in total_amount_of_payment


--Q3. What are the main reasons Edwards Lifesciences is making payments, and which types account for the largest share of payment activity?

--i)
select reason_for_payment, sum(total_amount_of_payment) as total_payment, count(payment_record_id) as transaction_count
from edwards_payments
group by reason_for_payment
order by total_payment desc


--Q4. Which recipients account for the largest share of Edwards Lifesciences’ total payment value?

select recipient_name, sum(total_amount_of_payment) as total_payment
from edwards_payments
group by recipient_name
order by total_payment desc
--largest share is of unidentified_recipient 


--Q5. How concentrated are Edwards Lifesciences’ payments among its recipients?

--i)
select recipient_name, sum(total_amount_of_payment) as total_payment
from edwards_payments
group by recipient_name
order by total_payment desc
--payments are mostly with unidentified_recipient followed by anothony nunez

--ii)Lets calculate the concentrated percentage of payments excluding unidentified recipient
with recipient_payment as(
select recipient_name, sum(total_amount_of_payment) as total_payment
from edwards_payments
where recipient_name <> 'Unidentified_Recipient'
group by recipient_name
)
select top 10 recipient_name, total_payment, round((total_payment)/(select sum(total_amount_of_payment) from edwards_payments)*100,2) as percentage_share
from recipient_payment
order by total_payment desc


--Q6. Which products or product categories are most closely associated with Edwards Lifesciences’ payment activity?

--i)
select product_category, sum(total_amount_of_payment) as total_payment
from edwards_payments
group by product_category
order by total_payment desc
--unidentified product category has maximun total_payments of 49172885.59 followed by Transcatheter Heart Valves with 36450308.00

--ii)now lets find out which product is top in each category
select product_category, product_name, sum(total_amount_of_payment) as total_payment,
row_number() over (partition by product_category order by sum(total_amount_of_payment)desc) as rn
from edwards_payments
group by product_category, product_name


--Q7. How has payment activity associated with Edwards Lifesciences’ products changed across the 2021–2025 period?

with product_revenue as(
select product_name, program_year,sum(total_amount_of_payment) as total_payment
from edwards_payments
group by product_name, program_year
)
select product_name, total_payment, program_year,
lag(total_payment) over(partition by product_name order by program_year) as previous_year,
round((total_payment - lag(total_payment) over(partition by product_name order by program_year))/
                        lag(total_payment) over(partition by product_name order by program_year)*100,2) as yoy_change
from product_revenue    
where product_name is not null
order by program_year      


--Q8. Are there geographic areas where Edwards Lifesciences’ payment activity is particularly concentrated, 
--either by the number of payments or by total payment value?

--i)
select recipient_state, sum(total_amount_of_payment) as total_payment
from edwards_payments
group by recipient_state
order by total_payment desc
--Max amount of payment is in OH followed by CA

--ii)
select recipient_state, count(payment_record_id) as total_transactions
from edwards_payments
group by recipient_state
order by total_transactions desc
--Max transactions were done with CA followed by NY


--Q9.Are there particular recipient specialties that account for a disproportionately large share of payment activity?

with cte as(
select recipient_specialty, sum(total_amount_of_payment) as total_payment
from edwards_payments
group by Recipient_Specialty
)
select recipient_specialty, total_payment, round((total_payment)/(select sum(total_amount_of_payment) from edwards_payments)*100,2) as pct
from cte
order by pct desc


--Q10. Which payment patterns stand out when we look at recipient, payment reason, and payment amount together?

select recipient_name, reason_for_payment, sum(total_amount_of_payment) as total_payment
from edwards_payments
where recipient_name not in('Unidentified_Recipient')
group by recipient_name, reason_for_payment
order by total_payment desc


--Q11. Based on the analysis from 2021–2025, what payment patterns should be highlighted for further compliance review?

select recipient_name, 
       recipient_specialty, 
       recipient_state, 
       reason_for_payment, 
       Product_category,
       sum(total_amount_of_payment) as total_payment,
       count(payment_record_id) as total_transactions
from edwards_payments
where recipient_name <> 'Unidentified_Recipient'
group by 
       recipient_name, 
       recipient_specialty, 
       recipient_state, 
       reason_for_payment, 
       Product_category
order by total_payment desc