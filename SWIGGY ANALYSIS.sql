#Q1: find the count of duplicate rows in the swiggy tabl
#1
select 
     count(id) as no_of_dulicates
from (
select *,row_number() over(partition by id) as dummy from dspro.swiggy
) as a
where dummy>1;


#Q2: Remove Duplicate records from the table
create
    table dspro.swiggy1
as
(select 
      * 
      from
(select 
       *,
       row_number() over(partition by id) as dummy 
       from dspro.swiggy) a
where dummy=1
) ;


#Q3: Print records from row number 4 to 9
SELECT 
    *
FROM
    dspro.swiggy1
LIMIT 3 , 6;


#Q4: Find the latest order placed by customers. Refer to the output below
SELECT 
    *
FROM
    dspro.swiggy1
ORDER BY order_date DESC
LIMIT 4;


#Q5: Print order_id, partner_code, order_date, comment (No issues in place of null else comment).
SELECT 
    order_id,
    partner_code,
    order_date,
    IF(Comments IS NULL,
        'No issues',
        Comments) AS comments
FROM
    dspro.swiggy1;


#Q6: Print outlet wise order count, cumulative order count, total bill_amount, cumulative bill_amount. Refer to the output below
SELECT 
    outlet,
    cnt,
    @cum_cnt:=@cum_cnt + cnt AS cum_cunt,
    total_sale,
    @cum_sale:=@cum_sale + total_sale AS cum_sale
FROM
    (SELECT 
        outlet,
            COUNT(*) AS cnt,
            @cum_cnt:=0,
            SUM(bill_amount) AS total_sale,
            @cum_sale:=0
    FROM
        dspro.swiggy1
    GROUP BY outlet) a
ORDER BY cnt;


#Q7: Print cust_id wise, Outlet wise 'total number of orders'. Refer to the output below
SELECT 
    cust_id,
    SUM(IF(outlet = 'kfc', 1, 0)) AS kfc,
    SUM(IF(outlet = 'dominos', 1, 0)) AS dominos,
    SUM(IF(outlet = 'pizza hut', 1, 0)) AS pizza_hut
FROM
    dspro.swiggy1
GROUP BY 1;


#Q8: Print cust_id wise, Outlet wise 'total sales'. Refer to the output below
SELECT 
    cust_id,
    SUM(IF(outlet = 'kfc', bill_amount, 0)) AS kfc,
    SUM(IF(outlet = 'dominos', bill_amount, 0)) AS dominos,
    SUM(IF(outlet = 'pizza hut', bill_amount, 0)) AS pizza_hut
FROM
    dspro.swiggy1
GROUP BY 1;


























