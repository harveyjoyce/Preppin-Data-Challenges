select
*
from til_playground.preppin_data_inputs.pd2023_wk04_january
PIVOT (min(Value) FOR Demographic IN ('Ethnicity','Account Type', 'Date of Birth'));

select
    ID
    ,dateadd('day',joining_day-1,MonthDate) as True_Joining_Date
    ,Account_Type
    ,Date_of_Birth
    ,Ethnicity
from 
    (
    select * 
        ,to_date('01/01/2023','DD/MM/YYYY') as MonthDate
    from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_JANUARY
    UNION ALL
    select * 
        ,to_date('01/02/2023','DD/MM/YYYY') as MonthDate
    from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_FEBRUARY
    UNION ALL
    select * 
        ,to_date('01/03/2023','DD/MM/YYYY') as MonthDate
    from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_MARCH
    UNION ALL
    select * 
        ,to_date('01/04/2023','DD/MM/YYYY') as MonthDate
    from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_APRIL
    UNION ALL
    select * 
        ,to_date('01/05/2023','DD/MM/YYYY') as MonthDate
    from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_MAY
    UNION ALL
    select * 
        ,to_date('01/06/2023','DD/MM/YYYY') as MonthDate
    from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_JUNE
    UNION ALL
    select * 
        ,to_date('01/07/2023','DD/MM/YYYY') as MonthDate
    from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_JULY
    UNION ALL
    select * 
        ,to_date('01/08/2023','DD/MM/YYYY') as MonthDate
    from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_AUGUST
    UNION ALL
    select * 
        ,to_date('01/09/2023','DD/MM/YYYY') as MonthDate
    from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_SEPTEMBER
    UNION ALL
    select * 
        ,to_date('01/10/2023','DD/MM/YYYY') as MonthDate
    from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_OCTOBER
    UNION ALL
    select * 
        ,to_date('01/11/2023','DD/MM/YYYY') as MonthDate
    from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_NOVEMBER
    UNION ALL
    select * 
        ,to_date('01/12/2023','DD/MM/YYYY') as MonthDate
    from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_DECEMBER
    )
PIVOT (min(Value) FOR Demographic IN ('Ethnicity','Account Type', 'Date of Birth')) 
        as q (ID, Joining_Day,MonthDate,Ethnicity,Account_Type,Date_of_Birth)
