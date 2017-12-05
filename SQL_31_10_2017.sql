select nvl(job_id, 0) as job, count(*) as no_of_emp, sum(salary + nvl(commission_pct,0)) as sum_of_salary, avg(salary) as average
from employees
group by job_id
having count(2) >= 5
and avg(salary) > (select avg(salary) from employees)
order by no_of_emp, job_id;


-- Find the names of the employees where...
select first_name, last_name from employees where employee_id = (
	select manager_id from employees
	group by manager_id having count(*) = (
		select max(people) from (
			select count(*) as people
			from employees
			group by manager_id)
			)
		);

		
		
create view manager_no_of_emps
  as select manager_id, count(*) as no_of_emps
  from employees
  group by manager_id
  order by manager_id, no_of_emps;
  
View MANAGER_NO_OF_EMPS created.

SQL> select * from manager_no_of_emps;

create table temp_manager_names as
  select distinct(manager_id), ' ' as manager_name
  from employees;

  
  /* insert into temp_manager_names(first_name, last_name) 
   select b.first_name, b.last_name
   from employees b
   where manager_id = b.employee_id;
*/

select trim(column_name), trim(table_name), trim(constraint_name)
from user_cons_columns;

alter table myfriends
drop constraint SYS_C0014534;
--Table MYFRIENDS altered.
  


  