with 
t1 as 
(
    select 
        split_part(transaction_code,'-',1) as Bank
        ,iff(online_or_in_person = 1,'Online','In-Person') as online_or_in_person
        ,quarter(to_date(transaction_date, 'DD/MM/YYYY HH24:MI:SS')) as date
        ,sum(value) as Transaction_Value
    from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK01
        where bank='DSB'
        Group by Bank
            ,online_or_in_person
            ,date
)
,t2 as
(
    select 
            ONLINE_OR_IN_PERSON
            ,right(quarter,1) as QUARTER
            ,target
        from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK03_TARGETS 
            unpivot (Target for Quarter in (Q1,Q2,Q3,Q4))
)

Select 
    bank
    ,t2.online_or_in_person
    ,t2.quarter
    ,transaction_value
    , transaction_value - target as Vary
from t1
inner join t2
    on t1.online_or_in_person=t2.online_or_in_person
    and date=t2.quarter