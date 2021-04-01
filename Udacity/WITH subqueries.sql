/*Question 1:Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales. */
--query runs however when include reps, gives wrong output: without reps just region, correct output however qn needs the re names
--from sol page: 3 select statements
with sales_rep as (
    select 
           distinct r.name region,
           s.name rep,
           sum(o.total_amt_usd) n_sum
      
    from sales_reps s
    join region r 
    on s.region_id = r.id 
    join accounts a 
    on a.sales_rep_id = s.id 
    join orders o 
    on o.account_id = a.id 
    group by rep, region 
    order by 3 desc         
)
select region, max(n_sum)
from sales_rep
group by region;

--solution
WITH t1 AS (
  SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
   FROM sales_reps s
   JOIN accounts a
   ON a.sales_rep_id = s.id
   JOIN orders o
   ON o.account_id = a.id
   JOIN region r
   ON r.id = s.region_id
   GROUP BY 1,2
   ORDER BY 3 DESC), 
t2 AS (
   SELECT region_name, MAX(total_amt) total_amt
   FROM t1
   GROUP BY 1)
SELECT t1.rep_name, t1.region_name, t1.total_amt
FROM t1
JOIN t2
ON t1.region_name = t2.region_name AND t1.total_amt = t2.total_amt;

--Question 2:For the region with the largest sales total_amt_usd, how many total orders were placed
--query runs: Same output as solution but different queries
--from sol page: Different query having 3 select statements
with total_sales as (
    select r.name region_name,
           sum(o.total_amt_usd) tot_amt, 
           count(o.total) tot_orders
    from sales_reps s  
    join accounts a 
    on s.id = a.sales_rep_id
    join orders o 
    on a.id = o.account_id 
    join region r 
    on r.id = s.region_id 
    group by region_name 
)
select *
from total_sales
order by tot_orders DESC
limit 1; 

--solution
WITH t1 AS (
   SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
   FROM sales_reps s
   JOIN accounts a
   ON a.sales_rep_id = s.id
   JOIN orders o
   ON o.account_id = a.id
   JOIN region r
   ON r.id = s.region_id
   GROUP BY r.name), 
t2 AS (
   SELECT MAX(total_amt)
   FROM t1)
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (SELECT * FROM t2);
 

--Question 3:How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?
--query runs: Wrong output
--from sol page:
with b_account as (
    select a.name acc_name, 
           sum(o.total) tot_orders,
           sum(o.standard_qty) std_qty 
    from accounts a 
    join orders o 
    on a.id = o.account_id
    group by acc_name 
    order by std_qty desc
    limit 1
)
select count(acc_name)
from b_account
having tot_orders > std_qty

--solution
WITH t1 AS (
  SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
  FROM accounts a
  JOIN orders o
  ON o.account_id = a.id
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 1), 
t2 AS (
  SELECT a.name
  FROM orders o
  JOIN accounts a
  ON a.id = o.account_id
  GROUP BY 1
  HAVING SUM(o.total) > (SELECT total FROM t1))
SELECT COUNT(*)
FROM t2;

--Question 4: For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?
--query runs but wrong output because it's getting all accounts
--from sol page: splits the query
with best_customer as (
    select a.name ac_name,
           sum(o.total_amt_usd) tot_spent,
           w.channel as channel,
           count(w.*) as n_events
    from accounts a 
    join orders o 
    on a.id = o.account_id 
    join web_events w 
    on w. account_id = a.id 
    group by ac_name, channel 
    order by tot_spent desc
    limit 1
)
select ac_name, channel, n_events 
from best_customer 

--
WITH t1 AS (
   SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id
   GROUP BY a.id, a.name
   ORDER BY 3 DESC
   LIMIT 1)
SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id FROM t1)
GROUP BY 1, 2
ORDER BY 3 DESC;

--Question 5: What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
--query runs: Same approach as solution
--from sol page: 
with lifetime_accs as (
    select a.name,
           sum(o.total_amt_usd) as avg_amt
    from accounts a 
    join orders o 
    on a.id = o. account_id 
    group by a.name
    order by 2 desc
    limit 10
)
select avg(avg_amt)
from lifetime_accs 

--solution
WITH t1 AS (
   SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id
   GROUP BY a.id, a.name
   ORDER BY 3 DESC
   LIMIT 10)
SELECT AVG(tot_spent)
FROM t1;

--Question 6: What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders.
--Failed to intepret query
--from sol page:
with lifetime_co as (
    select a.name,
           avg(o.total_amt_usd) as avg_amt
    from accounts a 
    join orders o 
    on a.id = o. account_id 
    group by a.name
)
select *
from lifetime_co

--solution
WITH t1 AS (
   SELECT AVG(o.total_amt_usd) avg_all
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id),
t2 AS (
   SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
   FROM orders o
   GROUP BY 1
   HAVING AVG(o.total_amt_usd) > (SELECT * FROM t1))
SELECT AVG(avg_amt)
FROM t2;
  