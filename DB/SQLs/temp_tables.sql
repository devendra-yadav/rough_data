drop table orders;
drop table orderdetails;

create table orders(
	customerid number,
	orderid number,
	orderdate date
);

create table orderdetails(
	orderid number,
	price number,
	quantity number
);

insert into orders values(9001, 1001, to_date('10/01/1996','dd/mm/yyyy'));
insert into orders values(9001, 1002, to_date('12/01/1996','dd/mm/yyyy'));
insert into orders values(9001, 1003, to_date('14/02/1996','dd/mm/yyyy'));
insert into orders values(9002, 1004, to_date('15/07/1996','dd/mm/yyyy'));
insert into orders values(9002, 1005, to_date('18/04/1996','dd/mm/yyyy'));
insert into orders values(9003, 1006, to_date('20/08/1996','dd/mm/yyyy'));
insert into orders values(9004, 1007, to_date('08/02/1996','dd/mm/yyyy'));
insert into orders values(9004, 1008, to_date('07/06/1996','dd/mm/yyyy'));
insert into orders values(9005, 1009, to_date('15/04/1996','dd/mm/yyyy'));
insert into orders values(9005, 1010, to_date('24/07/1996','dd/mm/yyyy'));
insert into orders values(9006, 1011, to_date('21/02/1996','dd/mm/yyyy'));
insert into orders values(9007, 1012, to_date('16/09/1996','dd/mm/yyyy'));
insert into orders values(9007, 1013, to_date('18/11/1996','dd/mm/yyyy'));
insert into orders values(9008, 1014, to_date('10/11/1996','dd/mm/yyyy'));

/*
CUSTOMERID	ORDERID	ORDERDATE
9001	1001	10-JAN-96
9001	1002	12-JAN-96
9001	1003	14-FEB-96
9002	1004	15-JUL-96
9002	1005	18-APR-96
9003	1006	20-AUG-96
9004	1007	08-FEB-96
9004	1008	07-JUN-96
9005	1009	15-APR-96
9005	1010	24-JUL-96
9006	1011	21-FEB-96
9007	1012	16-SEP-96
9007	1013	18-NOV-96
9008	1014	10-NOV-96
*/

insert into orderdetails values(1001, 10, 2);
insert into orderdetails values(1001, 8, 4);
insert into orderdetails values(1001, 6, 2);
insert into orderdetails values(1002, 4, 2);
insert into orderdetails values(1002, 11, 3);
insert into orderdetails values(1003, 16, 1);
insert into orderdetails values(1003, 20, 1);
insert into orderdetails values(1003, 18, 2);
insert into orderdetails values(1004, 10, 3);
insert into orderdetails values(1005, 14, 4);
insert into orderdetails values(1005, 9, 2);
insert into orderdetails values(1005, 21, 1);
insert into orderdetails values(1006, 8, 2);
insert into orderdetails values(1006, 11, 2);
insert into orderdetails values(1007, 13, 3);
insert into orderdetails values(1008, 17, 4);
insert into orderdetails values(1008, 12, 1);
insert into orderdetails values(1008, 11, 3);
insert into orderdetails values(1009, 8, 5);
insert into orderdetails values(1009, 6, 2);
insert into orderdetails values(1010, 21, 1);
insert into orderdetails values(1011, 22, 1);
insert into orderdetails values(1011, 12, 3);
insert into orderdetails values(1011, 17, 1);
insert into orderdetails values(1012, 12, 2);
insert into orderdetails values(1012, 11, 4);
insert into orderdetails values(1013, 7, 1);
insert into orderdetails values(1014, 10, 2);

/*
ORDERID	PRICE	QUANTITY
1001	10	2
1001	8	4
1001	6	2
1002	4	2
1002	11	3
1003	16	1
1003	20	1
1003	18	2
1004	10	3
1005	14	4
1005	9	2
1005	21	1
1006	8	2
1006	11	2
1007	13	3
1008	17	4
1008	12	1
1008	11	3
1009	8	5
1009	6	2
1010	21	1
1011	22	1
1011	12	3
1011	17	1
1012	12	2
1012	11	4
1013	7	1
1014	10	2
*/

/*
Find order with max total for every month.
output should contain
CustomerId, OrderId, MONTH, YEAR, OrderTotal  (for each month max order total)
*/

-----------------------1st SOLUTION-------------------------------------

--this select query selecting all orders (columns are the one that are needed) and where clause is fetching on the orders that match the condition
select data.cid, data.oid, data.month, data.year, data.ot from (
	select o.customerid cid, o.orderid as oid, to_char(o.orderdate,'mm') month, to_char(o.orderdate,'yyyy') year,  sum(od.price  * od.quantity ) ot from orders o, orderdetails od where o.orderid = od.orderid
				group by o.customerid, o.orderid , to_char(o.orderdate,'mm') , to_char(o.orderdate,'yyyy') order by 4,3
) data

where (data.month, data.year, data.ot) in 
(
	--this giving month, year and max order total for that month, year
    select d.month, d.year, max(d.ot) from 
    (
		--this query just merging 2 tables and giving order total for each order.
        select o.customerid cid, o.orderid as oid, to_char(o.orderdate,'mm') month, to_char(o.orderdate,'yyyy') year,  sum(od.price  * od.quantity ) ot from orders o, orderdetails od where o.orderid = od.orderid
            group by o.customerid, o.orderid , to_char(o.orderdate,'mm') , to_char(o.orderdate,'yyyy') order by 4,3
    ) d group by d. month, d.year -- order by 2,1 
)

--Order by inside teh where clause select statement was creating problems (ORA-00920: invalid relational operator)

/*  OUTPUT 
CID	    OID	   MONTH YEAR   OT
9001	1001	01	1996	64
9006	1011	02	1996	75
9002	1005	04	1996	95
9004	1008	06	1996	113
9002	1004	07	1996	30
9003	1006	08	1996	38
9007	1012	09	1996	68
9008	1014	11	1996	20
*/

----------------------2nd SOLUTION (using row_number() and partition by ------------------------------

 select d.cid,d.oid,d.month, d.year,d.ot from 
 (
 
 select 
    o.customerid cid, 
    o.orderid as oid, 
    to_char(o.orderdate,'mm') month, 
    to_char(o.orderdate,'yyyy') year,  
    sum(od.price  * od.quantity ) ot, 
    row_number() over(partition by to_char(o.orderdate,'yyyy'), to_char(o.orderdate,'mm') order by sum(od.price  * od.quantity ) desc) rn
    from orders o, orderdetails od 
    where o.orderid = od.orderid 
    group by o.customerid, o.orderid , to_char(o.orderdate,'mm') , to_char(o.orderdate,'yyyy') order by 4,3
    
) d where d.rn=1

/* output
CID	     OID  MONTH	YEAR	OT
9001	1001	01	1996	64
9006	1011	02	1996	75
9002	1005	04	1996	95
9004	1008	06	1996	113
9002	1004	07	1996	30
9003	1006	08	1996	38
9007	1012	09	1996	68
9008	1014	11	1996	20
*/


----------------------3rd SOLUTION ----------------------------------
with data as(
select 
    o.customerid cid, 
    o.orderid as oid, 
    to_char(o.orderdate,'mm') month, 
    to_char(o.orderdate,'yyyy') year,  
    sum(od.price  * od.quantity ) ot,
    dense_rank() over(partition by to_char(o.orderdate,'mm'), to_char(o.orderdate,'yyyy') order by sum(od.price  * od.quantity ) desc) rank
    from orders o, orderdetails od 
    where o.orderid = od.orderid 
    group by o.customerid, o.orderid , to_char(o.orderdate,'mm') , to_char(o.orderdate,'yyyy') 
    
)

select cid, oid, month, year, ot from data where rank=1 order by year, month

/*
CID	 OID	MONTH	YEAR	OT
9001	1001	01	1996	64
9006	1011	02	1996	75
9002	1005	04	1996	95
9004	1008	06	1996	113
9002	1004	07	1996	30
9003	1006	08	1996	38
9007	1012	09	1996	68
9008	1014	11	1996	20
*/


---------------Good queries for undersanding-----------------
--1. Use of dense_rank()

with data as(
select 
    o.customerid cid, 
    o.orderid as oid, 
    to_char(o.orderdate,'mm') month, 
    to_char(o.orderdate,'yyyy') year,  
    sum(od.price  * od.quantity ) ot,
    dense_rank() over(order by sum(od.price  * od.quantity )) rank  -- Here we didnt partition anything. just did ordey by. But we can partition as well.
    from orders o, orderdetails od 
    where o.orderid = od.orderid 
    group by o.customerid, o.orderid , to_char(o.orderdate,'mm') , to_char(o.orderdate,'yyyy') 
    
)

select * from data where rank <=10

/*Output
CID	   OID	MONTH	YEAR	OT	RANK
9007	1013	11	1996	7	1
9008	1014	11	1996	20	2
9005	1010	07	1996	21	3
9002	1004	07	1996	30	4
9003	1006	08	1996	38	5
9004	1007	02	1996	39	6
9001	1002	01	1996	41	7
9005	1009	04	1996	52	8
9001	1001	01	1996	64	9
*/

--2. use of dense_rank() with partition as well. Partition will create groups and then rank within those groups.
with data as(
select 
    o.customerid cid, 
    o.orderid as oid, 
    to_char(o.orderdate,'mm') month, 
    to_char(o.orderdate,'yyyy') year,  
    sum(od.price  * od.quantity ) ot,
    dense_rank() over(partition by to_char(o.orderdate,'mm'), to_char(o.orderdate,'yyyy') order by sum(od.price  * od.quantity )) rank --Here we partitioned. to create subgroups
    from orders o, orderdetails od 
    where o.orderid = od.orderid 
    group by o.customerid, o.orderid , to_char(o.orderdate,'mm') , to_char(o.orderdate,'yyyy') 
    
)

select * from data where rank <10

/*Output
CID	    OID	MONTH	YEAR	OT	RANK
9001	1002	01	1996	41	1
9001	1001	01	1996	64	2
9004	1007	02	1996	39	1
9001	1003	02	1996	72	2
9006	1011	02	1996	75	3
9005	1009	04	1996	52	1
9002	1005	04	1996	95	2
9004	1008	06	1996	113	1
9005	1010	07	1996	21	1
9002	1004	07	1996	30	2
9003	1006	08	1996	38	1
9007	1012	09	1996	68	1
9007	1013	11	1996	7	1
9008	1014	11	1996	20	2
*/
