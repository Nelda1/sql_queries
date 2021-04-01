/*QN: Say you're an analyst at Parch & Posey and you want to see:
each account who has a sales rep and each sales rep that has an account (all of the columns in these returned rows will be full)
but also each account that does not have a sales rep and each sales rep that does not have an account (some of the columns in these returned rows will be empty)
This type of question is rare, but FULL OUTER JOIN is perfect for it. In the following SQL Explorer, write a query with FULL OUTER JOIN to fit the above described Parch & Posey scenario (selecting all of the columns in both of the relevant tables, accounts and sales_reps) then answer the subsequent multiple choice quiz.*/
select a.name as account_name,
       s.name as sales_rep_name
from accounts a
full outer join sales_reps s 
on s.id = a. sales_rep_id
--each account has at least one sales rep and each sales rep has at least one account.
--incase unmatched rows existed, isolate them by adding the line WHERE a.sales_rep is NULL or s.id is NULL

/*The query in Derek's video was pretty long. Let's now use a shorter query to showcase the power of joining with comparison operators.

Inequality operators (a.k.a. comparison operators) don't only need to be date times or numbers, they also work on strings! You'll see how this works by completing the following quiz, which will also reinforce the concept of joining with comparison operators.

In the following SQL Explorer, write a query that left joins the accounts table and the sales_reps tables on each sale rep's ID number and joins it using the < comparison operator on accounts.primary_poc and sales_reps.name, like so:

accounts.primary_poc < sales_reps.name
The query results should be a table with three columns: the account name (e.g. Johnson Controls), the primary contact name (e.g. Cammy Sosnowski), and the sales representative's name (e.g. Samuel Racine). Then answer the subsequent multiple choice question*/

select a.name as account_name,
       a.primary_poc as primary_contact_name,
       s.name as sales_rep_name
from accounts a
left join sales_reps s 
on s.id = a. sales_rep_id
and a.primary_poc < s.name

/*SELF JOIN: Join a table onto itself inorder to find cases where 2 events occurred 1 after another eg which account made multiple orders within 30 days. OPTIMAL TO SHOW BOTH PARENT & CHILD RELATIONSHIPS*/
/*Modify the query from the previous video, which is pre-populated in the SQL Explorer below, to perform the same interval analysis except for the web_events table. Also:

- change the interval to 1 day to find those web events that occurred after, but not more than 1 day after, another web event
- add a column for the channel variable in both instances of the table in your query*/
/*SELECT o1.id AS o1_id,
       o1.account_id AS o1_account_id,
       o1.occurred_at AS o1_occurred_at,
       o2.id AS o2_id,
       o2.account_id AS o2_account_id,
       o2.occurred_at AS o2_occurred_at
  FROM orders o1
 LEFT JOIN orders o2
   ON o1.account_id = o2.account_id
  AND o2.occurred_at > o1.occurred_at
  AND o2.occurred_at <= o1.occurred_at + INTERVAL '28 days'
ORDER BY o1.account_id, o1.occurred_at*/
SELECT w1.id AS w1_id,
       w1.account_id AS w1_account_id,
       w1.occurred_at AS w1_occurred_at,
       w1.channel AS w1_channel,
       w2.id AS w2_id,
       w2.account_id AS w2_account_id,
       w2.occurred_at AS w2_occurred_at,
       w2.channel AS w2_channel
  FROM web_events w1 
 LEFT JOIN web_events w2
   ON w1.account_id = w2.account_id
  AND w1.occurred_at > w2.occurred_at
  AND w1.occurred_at <= w2.occurred_at + INTERVAL '1 day'
ORDER BY w1.account_id, w2.occurred_at

--QN 2: Write a query that uses UNION ALL on two instances (and selecting all columns) of the accounts table. Then inspect the results and answer the subsequent quiz.
select *
from accounts 
union all
select * 
from accounts
--QN 2: Add a WHERE clause to each of the tables that you unioned in the query above, filtering the first table where name equals Walmart and filtering the second table where name equals Disney. Inspect the results then answer the subsequent quiz.
select *
from accounts 
where name = 'Walmart'
union all
select * 
from accounts
where name = 'Disney'

--QN 3: Perform the union in your first query (under the Appending Data via UNION header) in a common table expression and name it double_accounts. Then do a COUNT the number of times a name appears in the double_accounts table. If you do this correctly, your query results should have a count of 2 for each name.
with double_accounts as (
    select *
    from accounts 
    union all
    select * 
    from accounts
)
select name,
       count(*) as name_count
from double_accounts
group by 1
order by 2 desc 