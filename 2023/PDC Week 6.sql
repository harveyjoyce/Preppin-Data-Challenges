select *
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK06_DSB_CUSTOMER_SURVEY;

with t1 as
(select *
, split_part(online,'___',2) as area
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK06_DSB_CUSTOMER_SURVEY
unpivot(Oscore for Online in (ONLINE_INTERFACE___EASE_OF_USE
                    , ONLINE_INTERFACE___EASE_OF_ACCESS
                    , ONLINE_INTERFACE___NAVIGATION
                    , ONLINE_INTERFACE___LIKELIHOOD_TO_RECOMMEND
                    , ONLINE_INTERFACE___OVERALL_RATING)))
, t2 as 
(select *
, split_part(mobile,'___',2) as area
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK06_DSB_CUSTOMER_SURVEY
unpivot(Mscore for Mobile in (MOBILE_APP___EASE_OF_USE
                    , mobile_app___ease_of_access
                    , MOBILE_APP___NAVIGATION
                    , MOBILE_APP___LIKELIHOOD_TO_RECOMMEND
                    , MOBILE_APP___OVERALL_RATING)))
                    
select
    t1.customer_id
    ,t1.area
    ,t2.mscore
    ,t1.oscore
from t1
inner join t2
on t1.customer_id=t2.customer_id
and t1.area=t2.area
where t1.area != 'OVERALL_RATING';

with t1 as
(select *
, split_part(online,'___',2) as area
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK06_DSB_CUSTOMER_SURVEY
unpivot(Oscore for Online in (ONLINE_INTERFACE___EASE_OF_USE
                    , ONLINE_INTERFACE___EASE_OF_ACCESS
                    , ONLINE_INTERFACE___NAVIGATION
                    , ONLINE_INTERFACE___LIKELIHOOD_TO_RECOMMEND
                    , ONLINE_INTERFACE___OVERALL_RATING)))
, t2 as 
(select *
, split_part(mobile,'___',2) as area
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK06_DSB_CUSTOMER_SURVEY
unpivot(Mscore for Mobile in (MOBILE_APP___EASE_OF_USE
                    , mobile_app___ease_of_access
                    , MOBILE_APP___NAVIGATION
                    , MOBILE_APP___LIKELIHOOD_TO_RECOMMEND
                    , MOBILE_APP___OVERALL_RATING)))
                    
select
    t1.customer_id
    ,avg(t2.mscore) as Avg_score_mobile
    ,avg(t1.oscore) as Avg_score_online
    , Avg_score_mobile - Avg_score_online as Diff_in_avg_score
from t1
inner join t2
on t1.customer_id=t2.customer_id
and t1.area=t2.area
where t1.area != 'OVERALL_RATING'
group by t1.customer_id;

with t1 as
(select *
, split_part(online,'___',2) as area
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK06_DSB_CUSTOMER_SURVEY
unpivot(Oscore for Online in (ONLINE_INTERFACE___EASE_OF_USE
                    , ONLINE_INTERFACE___EASE_OF_ACCESS
                    , ONLINE_INTERFACE___NAVIGATION
                    , ONLINE_INTERFACE___LIKELIHOOD_TO_RECOMMEND
                    , ONLINE_INTERFACE___OVERALL_RATING)))
, t2 as 
(select *
, split_part(mobile,'___',2) as area
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK06_DSB_CUSTOMER_SURVEY
unpivot(Mscore for Mobile in (MOBILE_APP___EASE_OF_USE
                    , mobile_app___ease_of_access
                    , MOBILE_APP___NAVIGATION
                    , MOBILE_APP___LIKELIHOOD_TO_RECOMMEND
                    , MOBILE_APP___OVERALL_RATING)))
                    
, t3 as
(select
    t1.customer_id
    ,avg(t2.mscore) as Avg_score_mobile
    ,avg(t1.oscore) as Avg_score_online
    , Avg_score_mobile - Avg_score_online as Diff_in_avg_score
    , case when diff_in_avg_score >= 2 then 'Mobile Superfan' 
            when diff_in_avg_score <= -2 then 'Online Superfan'
            when diff_in_avg_score >= 1 and diff_in_avg_score <2 then 'Mobile Fan'
            when diff_in_avg_score <= -1 and diff_in_avg_score >-2 then 'Online Fan'
            when diff_in_avg_score > -1 and diff_in_avg_score < 1 then 'Neutral'
         end as Type
from t1
inner join t2
on t1.customer_id=t2.customer_id
and t1.area=t2.area
where t1.area != 'OVERALL_RATING'
group by t1.customer_id)

, t4 as
 (select
    count(customer_id) as total_customers
from t3) 


select 
    type
    ,round((count/t4.total_customers)*100,2)||'%' as percent_of_total
from(
    select 
        type,
        count(customer_id) as count
    from t3
    group by type) as cat_count
inner join t4
on true