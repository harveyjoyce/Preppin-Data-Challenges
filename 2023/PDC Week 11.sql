-- First we want to input both of our data sources and then combine them together so that all of the customer locations can be compared to all of the branch locations. 
-- Append the Branch information to the Customer information
-- Transform the latitude and longitude into radians
-- Find the closest Branch for each Customer
-- Make sure Distance is rounded to 2 decimal places
-- For each Branch, assign a Customer Priority rating, the closest customer having a rating of 1

select 
branch
, branch_long/(180/PI()) as branch_long_rad
, branch_lat/(180/PI()) as branch_lat_rad
, customer
, address_long/(180/PI()) as address_long_rad
, address_lat/(180/PI()) as address_lat_rad
, ROUND(3963*ACOS((SIN(address_lat_rad)*SIN(branch_lat_rad))+COS(address_lat_rad)*COS(branch_lat_rad)*COS(branch_long_rad-address_long_rad)),2) as distance
, rank() over (partition by branch order by distance asc) as customer_priority
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK11_DSB_CUSTOMER_LOCATIONS cl
inner join TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK11_DSB_BRANCHES db
on true
order by branch, customer_priority