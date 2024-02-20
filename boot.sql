-- 1.continet wise total population and country count
SELECT 
    Continent, SUM(population), COUNT(Name)
FROM
    world.country
GROUP BY 1
order by 2;


-- 2.retrieving all the data of countries having population above the world average
SELECT 
    *
FROM
    world.country
WHERE
    population > (SELECT 
                  AVG(population)
                  FROM
				  world.country);


-- 3.retrieving the name and population of countries having population above average population within each continent
select
 continent,name,ppl 
 from  (
 select 
 name,continent,population as ppl,
 avg(Population) over(partition by Continent ) as avgppl 
 from 
 world.country) a 
 where ppl>avgppl 
 order by 1,3 desc;


-- 4.top 5 coutries based on life expectency
SELECT 
    Continent, Name, LifeExpectancy
FROM
    world.country
ORDER BY 3 DESC
LIMIT 5;


-- 5.continent wise top 3 coutries based on life expectancy using CTE
with top3 
as
(select 
Continent,Name,LifeExpectancy,dense_rank() over(partition by continent order by LifeExpectancy desc ) as rnk
 from world.country)
 select 
 Continent,Name,LifeExpectancy
 from top3
 where rnk <4;


-- 6.using joins,getting the official language of countries from countrylanguage table
select * from
(select continent,name,Code from world.country) as a
join
(select CountryCode,Language,IsOfficial from world.countrylanguage) as b
on a.code=b.CountryCode
where IsOfficial='t' ;


-- 7.continent wise cumulative sum
SELECT 
    sortpop.Continent,sortpop.pop,@cumpop:=@cumpop+sortpop.pop as cumulativepopulation
FROM
    (SELECT 
        continent, SUM(population) as pop
    FROM
        world.country
    GROUP BY 1
    ORDER BY 2 DESC) sortpop,
    (SELECT @cumpop:=0) cumpop;

    
-- 8.median population and curresponding country
select 
name,avg(population) over() 
from
(select 
    *,row_number() over(order by population) as rnum
	from world.country) a,
(select 
     count(*) as cnt 
     from world.country) b
where rnum in (floor((cnt+1)/2),floor((cnt+2)/2));


-- 9.median population and curresponding country in each continent
select 
continent,name,avg(population) over() 
from
(select 
    *,row_number() over(partition by continent order by population) as rnum,count(*) over(partition by Continent) as cnt
	from world.country) a
where rnum in (floor((cnt+1)/2),floor((cnt+2)/2));


-- 10.creating crosstab by deriving population percentage column (also using temporary table)
-- creating temporary table
create 
      temporary table world.temppopulation as
(select 
       *,population/tpop*100 as poppercentage 
 from
(select 
       continent,name,population, sum(population) over() as tpop 
 from 
      world.country) a);
-- creating crosstab using it 
SELECT 
    continent,
    SUM(IF(poppercentage > 3, 1, 0)) AS high_population,
    SUM(IF(poppercentage <= 3 AND poppercentage > .3,
        1,
        0)) AS medium_population,
    SUM(IF(poppercentage <= .3, 1, 0)) AS low_population
FROM
    world.temppopulation
GROUP BY 1;


-- 11.coutries,which got independence after india got independence
SELECT 
    name, IndepYear
FROM
    world.country
WHERE
    IndepYear > (SELECT 
            IndepYear
        FROM
            world.country
        WHERE
            name = 'india')
ORDER BY 2;










