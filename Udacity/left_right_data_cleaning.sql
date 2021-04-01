--question 1:
select right(website, 3) ext,
       count(*) n_ext
from accounts
group by 1
order by 2 desc;

--question 2:
select left(name, 1) co_name, count(*)
from accounts
group by 1
order by 2 desc;

--question 3
--Failed to inteprete qn
select left()
--solution
SELECT SUM(num) nums, SUM(letter) letters
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                          THEN 1 ELSE 0 END AS num, 
            CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                          THEN 0 ELSE 1 END AS letter
         FROM accounts) t1;


--question 4
select left()
--solution
SELECT SUM(vowels) vowels, SUM(other) other
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U') 
                           THEN 1 ELSE 0 END AS vowels, 
             CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U') 
                          THEN 0 ELSE 1 END AS other
            FROM accounts) t1;

/*In cases where one wants to create columns directly from the messy data
without using left,right or substr() functions, they can use
other functions as shown in the code below. Note: All these will work 
similarly to the text_to_column() in excel*/
with table as (
    select student_information,
           value,
           row_number() over(partition by student_information order by (select null)) as row_number 
    from student_db
         cross apply string_split(student_information, ',') as back_values       
)
select student_information,
       [1] as student_id,
       [2] as gender,
       [3] as city,
       [4] as GPA,
       [5] as salary
from table
pivot(
    max(value)
    for row_number in ([1],[2],[3],[4],[5])
) as pvt 
/*query above created a new table with the different columns*/

--QUIZ 2: CONCAT, LEFT, RIGHT, SUBSTR
--question 1: Suppose the company wants to assess the performance of all the sales representatives. Each sales representative is assigned to work in a particular region. To make it easier to understand for the HR team, display the concatenated sales_reps.id, ‘_’ (underscore), and region.name as EMP_ID_REGION for each sales representative.
select s.name as rep_name, 
       concat(s.id,'-',r.name) as emp_id_region
from sales_reps s 
join region r
on r.id = s.region_id

--question 2: From the accounts table, display the name of the client, the coordinate as concatenated (latitude, longitude), email id of the primary point of contact as <first letter of the primary_poc><last letter of the primary_poc>@<extracted name and domain from the website>
select name as client_name,
       concat(lat,long) as coordinate
       concat(left(primary_poc,1), right(primary_poc,1),'@',name,'.',left(website,3)) as email_id
from accounts
--solution: Used a substring to extraxt the name from the website. i missed that in my solution
SELECT NAME, CONCAT(LAT, ', ', LONG) COORDINATE, CONCAT(LEFT(PRIMARY_POC, 1), RIGHT(PRIMARY_POC, 1), '@', SUBSTR(WEBSITE, 5)) EMAIL
FROM ACCOUNTS

--question 3: From the web_events table, display the concatenated value of account_id, '_' , channel, '_', count of web events of the particular channel
select 
    concat(account_id, '-', channel, count(*))
from web_events
group by channel, account_id

--solution
WITH T1 AS (
 SELECT ACCOUNT_ID, CHANNEL, COUNT(*) 
 FROM WEB_EVENTS
 GROUP BY ACCOUNT_ID, CHANNEL
 ORDER BY ACCOUNT_ID
)
SELECT CONCAT(T1.ACCOUNT_ID, '_', T1.CHANNEL, '_', COUNT)
FROM T1;

/*CAST QUIZ:write a query to change date into correct sql format*/
--extract the date from the string
with t1 as (
select substr(date, 1, 10) date
from sf_crime_data
)
--convert it into date data type
select cast(date as date)
from t1
--solution
SELECT date orig_date, (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2)) new_date
FROM sf_crime_data;
--casting it to sql data format or 'date' data type
SELECT date orig_date, (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2))::DATE new_date
FROM sf_crime_data;