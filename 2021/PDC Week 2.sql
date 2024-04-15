-- Clean up the Model field to leave only the letters to represent the Brand of the bike
-- Workout the Order Value using Value per Bike and Quantity.
-- Calculate Days to ship by measuring the difference between when an order was placed and when it was shipped as 'Days to Ship'

with cte as (
select *
, regexp_replace(model,'[[:digit:]\/]+','') as Brand
, quantity*value_per_bike as order_value
, datediff('day',date(order_date,'DD/MM/YYYY'),DATE(shipping_date,'DD/MM/YYYY')) as days_to_ship
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2021_WK02_BIKE_SALES
)

-- Aggregate Value per Bike, Order Value and Quantity by Brand and Bike Type to form:
-- Quantity Sold
-- Order Value
-- Average Value Sold per Brand, Type
-- Round any averaged values to one decimal place to make the values easier to read

, output1 as (
select
Brand
, bike_type
, sum(quantity) as quantity_sold
, sum(order_value) as order_value
, round(avg(order_value),1) as avg_order_value
from cte
group by brand, bike_type)

-- Aggregate Order Value, Quantity and Days to Ship by Brand and Store to form:
-- Total Quantity Sold
-- Total Order Value
-- Average Days to Ship
-- Round any averaged values to one decimal place to make the values easier to read

, output2 as (
select
Brand
, store
, sum(quantity) as total_quantity_sold
, sum(order_value) as total_order_value
, round(avg(days_to_ship),1) as avg_days_to_ship
from cte
group by brand, store);
