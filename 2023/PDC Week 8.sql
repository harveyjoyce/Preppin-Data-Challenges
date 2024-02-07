with cte as (
        SELECT 
        1 as file
        , * 
        FROM pd2023_wk08_01
        
        UNION ALL 
        
        SELECT 2 as file,* FROM pd2023_wk08_02
        
        UNION ALL 
        
        SELECT 3 as file,* FROM pd2023_wk08_03
        
        UNION ALL 
        
        SELECT 4 as file,* FROM pd2023_wk08_04
        
        UNION ALL 
        
        SELECT 5 as file,* FROM pd2023_wk08_05
        
        UNION ALL 
        
        SELECT 6 as file,* FROM pd2023_wk08_06
        
        UNION ALL 
        
        SELECT 7 as file,* FROM pd2023_wk08_07
        
        UNION ALL 
        
        SELECT 8 as file,* FROM pd2023_wk08_08
        
        UNION ALL 
        
        SELECT 9 as file,* FROM pd2023_wk08_09
        
        UNION ALL 
        
        SELECT 10 as file,* FROM pd2023_wk08_10
        
        UNION ALL 
        
        SELECT 11 as file,* FROM pd2023_wk08_11
        
        UNION ALL 
        
        SELECT 12 as file,* FROM pd2023_wk08_12)

, cte2 as ( Select 
DATE_FROM_PARTS(2023,file,1) as file_date
,id
,first_name
,last_name
,ticker
,sector
,market
,stock_name
, replace(purchase_price,'$','') :: float as new_purchase_price
    , case WHEN new_purchase_price < 25000 THEN 'Low'
    WHEN new_purchase_price < 50000 THEN 'Medium'
    WHEN new_purchase_price < 75000 THEN 'High'
    WHEN new_purchase_price <= 100000 THEN 'Very High'
    END as purchase_price_group
, replace(market_cap,'$','') as new_market_cap
,split_part(new_market_cap,substr(new_market_cap,-1),1) as num
, case when substr(new_market_cap,-1)='M' then num*1000000
when substr(new_market_cap,-1)='B' then num*1000000000
    else num*0 end :: float as Market_Capitalisation
    , case WHEN Market_Capitalisation < 100000000 THEN 'Low'
    WHEN Market_Capitalisation < 100000000000 THEN 'Medium'
    WHEN Market_Capitalisation < 100000000000000 THEN 'High'
    WHEN Market_Capitalisation <= 100000000000000 THEN 'Very High'
    END as Market_Capitalisation_group
from cte
where market_cap <> 'n/a')

, cte3 as (
select
*
,rank() over (partition by file_date, market_capitalisation_group, purchase_price_group order by  new_purchase_price desc) as rnk
from cte2)

,CATEGORIES AS (
SELECT 
DATE_FROM_PARTS(2023,file,1) as file_date,
CASE
    WHEN 
    ((SUBSTR(market_cap,2,LENGTH(market_cap)-2))::float *
    (CASE 
    WHEN RIGHT(market_cap,1)='B' THEN 1000000000
    WHEN RIGHT(market_cap,1)='M' THEN 1000000
    END))<100000000 THEN 'Small' 
    WHEN 
    ((SUBSTR(market_cap,2,LENGTH(market_cap)-2))::float *
    (CASE 
    WHEN RIGHT(market_cap,1)='B' THEN 1000000000
    WHEN RIGHT(market_cap,1)='M' THEN 1000000
    END))<1000000000 THEN 'Medium' 
    WHEN 
    ((SUBSTR(market_cap,2,LENGTH(market_cap)-2))::float *
    (CASE 
    WHEN RIGHT(market_cap,1)='B' THEN 1000000000
    WHEN RIGHT(market_cap,1)='M' THEN 1000000
    END))<100000000000 THEN 'Large'
    ELSE 'Huge'
END as market_cap_category,
CASE 
WHEN (SUBSTR(purchase_price,2,LENGTH(purchase_price)))::float < 25000 THEN 'Low'
WHEN (SUBSTR(purchase_price,2,LENGTH(purchase_price)))::float < 50000 THEN 'Medium'
WHEN (SUBSTR(purchase_price,2,LENGTH(purchase_price)))::float < 75000 THEN 'High'
WHEN (SUBSTR(purchase_price,2,LENGTH(purchase_price)))::float <= 100000 THEN 'Very High'
END as price_category,
*
FROM CTE
WHERE market_cap <> 'n/a'
)
,RANKED AS (
SELECT 
RANK() OVER(PARTITION BY file_date, market_cap_category, price_category ORDER BY (SUBSTR(purchase_price,2,LENGTH(purchase_price)))::float DESC) as rnk,
*
FROM CATEGORIES
)


select 
c.file_date
,c.ticker
,market_capitalisation_group
, purchase_price_group
, new_purchase_price
, market_cap_category
, price_category
, SUBSTR(purchase_price,2,LENGTH(purchase_price))
from cte3 c
inner join ranked r
on c.file_date=r.file_date and c.ticker=r.ticker
where c.rnk!=r.rnk and r.rnk<=5


;
select
count(*)
from cte3