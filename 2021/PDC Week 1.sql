-- Split the 'Store-Bike' field into 'Store' and 'Bike' (help)
-- Clean up the 'Bike' field to leave just three values in the 'Bike' field (Mountain, Gravel, Road) (help)
-- Create two different cuts of the date field: 'quarter' and 'day of month' (help)
-- Remove the first 10 orders as they are test values

select
customer_age
, bike_value
,existing_customer
, order_id
, day(date) as Day
, quarter(date) as quarter
, case when left(split_part(store_bike,'-',2),2)=' R' then 'Road'
    when left(split_part(store_bike,'-',2),2)=' M' then 'Mountain'
    when left(split_part(store_bike,'-',2),2)=' G' then 'Gravel' end as bike
, split_part(store_bike,'-',1) as store
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2021_WK01
where order_id>10