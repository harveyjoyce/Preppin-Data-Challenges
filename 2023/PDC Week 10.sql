-- week 10 parameter
set select_date='2023-02-01';

-- week 9 output
-- For the Transaction Details we want to filter to exclude 'Y' from the 'Cancelled?' field and then remove the 'Cancelled?' field. 
-- We are then ready to join our tables together using an inner join on Transaction ID. 
-- We now need to split the transactions into incomings and outgoings. For this we want to create two separate branches - 1, Incoming Transactions where we remove the Account From field, 2, Outgoing Transactions where we remove the Account To field and also make the values negative by multiplying by -1

with week_9_output as (
 with cte1 as
(select
account_from as account
,transaction_date as date
,-1*value as value
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_TRANSACTION_DETAIL td
inner join TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_TRANSACTION_PATH tp
on td.transaction_id=tp.transaction_id
where cancelled_<>'Y')

, cte2 as (select
account_to as account
,transaction_date
,value
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_TRANSACTION_DETAIL td
inner join TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_TRANSACTION_PATH tp
on td.transaction_id=tp.transaction_id
where cancelled_<>'Y')

-- We can then include the final input, Account Information, into the workflow as a third branch. Within the input we only need to keep the Account Number, Balance Date, and Balance fields. 

-- After this we can bring all of these back together with a union so we have three fields - Account Number, Balance Date, & Balance

, cte3 as (
SELECT *
FROM cte1
UNION all
SELECT * 
FROM cte2
UNION all
SELECT 
account_number as account
, balance_date as date
, balance as value
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_ACCOUNT_INFORMATION)

-- Next we want to identify the order in which the transactions occurred so that we can then start to calculate the balance at each stage.
-- To order the transactions we can use a Rank calculation where we group by Account Number, and rank the Balance Date (Ascending) and Balance (Descending)

, cte4 as (
select 
account
, date
,value
,rank() over (partition by account order by date asc, value desc) as transaction_order
from cte3)

-- Now we need to calculate a running sum based on the balance at each stage and account.
-- We can then make sure that the opening transaction value is null as per the requirements

select 
account
, date
, iff(transaction_order=1,null,value) as transaction_value
, sum(value) over (partition by account order by transaction_order) as balance
from cte4)

--Week 10
-- Aggregate the data so we have a single balance for each day already in the dataset, for each account


, daily_trans as(
select 
account
, date
, sum(transaction_value) as total_transaction
from week_9_output
group by account, date)

, ordered_trans as (
select 
account
, date
, transaction_value
, balance
, row_number() over (partition by account, date order by balance asc) as order_t
from week_9_output)

, daily_summary as (
select 
ot.account
, ot.date
, dt.total_transaction
, ot.balance
from ordered_trans ot
inner join daily_trans dt
on ot.account=dt.account and ot.date=dt.date
where order_t=1)

-- Scaffold the data so each account has a row between 31st Jan and 14th Feb
-- Make sure new rows have a null in the Transaction Value field

, account_num as (
select distinct
account
from daily_summary)

, Date_Numbers as (
select '2023-01-31'::date as n
, account
from account_num

union all

select 
dateadd('day',1,n)
, account
from date_numbers
where n < '2023-02-14'::date)

, group_table as (
select 
dn.account
, N
, ds.total_transaction
, ds.balance
, count(balance) over (partition by dn.account order by n asc) as rn
from date_numbers dn
left join daily_summary ds
on dn.n=ds.date and dn.account=ds.account
order by account, n)

-- Create a parameter so a particular date can be selected
-- Filter to just this date
-- Output the data - making it clear which date is being filtered to

select
account
, n as date
, total_transaction
, first_value(balance) over (partition by account, rn order by n) as EOD_balance
from group_table
where date=$select_date


;