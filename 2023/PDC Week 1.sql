select 
*
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK01;

select
    *
    ,split_part(transaction_code,'-',1) as "Bank"
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK01;

select 
    split_part(transaction_code,'-',1) as "Bank"
   ,sum(value) as "Transaction Value"
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK01
Group by "Bank";

select 
    split_part(transaction_code,'-',1) as "Bank"
    ,iff(online_or_in_person = 1,'Online','In-Person') as "Online or In-Person"
    ,dayname(to_date(transaction_date, 'DD/MM/YYYY HH24:MI:SS')) as "Date"
    ,sum(value) as "Transaction Value"
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK01
Group by "Bank"
    ,online_or_in_person
    ,transaction_date;

select 
    split_part(transaction_code,'-',1) as "Bank"
    ,customer_code
   ,sum(value) as "Transaction Value"
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK01
Group by "Bank"
    ,customer_code;