--question 1: Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc.
SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') -1 ) first_name, 
RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name
FROM accounts;

--question 2: Now see if you can do the same thing for every rep name in the sales_reps table. Again provide first and last name columns.
SELECT LEFT(name, STRPOS(name, ' ') -1 ) first_name, 
       RIGHT(name, LENGTH(name) - STRPOS(name, ' ')) last_name
FROM sales_reps;

/*QUIZ:CONCAT & STRPOS*/
--My solutions also give similar output but they are too crowded, solution from lesson is easy to read.
--Question 1:Each company in the accounts table wants to create an email address for each primary_poc. The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.
select primary_poc
       concat(left(primary_poc,strpos(primary_poc, '') -1), RIGHT(primary_poc, length(primary_poc) - STRPOS(primary_poc, ' ')), '@', name, '.com')
from accounts

--solution
WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', name, '.com')
FROM t1;

--question 2: You may have noticed that in the previous solution some of the company names include spaces, which will certainly not work in an email address. See if you can create an email address that will work by removing all of the spaces in the account name, but otherwise your solution should be just as in question 1. Some helpful documentation is here.
used replace() to trim whitespace
select primary_poc
       concat(left(primary_poc,strpos(primary_poc, ' ') -1), RIGHT(primary_poc, length(primary_poc) - STRPOS(primary_poc, ' ')), '@', replace(name, ' ',''), '.com')
from accounts

--solution
WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', REPLACE(name, ' ', ''), '.com')
FROM  t1;

--question 3:We would also like to create an initial password, which they will change after their first log in. The first password will be the first letter of the primary_poc's first name (lowercase), then the last letter of their first name (lowercase), the first letter of their last name (lowercase), the last letter of their last name (lowercase), the number of letters in their first name, the number of letters in their last name, and then the name of the company they are working with, all capitalized with no spaces.
select 
   
from accounts
--solution
WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', name, '.com'), LEFT(LOWER(first_name), 1) || RIGHT(LOWER(first_name), 1) || LEFT(LOWER(last_name), 1) || RIGHT(LOWER(last_name), 1) || LENGTH(first_name) || LENGTH(last_name) || REPLACE(UPPER(name), ' ', '')
FROM t1;

--QUIZ: COALESCE
SELECT a.*, o.*,
coalesce(a.id) as id,
coalesce(o.account_id, a.id) as account_id,
coalesce(o.standard_qty, 0) as standard_qty,
coalesce(o.gloss_qty, 0) as gloss_qty,
coalesce(o.poster_qty, 0) as poster_qty,
coalesce(o.standard_amt_usd, 0) as standard_amt_usd,
coalesce(o.gloss_amt_usd, 0) as gloss_amt_usd,
coalesce(o.poster_amt_usd, 0) as poster_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;