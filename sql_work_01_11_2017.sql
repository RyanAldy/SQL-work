-- Functions, concatenate and demonstrating check constraints again

create table bank_accounts(
acc_no char(6) not null unique check(substr(acc_no,1,1) in ('C','S')),
name varchar(20) not null
);

insert into bank_accounts(acc_no, name)
values(
(select 'C' || lpad(nvl(max(substr(acc_no,2,5))+1,'00001'),5,'0')
from bank_accounts),
'Jason Bourne');

insert into bank_accounts(acc_no, name)
values(
(select 'C' || lpad(nvl(max(substr(acc_no,2,5))+1,'00001'),5,'0')
from bank_accounts
where substr(acc_no,1,1)='C'),
'Jason Bourne jr');

insert into bank_accounts(acc_no, name)
values(
(select 'S' || lpad(nvl(max(substr(acc_no,2,5))+1,'00001'),5,'0')
from bank_accounts
where substr(acc_no,1,1)='S'),
'George Bush');

create table cat(
  cid number(3) unique not null,
  name char(10) unique not null
);

create table subcat(
  sid number(3) unique not null,
  cid number(3) references cat (cid),
  name varchar(20) unique not null
);

create table products(
  pid number(3) unique not null,
  sid number(3) references subcat (sid),
  name char(10) unique not null
);

create table sales(
  invoice number(3) not null,
  pid number(3) references products (pid),
  qty number(3),
  price number(5,2),
  date_ordered date
);

-- Find the name of the most popular product - wrong
select name
from products where pid in (
  select pid from sales
  where pid = (
select max(count(*))
    from sales
    group by pid
  )
);

insert into cat
values(1, 'Food');

insert into subcat
  values(101, 1, 'Fast food');


insert into sales
  values(15,1,10,2.00,'01-NOV-2017');

-- Find the name of the most popular product - correct
select name from products
where pid in
(select pid from sales
  group by pid
having count(*) =
  (select max(sold) from
  (select count(*) as sold
  from sales
  group by pid)));

-- Name of most popular subcategory (by most customers not max sales)
select name
from subcat
where sid in (
  select products.sid
  from products, sales
  where products.pid = sales.pid
  group by products.sid
  having count(*) = (
    select max(count(*))
    from products, sales
    where products.pid = sales.pid
    group by products.sid
  )
);

-- SQL Functions
create or replace function double_salary(salary in number)
return number
is
  net_salary number(8,2);
BEGIN
net_salary := salary * 2;
return net_salary;
END;
/ --  had to use this when creating on command line

-- Calling the Function

select first_name, last_name, salary, double_salary(salary)
from employees;





create or replace function get_department(d in number)
  return char
  is
  dname char(30);
  BEGIN
  select department_name into dname
  from departments
  where department_id = d;
  return dname;
  END;
  /


  create or replace procedure print_number(a in number)
  IS
    b number(4);
  BEGIN
    b := 1;
    while b <= a
    loop
      DBMS_output.put_line(b);
      b := b + 1;
    end loop;
  END;

  create or replace procedure print_even(a in number)
  IS
    b number(4);
  BEGIN
    b := 1;
    while b <= a
    loop
      if MOD(b,2) = 0 THEN
      DBMS_output.put_line(b);
      end if;
      b := b + 1;
    end loop;
  END;



  select employee_id
  from employees
  where salary in (select max(salary)
  from employees);

-- Triggers example
create or replace trigger tesco_insert
Before insert on tesco
BEGIN
  DBMS_output.put_line('Hello my friends!');
END;
/

create table sales_audit(
invoice number(3),
pid number(3),
qty number(3),
price number(5,2),
date_ordered date,
delete_date date,
deleted_by char(20)
);


CREATE OR REPLACE TRIGGER sales_before_delete
BEFORE DELETE
   ON sales
   FOR EACH ROW

DECLARE
   v_username varchar2(10);

BEGIN

   SELECT user INTO v_username
   FROM dual;

   -- Insert record into audit table
   INSERT INTO sales_audit
   ( invoice,
     pid,
     qty,
     price,
     date_ordered,
     delete_date,
     deleted_by )
   VALUES
   ( :old.invoice,
     :old.pid,
     :old.qty,
     :old.price,
     :old.date_ordered,
      sysdate,
      v_username);
END;
/

create table asda_backup_delete(
product char(20),
quantity number(3),
price number(5,2),
date_deleted date,
username char(15)
);

create table asda_backup_insert(
product char(20),
quantity number(3),
price number(5,2),
date_deleted date,
username char(15)
);

create table asda_backup_update(
product char(20),
new_product char(20),
quantity number(3),
new_quantity number(3),
price number(5,2),
new_price number(5,2),
date_deleted date,
username char(15)
);

CREATE OR REPLACE TRIGGER asda_backup_trigger
BEFORE DELETE OR INSERT OR UPDATE
ON ASDA
FOR EACH ROW

BEGIN
  if deleting THEN
    insert into asda_backup_delete
    values(:old.product, :old.quantity, :old.price, sysdate, user);
  end if;

  if inserting THEN
    insert into asda_backup_insert
    values(:new.product, :new.quantity, :new.price, sysdate, user);
  end if;

  if updating THEN
    insert into asda_backup_update
    values(:old.product, :new.product, :old.quantity, :new.quantity, :old.price, :new.price, sysdate, user);
  end if;
END;

CREATE OR REPLACE TRIGGER RAISE_DELETE_ERROR
BEFORE DELETE ON tesco
FOR EACH ROW

BEGIN
  if :old.product = 'Fanta' THEN
    raise_application_error(-20001, 'Can not delete Fanta record');
  end if;
END;
