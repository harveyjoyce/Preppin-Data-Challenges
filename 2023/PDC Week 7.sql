select *
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_ACCOUNT_HOLDERS;

select 
        ACCOUNT_NUMBER 
        ,ACCOUNT_TYPE 
        ,value as ACCOUNT_HOLDER_ID
        ,BALANCE_DATE 
        ,BALANCE
    from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_ACCOUNT_INFORMATION, 
    LATERAL SPLIT_TO_TABLE(account_holder_id,', ')
    WHERE account_holder_id IS NOT NULL
;

with t1 as 
        (select
        account_holder_id
        ,name
        ,date_of_birth
        ,'0'||contact_number as contact_number
        ,first_line_of_address
        from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_ACCOUNT_HOLDERS)
        
, t2 as 
        (select 
        ACCOUNT_NUMBER 
        ,ACCOUNT_TYPE 
        ,value as ACCOUNT_HOLDER_ID
        ,BALANCE_DATE 
        ,BALANCE
        from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_ACCOUNT_INFORMATION, LATERAL SPLIT_TO_TABLE(account_holder_id,', ')
        WHERE account_holder_id IS NOT NULL)
        
        select *
        from t1 
        inner join t2
        on t1.ACCOUNT_HOLDER_ID=t2.ACCOUNT_HOLDER_ID
;
select *
        from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_TRANSACTION_DETAIL as t3
        inner join TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_TRANSACTION_PATH as t4
        on t3.transaction_id=t4.transaction_id
;

With t5 as
        (with t1 as 
        (select
        account_holder_id
        ,name
        ,date_of_birth
        ,'0'||contact_number as contact_number
        ,first_line_of_address
        from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_ACCOUNT_HOLDERS)
        
        , t2 as 
        (select 
        ACCOUNT_NUMBER 
        ,ACCOUNT_TYPE 
        ,value as ACCOUNT_HOLDER_ID
        ,BALANCE_DATE 
        ,BALANCE
        from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_ACCOUNT_INFORMATION, LATERAL SPLIT_TO_TABLE(account_holder_id,', ')
        WHERE account_holder_id IS NOT NULL)
        
        select *
        from t1 
        inner join t2
        on t1.ACCOUNT_HOLDER_ID=t2.ACCOUNT_HOLDER_ID)

,t6 as 
        (select *
        from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_TRANSACTION_DETAIL as t3
        inner join TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_TRANSACTION_PATH as t4
        on t3.transaction_id=t4.transaction_id)

select *
from t5
inner join t6
on t5.account_number=t6.account_to
where cancelled_ != 'Y'
AND value >1000
AND account_type != 'Platinum'