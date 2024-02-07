select *
from til_playground.preppin_data_inputs.pd2023_wk01;

with t1 as 
    (select
    split_part(transaction_code,'-',1) as bank
    ,monthname(to_date(transaction_date, 'DD/MM/YYYY HH24:MI:SS')) as month
    ,sum(value) as value
    ,RANK() OVER (PARTITION BY month ORDER BY sum(value) DESC) as bank_rank_per_month
    from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK01
    group by bank, month)
    
,t2 as
    (select 
        bank
        ,avg(bank_rank_per_month) as avg_rank_per_bank
    from t1
    group by bank)

,t3 as
    (select 
    bank_rank_per_month
    ,avg(value) as avg_trans_per_rank
    from t1
    group by bank_rank_per_month)

select 
    t1.bank
    ,t1.month
    ,t1.value
    ,t1.bank_rank_per_month
    ,t2.avg_rank_per_bank
    ,t3.avg_trans_per_rank
from t1
inner join t2
on t1.bank=t2.bank
inner join t3
on t1.bank_rank_per_month=t3.bank_rank_per_month