use hello

----1) To find the average growth of each state 
select  state, round(AVG(growth)*100,2) as avg_state_growth from data1 
group by state
order by avg_state_growth desc



----2) To find the average sex ratio from each state
select state,round(AVG(sex_ratio)*100,2) as avg_sex_ratio from data1 
group by state
order by avg_sex_ratio desc


-----3) To find the top 5 states with max literacy
select top 5 state,round(max(literacy),2)as Max_literacy from data1
where (literacy) is not null
group by state
order by max_literacy asc


-----4) To find top 3 states with average growth rate 

select top 3 state,round(avg(Growth),2)as avg_growth from data1
group by state
order by avg_growth desc

------5)To find the states whose avg_literacy is greater than 90 
----- Method 1 : CTE		

with t1 as (
select state,avg(literacy) as avg_literacy
from Data1
group by state 
)
select * from t1
where avg_literacy>90
order by avg_literacy 



----- Method 2 : Having Clause 
select state ,avg(literacy) from data1 
group by state having avg(literacy)>90



------6)Top 3 and bottom 3 states based on average literacy using CTE------

with t1 as (
select  top 4 state,avg(literacy) as avg_literacy
from Data1
group by state 
order by avg_literacy asc
),
 t2 as (
select  top 3 state,avg(literacy) as avg_literacy
from Data1
group by state 
order by avg_literacy desc
)
select * from t2
union 
select * from t1
where avg_literacy is not null
order by avg_literacy desc
----------------------------------------------------------------------------------------------------


--------7)To find the three states with lowest avg sex ratio----


select top 4 state ,avg(Sex_ratio)*100 as Sex_ratio from Data1 
group by state
having avg(Sex_ratio)*100  is not null
order by avg(Sex_Ratio) asc


------8)Top and Bottom 3 states using literacy rate 
----  Method 1  using data table 
drop table if exists top_states
create table  top_states (state varchar(255),top_states float )

insert into top_states
select   top 4 state, avg(Literacy)*100 from Data1 
group by state
order by avg(Literacy) desc

select * from top_states

------9) To find the states starting with letter a or b 
-----States starting with letter a 

select  distinct state from data1 
where state like 'a%' or state like 'b%'
order by state

------10) To find the states starting with letter a and end with letter m----- 

select  distinct state from data1 
where state like 'a%m'
order by state


----formulaes----
----female/male= sex-ratio,---(1)
----female + male = population---(2)
----from (1) &(2) we get the formulaes for male & female as follows
-----male = population/(1+sex-ratio)
---- female= population*sex_ratio/(1+sex_ratio)


----11)Total number of Female & Male population per state
---------Method 1 using CTE 
with gender_population as 
(
select  d1.state, d1. district,sum(round((Population*Sex_Ratio)/(1+ Sex_Ratio),0))  Female,
sum(round(population/(1+sex_ratio),0))  Male
from data1 d1 join  data2 d2 on   
d2.district= d1.District 
group by d1.state, d1.district
) 
select state,
	   sum(Female) Total_Females,
	   sum(Male) Total_Males
	   from gender_population
group by state
order by State


----- Method 2:- To find the Female and Male population per state using subqueries 
 select c.state ,
 sum(c.Female) Total_Females,
 sum(c.Male) Total_males from 
(
select  d1.state, d1. district,
sum(round((Population*Sex_Ratio)/(1+ Sex_Ratio),0))  Female,
sum(round(population/(1+sex_ratio),0))  Male
from data1 d1 join  data2 d2 on   
d2.district= d1.District 
group by d1.state, d1.district
) c 
group by c.state
order by c.State

----12)Total number of literate and illiterate people per state
----- total literate and illterate people  statewise-----
 ------ literacy rate = literacy * population
 -------illiteracy rate = (1-literacy)*population


select  d.state,
   		round(sum(d.Literacy/100 *d1.population),0) as literate_people,
	    round(sum((1-d.Literacy/100) *d1.population),0) as illiterate_people 
		from Data1 d
        join data2 d1 on  d.District=d1.District
		group by d.state
		

------population in previous census

-----previous census*growth+ previous census=population
------previous census(1+growth)= population
-------(previous census)= population/(1+growth)
select * from Data1
select * from Data2

-----13)To calculate the previous census from current census(population)
select  d1.state,
round(sum(d2.population/(1+d1.growth)),0) Previous_census,
sum(d2.Population) Current_census 
from Data1 d1 join Data2 d2 on 
d2.District=d1.District
group by d1.State
order by current_census desc


---- 14)To calculate the area/census or total area/area occupied by previous year population and current population 
select h.area/(h.prev_census) as prevs_census ,h.area/cast(h.current_census as float)as cur_census
from 
(
select q.*,r.area
from
(
select '1'as keys,d.*
from 
(
select 
sum(c.previous_census) as prev_census,
sum(c.current_census) as current_census
	from
	(
	select 
	d1.state,
	sum(round(d2.population/(1+d1.growth),0)) previous_census,
	sum(d2.Population) current_census 
	from 
	Data1 d1 join Data2 d2 on 
	d2.District=d1.District
	group by d1.State
	)
	c
)
d
) q 
join 
(
select '1' as keys, f.* from 
(select sum(area_km2) as area from Data2)
f
)
r 
on
q.keys= r.keys
)
h




select  Data1.state , count(District)as total,District from Data1
group by District
having count(district)=1
order by Data1.state

----- 15) Top 3 Districts with highest literacy per state.  
with top_literacy_districts as (
select  
row_number()
over 
(partition by state
order by literacy desc) as Top_3_Districts ,
literacy,State, District from Data1
group by District,State,Literacy
)
select * from top_literacy_districts
where Top_3_Districts in (1,2,3)







