-- For the Transaction Details we want to filter to exclude 'Y' from the 'Cancelled?' field and then remove the 'Cancelled?' field. 
-- We are then ready to join our tables together using an inner join on Transaction ID. 
-- We now need to split the transactions into incomings and outgoings. For this we want to create two separate branches - 1, Incoming Transactions where we remove the Account From field, 2, Outgoing Transactions where we remove the Account To field and also make the values negative by multiplying by -1

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
from cte4
;