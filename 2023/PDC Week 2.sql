select
*
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK02_TRANSACTIONS;

select
*
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK02_SWIFT_CODES;

select
*
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK02_TRANSACTIONS tr
inner join TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK02_SWIFT_CODES sc
    on tr.bank=sc.bank;

select
    'GB'as country_code
    ,check_digits
    ,swift_code
    ,replace(sort_code,'-') as sort_code
    ,account_number
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK02_TRANSACTIONS tr
inner join TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK02_SWIFT_CODES sc
    on tr.bank=sc.bank;
    
select
'GB'
||check_digits
||swift_code
||replace(sort_code,'-')
||account_number as "IBAN"
from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK02_TRANSACTIONS tr
inner join TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK02_SWIFT_CODES sc
    on tr.bank=sc.bank;