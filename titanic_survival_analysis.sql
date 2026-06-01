use titanic;
set sql_safe_updates=0 ;
/*1. Data Cleaning: Handling invalid values in the Age column
Replacing 0 values with NULL to ensure statistical accuracy*/
update titanic2
set Age = null
where Age = 0;

/* 2. Data Exploration: Checking for missing values
 Counting the number of passengers with missing Age information*/
select COUNT(*) as missing_age
from titanic2
where age is null;

/*3. Data Analysis: Calculating the overall survival rate
Finding the percentage of passengers who survived the Titanic disaster*/
select round ((SUM(survived) / COUNT(*)) * 100,2) as overall_survival_rate
from titanic2;
-- 4. survival rate by sex
select 
sex,
count(*) as total_passengers,
sum(survived) as survived_count,
round((sum(survived)/count(*))*100,2)as survival_rate
from titanic2
group by sex;

-- 5.Survived rate by passenger class

select
pclass,
count(*) as total_passengers,
sum(survived) as survived_count,
round((sum(survived)/count(*))*100,2)as survival_rate
from titanic2
group by pclass;

-- 6.Analyze passenger survival statistics categorized by age group

select
case 
when age is null then 'Unknown'
when age<18 then 'Child'
else 'Adult'
end as age_group ,
count(*) as total_passengers,
sum(survived) as survived_count,
round((sum(survived)/count(*))*100,2)as survival_rate
from titanic2
group by age_group;

-- 7 Impact of family size on passenger survival

select
case
when sibsp + parch= 0 then 'Alone'
when sibsp + parch between 1 and 3 then 'Small Family'
else 'Large Family'
end as family_group,
count(*) as total_passengers,
sum(survived) as survived_count,
round((sum(survived)/count(*))*100,2)as survival_rate
from titanic2
group by family_group;

-- 8. Analyzing survival rates based on the port of embarkation

select
case
when embarked = 'C' then 'Cherbourg'
when embarked = 'Q' then 'Queenstown'
when embarked = 'S' then 'Southampton'
else 'Unknown'
end as embark_port,
count(*) as total_passengers,
sum(survived) as survived_count,
round((sum(survived)/count(*))*100,2)as survival_rate
from titanic2
group by embark_port;

-- 9. Relationship between survival status and fare statistics 

select
survived,
count(*) as Passenger_Count,
avg(Fare) as Average_Fare,
min(Fare) as Min_Fare,
max(Fare) as Max_Fare
from titanic2
group by survived;

/* 10. Analyze socio-economic impact on survival by calculating Average Fare 
and Survival Rate per Passenger Class (Pclass)*/

select 
pclass,
round(avg(Fare),2) as Avg_Class_Fare,
round(sum(survived) *100.0/ count(*),2) as survival_Rate
from titanic2
group by pclass;

/* 11. Categorize passengers into four groups based on their ticket fare alter
to determine if paying more increased the probability of survival */

select
case
when fare <=10 then 'Very low (0-10)'
when fare > 10 and fare <= 30 then 'Medium (10-30)'
when fare >30 and fare <= 100 then 'High (30-100)'
when fare is null then 'Unknown'
else 'Luxury (100+)'
end Fare_Category,
count(*) as Total_Passengers,
Sum(survived ) as Survived_Count,
round(sum(survived) *100.0/ count(*),2) as survival_rate
from titanic2
group by Fare_Category
order by survival_rate desc;

/*
12. Survival Rate by Passenger Title

This query extracts social titles from passenger names, such as Mr, Mrs, Miss,
Master, Dr, Sir, and Lady. These titles can provide insight into social status,
gender, and age-related groups.

The query then calculates the total number of passengers, number of survivors,
and survival rate for each title.
*/

select
trim(substring_index(substring_index(name, ',', -1),'.',1)) as title,
count(*) as total_passengers,
sum(survived) as survived_count,
round((sum(survived)/count(*))*100,2)as survival_rate
from titanic2
group by title
order by survival_rate desc, total_passengers desc;


/*
13. Impact of Cabin Assignment on Survival

This query compares passengers with recorded cabin information
against passengers without cabin information.

In this dataset, missing cabin values are stored as empty strings
rather than NULL values. Therefore, both NULL and empty cabin values
are treated as "No Cabin" to make the analysis accurate.
*/

SELECT
CASE
WHEN cabin IS NULL OR TRIM(cabin) = '' THEN 'No Cabin'
ELSE 'Has Cabin'
END AS cabin_status,
COUNT(*) AS total_passengers,
SUM(survived) AS survived_count,
ROUND(SUM(survived) * 100.0 / COUNT(*), 2) AS survival_rate
FROM titanic2
GROUP BY cabin_status
ORDER BY survival_rate DESC;

/*
14. Comparative Analysis: 3rd Class Female Passengers vs. 1st Class Male Passengers

This query compares survival rates between two contrasting groups:
female passengers in 3rd class and male passengers in 1st class.

The goal is to examine whether gender may have had a stronger influence
on survival chances than passenger class in this specific comparison.
*/


(select '3rd Class Female' as Category ,round(avg(survived)*100,2) As survival_Rate
from titanic2 where pclass=3 and sex='female')
union 
(select '1rd Class Male'as Category ,round(Avg(survived)*100,2) as survival_Rate
from titanic2 where pclass=1 and sex= 'male')
order by survival_rate desc;



/*
15. Creating a Comprehensive Survival Profile

This view combines multiple survival factors: passenger class, gender,
and age group. It calculates the survival chance for each group by converting
the average survival value into a percentage.

This helps identify which groups had higher survival probabilities,
such as first-class female children, and which groups were at higher risk.*/

create or replace view Survival_Profile as
select
pclass,
sex,
case
when age is null then 'Unknown'
when age < 18 then 'Child'
else 'Adult'
end as age_group,
ROUND(AVG(survived) * 100, 2) as survival_chance
from titanic2
group by pclass, sex, age_group;

select *
from Survival_Profile
order by survival_chance desc;







