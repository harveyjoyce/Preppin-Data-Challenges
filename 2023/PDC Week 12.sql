-- Fill down the years and create a date field for the UK bank holidays

with year_fill as (
select 
row_num
, max(year) over(order by row_num) as year
, date
, split_part(date,'-',1) as day
, split_part(date,'-',2) as month
, bank_holiday
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK12_UK_BANK_HOLIDAYS)

, bank_holidays as (
select
date(date || '-' || year, 'DD-Mon-YYYY') as new_date
, bank_holiday
from year_fill
where date <> '')

-- Combine with the UK New Customer dataset

, unflaged_data as (
select 
date(uk.date, 'DD/MM/YYYY') as date
, new_customers
, bank_holiday
from preppin_data_inputs.pd2023_wk12_new_customers as uk
left join bank_holidays as bh
on date(uk.date, 'DD/MM/YYYY')=bh.new_date)


-- Create a Reporting Day flag
-- UK bank holidays are not reporting days
-- Weekends are not reporting days

, flagged_data as (
select *
, iff(dayofweek(date)=0 or dayofweek(date)=6
or bank_holiday is not null, 'N','Y') as Flagged
from unflaged_data
order by date)


-- For non-reporting days, assign the customers to the next reporting day

, non_reporting_days as (
select distinct
date as non_report_date
from flagged_data
where flagged='N')

, lookup as (
select
non_report_date
, min(date) as next_report_date
from flagged_data as fd
inner join non_reporting_days as nr
on date > non_report_date
where flagged='Y'
group by non_report_date
order by non_report_date)

, fixed_days as (
select
ifnull(next_report_date,date) as date
, to_varchar(date,'Mon-YYYY') as month
, new_customers
from flagged_data
left join lookup
on non_report_date=date)

-- Calculate the reporting month, as per the definition above
-- Filter our January 2024 dates
-- Calculate the reporting day, defined as the order of days in the reporting month
-- You'll notice reporting months often have different numbers of days!

, last_day as (
select 
month,
max(date) as last_date
from fixed_days
group by month)

, uk_data_adj as (
select 
case 
    when last_date is null then monthname(date) || '-' || year(date)
    else monthname(dateadd('month',1,date)) || '-' || year(dateadd('month',1,date))
    end as reporting_month
, date
, row_number() over (partition by 
    (case 
    when last_date is null then monthname(date) || '-' || year(date)
    else monthname(dateadd('month',1,date)) || '-' || year(dateadd('month',1,date))
    end) order by date
) as rn
, sum(new_customers) as new_customers
from fixed_days
left join last_day
on date=last_date
where reporting_month <> 'Jan-2024'
group by date, reporting_month
order by date)

-- Now let's focus on ROI data. This has already been through a similar process to the above, but using the ROI bank holidays. We'll have to align it with the UK reporting schedule
-- Rename fields so it's clear which fields are ROI and which are UK
-- Combine with UK data
-- For days which do not align, find the next UK reporting day and assign new customers to that day (for more detail, refer to the above description of the challenge)

, roi_data as (
select
reporting_month as roi_reporting_month,
reporting_day as roi_reporting_day,
new_customers as roi_new_customers,
DATE(reporting_date,'DD/MM/YYYY') as roi_reporting_date
FROM pd2023_wk12_roi_new_customers)

, matching_uk_dates as (
select
reporting_month
, rn as reporting_day
, date as reporting_date
, new_customers as uk_new_customers
, roi_new_customers
, roi_reporting_month
from uk_data_adj uk
left join roi_data roi
on uk.date=roi.roi_reporting_date)

, roi_data_adj as (
select
roi_reporting_month
, roi_reporting_day
, roi_new_customers
, roi_reporting_date
, min(uk2.date) as next_uk_date
from roi_data roi
left join uk_data_adj uk
    on uk.date=roi.roi_reporting_date
left join uk_data_adj uk2
    on uk2.date>roi.roi_reporting_date
where uk.date is null
group by roi_reporting_month, roi_reporting_day, roi_new_customers, roi_reporting_date)

-- Make sure null customer values are replaced with 0's

, combined as (
select 
reporting_month,
rn as reporting_day,
date as reporting_date,
0 as uk_new_customers,
roi_new_customers,
roi_reporting_month
from roi_data_adj roi
inner join uk_data_adj uk
on uk.date=roi.next_uk_date

union all

select *
from matching_uk_dates)

-- Create a flag to find which dates have differing reporting months when using the ROI/UK systems

select
case 
    when roi_reporting_month is null then 'x'
    when left(reporting_month,3) <> left(roi_reporting_month,3) then 'x'
    else '' 
end as misalignment_flag
, reporting_month
, reporting_day
, reporting_date
, SUM(uk_new_customers) as uk_new_customers
, SUM(roi_new_customers) as roi_new_customers
, roi_reporting_month
from combined
where dayofweek(reporting_date)!=6 and dayofweek(reporting_date)!=0
group by 
 reporting_date,reporting_day, reporting_month, roi_reporting_month
order by reporting_date;