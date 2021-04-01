/*Steps to Complete
1. Create a View called “forestation” by joining all three tables - forest_area, land_area and regions in the workspace.
2. The forest_area and land_area tables join on both country_code and year.
3. The regions table joins these based on only country_code.
4. In the ‘forestation’ View, include the following:
- All of the columns of the origin tables
- A new column that provides the percent of the land area that is designated as forest. (adding the new column has played me)
5. Keep in mind that the column forest_area_sqkm in the forest_area table and the land_area_sqmi in the land_area table are in different units (square kilometers and square miles, respectively), so an adjustment will need to be made in the calculation you write (1 sq mi = 2.59 sq km).*/

create view forestation
as 
select fa.year,
       r.country_code,
       r.country_name,
       r.region,
       fa.forest_area_sqkm,
       la.total_area_sq_mi*2.59 as total_area_sqkm,
       --calculating percentage of land area designated as forest
       (fa.forest_area_sqkm/(la.total_area_sq_mi*2.59))*100 as percent_forest_area,
       r.income_group
from forest_area as fa 
join land_area as la 
on fa.country_code = la.country_code
and fa.year = la.year
join regions as r 
on la.country_code = r.country_code
;

--PART 1:
--a. What was the total forest area (in sq km) of the world in 1990? Please keep in mind that you can use the country record denoted as “World" in the region table.
select round(cast(forest_area_sqkm as numeric),2) as total_forest_1990
from forestation
where region = 'World'
  and year = 1990

--b. What was the total forest area (in sq km) of the world in 2016? Please keep in mind that you can use the country record in the table is denoted as “World.”
select round(cast(forest_area_sqkm as numeric),2) as total_forest_2016
from forestation
where region = 'World'
and year = 2016

--c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?
--1.select forest area & any other relevant column eg region for the year 1990
--2.select forest area & any other relevant column for the year 2016
--3. Get the difference between the 2 years: That is the change
with forest_area_1990 as (
     --calculating forest_area in 1990
     select round(cast(forest_area_sqkm as numeric),2) forest_area_90,
       region
     from forestation
     where region = 'World'
     and year = 1990
       ), 
     --calculating forest_area in 2016
     forest_area_2016 as (
     select round(cast(forest_area_sqkm as numeric),2) forest_area_16,
         region
     from forestation
     where region = 'World'
     and year = 2016
         )
    --Finding change in forest_area
      select forest_area_90,
             forest_area_16, 
             forest_area_16 - forest_area_90 as difference_forest_area
      from forest_area_2016 fa16
      join forest_area_1990 fa90
      on fa90.region = fa16.region

--d. What was the percent change in forest area of the world between 1990 and 2016?
     --follow similar steps in c)1&2 above
     --calculate percentage change between the 2 years 

     --calculating forest_area in 1990
     with forest_area_1990 as (
     select round(cast(forest_area_sqkm as numeric),2) forest_area_90,
       region
     from forestation
     where region = 'World'
     and year = 1990
       ), 
     --calculating forest_area in 2016
     forest_area_2016 as (
     select round(cast(forest_area_sqkm as numeric),2) forest_area_16,
         region
     from forestation
     where region = 'World'
     and year = 2016
         )
      --Finding percentage change
      select forest_area_90,
             forest_area_16, 
             round(((forest_area_16 - forest_area_90)/forest_area_90)*100,2) as percent_change_forest_area
      from forest_area_2016 fa16
      join forest_area_1990 fa90
      on fa90.region = fa16.region
;

--e. If you compare the amount of forest area lost between 1990 and 2016, to which country's total area in 2016 is it closest to?
select f.country_name,
       f.total_area_sqkm as total_area_sqkm,
       ABS((f.total_area_sqkm)- (select 
                                       fa90.forest_area_sqkm - fa16.forest_area_sqkm as difference
                                from (
                                        select 
                                               f.country_name, 
                                               f.forest_area_sqkm
      	                                from forestation f
                                        where f.country_name = 'World'
              	                          and f.year = 1990
                                      ) as fa90
                                join (
                                        select 
                                              f.country_name,
                                              f.forest_area_sqkm
      		                        from forestation f
                                        where f.country_name = 'World'
              	                          and f.year = 2016) as fa16 
                                   on fa90.country_name = fa16.country_name)) as diff_fa
    from forestation f
    where f.year = 2016
    order by diff_fa 
    LIMIT 1
;
--PART 2
--Create a table that shows the Regions and their percent forest area (sum of forest area divided by sum of land area) in 1990 and 2016. (Note that 1 sq mi = 2.59 sq km). Based on the table you created, ....
create view regional_forest_area 
as
select year,
       region,
       sum(forest_area_sqkm) as sum_forest_area_sqkm,
       sum(total_area_sqkm) as sum_land_area_sqkm,
       (sum(forest_area_sqkm)/sum(total_area_sqkm))*100 as percent_forest_area
from forestation
where year in (1990, 2016)
group by region, year
order by year
;                         
--a. What was the percent forest of the entire world in 2016? Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?
select round(cast(percent_forest_area as numeric),2) as percent_forest_region
from regional_forest_area
where year = 2016 
and region = 'World'
;
--use max() to pick highest and limit to give only 1 row, top most
select region, 
       sum_land_area_sqkm,
       max(round(cast(percent_forest_area as numeric),2)) as highest_percent_forest
from regional_forest_area
where year = 2016 
group by region, sum_land_area_sqkm
order by highest_percent_forest desc
limit 1 
;

--use min() to pick highest and limit to give only 1 row, top most
select region, 
       sum_land_area_sqkm,
       min(round(cast(percent_forest_area as numeric),2)) as highest_percent_forest
from regional_forest_area
where year = 2016 
group by region, sum_land_area_sqkm
order by highest_percent_forest
limit 1 
;


--b. What was the percent forest of the entire world in 1990? Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places?
--Follow all the steps in 2a above and change the year to 1990.
select round(cast(percent_forest_area as numeric),2) as percent_forest_region
from regional_forest_area
where year = 1990 
and region = 'World'
;

select region, 
       sum_land_area_sqkm,
       max(round(cast(percent_forest_area as numeric),2)) as highest_percent_forest
from regional_forest_area
where year = 1990 
group by region, sum_land_area_sqkm
order by highest_percent_forest desc
limit 1 
;

select region, 
       sum_land_area_sqkm,
       min(round(cast(percent_forest_area as numeric),2)) as highest_percent_forest
from regional_forest_area
where year = 1990 
group by region, sum_land_area_sqkm
order by highest_percent_forest
limit 1 
;

--c. Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016?
--1. select columns for the year 1990 and 2016 separately
--2. select region, percent_forest_area
--3. Calculate difference, add a column for difference
--4. Filter to show percentage forest area in 1990 that were greater than in 2016
with forest_area_1990 as (
--select all columns for the year 1990
select *
from regional_forest_area
where year = 1990
), forest_area_2016 as (
--select all columns for the year 2016
select *
from regional_forest_area
where year = 2016
 )
--pick out region and forest_area for each region
select fa90.region,
        round(cast(fa90.percent_forest_area as numeric),2) as forest_1990,
        round(cast(fa16.percent_forest_area as numeric),2) as forest_2016,
--introduce a difference column to see which rows give me a negative difference hence decrease
        fa16.percent_forest_area - fa90.percent_forest_area as difference
from forest_area_1990 as fa90
join forest_area_2016 as fa16
on fa90.region = fa16.region
--use where clause to filter out all the rows where forest area in 90 is larger
where fa90.percent_forest_area > fa16.percent_forest_area
;


--PART 3
--a. Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? What was the difference in forest area for each?
--1. select all columns for years 1990 & 2016
--2. Filter to both 1990 & 2016 separately
--3. Exlude all the nulls in forest_area column
--4. Exclude country 'World'
--5. Calculate the difference (1990 from 2016)
with forest_area_1990 as (
select *
from forestation f90
where year = 1990
--Exclude forest_area_sqkms that are null
and forest_area_sqkm is not null
--Exclude world, doesn't qualify as a country_name
and country_name != 'World'
), forest_area_2016 as (
select *
from forestation f16
where year = 2016
and forest_area_sqkm is not null
and country_name != 'World'
 )
 select fa90.country_name,
        fa90.region,
        fa90.forest_area_sqkm as forest_area90,
        fa16.forest_area_sqkm as forest_area16,
--get difference in forest area between 2 years
        round(cast(fa16.forest_area_sqkm - fa90.forest_area_sqkm as numeric),2) as difference
from forest_area_1990 as fa90
join forest_area_2016 as fa16
on fa90.country_name = fa16.country_name
order by difference 
limit 5
;

--b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?
--Follow same steps in 3b however calculate percent decrease ((2016-1990/1990)*100)
with forest_area_1990 as (
select *
from forestation f90
where year = 1990
--Exclude forest_area_sqkms that are null
and forest_area_sqkm is not null
--Exclude world, doesn't qualify as a country_name
and country_name != 'World'
), forest_area_2016 as (
select *
from forestation f16
where year = 2016
and forest_area_sqkm is not null
and country_name != 'World'
 )
 select fa90.country_name,
        fa90.region,
        fa90.forest_area_sqkm as forest_area90,
        fa16.forest_area_sqkm as forest_area16,
--get difference in percent forest area between 2 years
        fa16.forest_area_sqkm - fa90.forest_area_sqkm as difference,
        round(cast(((fa16.forest_area_sqkm - fa90.forest_area_sqkm)/fa90.forest_area_sqkm)*100 as numeric),2) as perc_difference
from forest_area_1990 as fa90
join forest_area_2016 as fa16
on fa90.country_name = fa16.country_name
order by perc_difference
limit 5 

option 2:
with forest_area_1990 as (
select *
from forestation f90
where year = 1990
--Exclude forest_area_sqkms that are null
and percent_forest_area is not null
--Exclude world, doesn't qualify as a country_name
and country_name != 'World'
), forest_area_2016 as (
select *
from forestation f16
where year = 2016
and percent_forest_area is not null
and country_name != 'World'
 )
 select fa90.country_name,
        fa90.region,
        fa90.percent_forest_area as forest_area90,
        fa16.percent_forest_area as forest_area16,
--get difference in percent forest area between 2 years
        fa16.percent_forest_area - fa90.percent_forest_area as difference,
        round(cast(((fa16.percent_forest_area - fa90.percent_forest_area)/fa90.percent_forest_area)*100 as numeric),2) as perc_difference
from forest_area_1990 as fa90
join forest_area_2016 as fa16
on fa90.country_name = fa16.country_name
order by perc_difference
limit 5 
;

--c. If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?
--1. select all columns from forestation db
--2. quartiles are into 4 hence group according to percentage. use case when to differentiate the quarters
--3. count(quartile groups)
with forest_area_2016 as
(
select *
from forestation
where year = 2016
and percent_forest_area is not null
and country_name != 'World'
),
percentile as (
select fa16.country_name,
       case when fa16.percent_forest_area <=25 then '0-25%' 
       when fa16.percent_forest_area > 25 and fa16.percent_forest_area <=50 then '25%-50%' 
       when fa16.percent_forest_area > 50 and fa16.percent_forest_area <=75 then '50%-75%'
       else '75%-100%'
      end as quartile
from forest_area_2016 as fa16
 )
 select distinct quartile,
                 count(quartile) as count_quartile_group
 from percentile
 group by quartile 
 order by count_quartile_group desc
 ;

--d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.
--1. Follow steps 1 & 2 from 3c above
--2. select country, region and percent_forest_area
with forest_area_2016 as
(
select *
from forestation
where year = 2016
and percent_forest_area is not null
and country_name != 'World'
),
percentile as (
select fa16.*,
       case when fa16.percent_forest_area <=25 then '0-25%' 
       when fa16.percent_forest_area > 25 and fa16.percent_forest_area <=50 then '25%-50%' 
       when fa16.percent_forest_area > 50 and fa16.percent_forest_area <=75 then '50%-75%'
       else '75%-100%'
      end as quartile
from forest_area_2016 as fa16
 )
 select distinct p.country_name, 
                 p.region,
                 round(cast(p.percent_forest_area as numeric),2),
                 quartile
 from percentile p
 where quartile = '75%-100%'
 ;

--e. How many countries had a percent forestation higher than the United States in 2016?
--1. select columns from forestation
--2. use a sub query to pick country in the united states
--3. filter percent_forest_area to pick countries greater than
with forest_area_2016 as (
        select *
        from forestation
        where year = 2016
        and percent_forest_area is not null
        and country_name != 'World'
)
select count(country_name)
from forest_area_2016 as fa16 
where fa16.percent_forest_area > (
        select fa16.percent_forest_area
        from forest_area_2016 fa16
        where fa16.country_name = 'United States'
)
;
case 
  when condition then 
  else 
end;


       