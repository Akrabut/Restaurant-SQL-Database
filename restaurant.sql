

--CLEAR OLD TABLES
drop table tables cascade constraints;
drop table diners cascade constraints;
drop table waiters cascade constraints;
drop table visits cascade constraints;
--CLEARING ENDS

--CREATE NEW TABLES AND INSERT VALUES
create table Tables
(
tnum number(1) primary key,
floor number(1) not null,
capacity number(1) not null,
location varchar(30) not null
);

create table Diners
(
dinerid number(2) primary key,
name varchar(1),
phone number(2),
city varchar(2) not null
);

create table Waiters
(
wid number(3) primary key,
wname varchar(3),
totalOrders number(2) default 0,
totalBill number(5) default 0,
payment number(4) default 0
);

create table Visits
(
dinerid number(2),
visitDay varchar(3) constraint checkday check(visitDay in ('sun', 'mon', 'tue', 'wed', 'thu', 'fri')),
tnum number(1) constraint tablenumber references Tables(tnum),
wid number(3) constraint waiter references Waiters(wid),
numOfDiners number(1) not null,
bill number(3) DEFAULT 0,
constraint diner foreign key (dinerid) references Diners (dinerid)
);

--QUESTION 2
create or replace trigger waiter_details 
    after insert on Visits 
    for each row
begin
        update Waiters 
        set totalBill = totalBill + :new.bill,
        totalOrders = totalOrders + 1,
        payment = (totalBill + :new.bill) / 10
        where wid = :new.wid;
end;
/
--END OF QUESTION 2


insert into tables values (6, 2, 6, 'Near stairs');
insert into tables values (1, 1, 4, 'Near Entrance');
insert into tables values (2, 1, 4, 'Far corner on the right');
insert into tables values (7, 2, 4, 'Far corner');
insert into tables values (8, 2, 8, 'Far corner');
insert into tables values (3, 1, 2, 'Near window');
insert into tables values (4, 1, 2, 'Far corner on the left');
insert into tables values (5, 1, 2, 'Near window');
insert into tables values (9, 2, 8, 'Near stairs');


insert into diners values (1, 'A', 11, 'AA');
insert into diners values (2, 'B', 33, 'CC');
insert into diners values (3, 'C', 66, 'CC');
insert into diners values (4, 'C', 55, 'DD');
insert into diners values (5, 'D', 44, 'CC');
insert into diners values (6, 'A', 22, 'BB');
insert into diners values (7, 'B', 22, 'BB');
insert into diners values (8, 'D', 33, 'CC');
insert into diners values (9, 'E', 11, 'AA');
insert into diners values (10, 'F', 77, 'DD');
insert into diners values (11, 'F', 22, 'BB');


insert into waiters values (111, 'AAA', 0, 0, 0);
insert into waiters values (222, 'BBB', 0, 0, 0);
insert into waiters values (333, 'CCC', 0, 0, 0);
insert into waiters values (444, 'DDD', 0, 0, 0);


insert into visits values (1, 'sun', 5, 222, 2, 400);
insert into visits values (5, 'sun', 5, 222, 1, 200);
insert into visits values (6, 'sun', 7, 111, 3, 500);
insert into visits values (3, 'mon', 9, 333, 5, 325);
insert into visits values (10, 'mon', 9, 444, 6, 801);
insert into visits values (5, 'mon', 3, 111, 1, 400);
insert into visits values (5, 'fri', 3, 111, 1, 128);
insert into visits values (7, 'fri', 7, 111, 4, 551);
insert into visits values (2, 'fri', 6, 444, 5, 630);
insert into visits values (3, 'fri', 2, 444, 3, 225);

--QUESTION 3
prompt TRIGGER WORKED, RESULTS-;
select * from waiters;
--END OF QUESTION 3

--QUESTION 4.A
prompt NORMAL CURSOR
accept x char prompt 'Enter a day in format sun/mon/tue/wed/thu/fri '
declare 
    a varchar2(10);
    t number(2);
    n number(2);
    b number(4);
    v varchar2(3);
    cursor day_details is select tnum, numOfDiners, bill, visitDay from Visits order by bill desc;
begin
    open day_details;
    a := '&x';
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Report for day - ' || a);
    loop
    fetch day_details into t, n, b, v;
    exit when day_details%notfound;
    if (v like a) then
    DBMS_OUTPUT.PUT_LINE(t || ' | ' || n || ' | ' || b);  
    end if;
    end loop;
    close day_details;
end;
/
--END OF QUESTION 4.A


--QUESTION 4.B
prompt FOR LOOP CURSOR
accept x char prompt 'Enter a day in format sun/mon/tue/wed/thu/fri '
declare
    a varchar2(10);
    cursor day_details2 is select tnum, numOfDiners, bill, visitDay from Visits order by bill desc;
begin
    a := '&x';
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Report for day - ' || a);
    for day_detail in day_details2
    loop
    if (day_detail.visitDay like a) then
    DBMS_OUTPUT.PUT_LINE(day_detail.tnum || ' | ' || day_detail.numOfDiners || ' | ' || day_detail.bill);
    end if;
    end loop;
end;
/
--END OF QUESTION 4.B

--QUESTION 5
prompt FUNCTION BLOCK
create or replace function maxbill(a varchar)
return number is highest number(3);
    vara varchar(10) := '0';
begin
    select distinct wname into vara from waiters inner join visits on visits.wid = waiters.wid where a like wname group by wname;
    if (vara is not null) then
        select max(bill) into highest from visits inner join waiters on visits.wid = waiters.wid where wname like vara;
        DBMS_OUTPUT.PUT_LINE(a || ' | ' || highest);
        return highest;
    end if;

    EXCEPTION WHEN NO_DATA_FOUND then
        DBMS_OUTPUT.PUT_LINE('this waiter could not be found');
        highest := -1;
        return highest;
    END;

/
accept x char prompt 'Enter waiter name: ';
declare
     y number(5);
     a varchar(10);
begin
    a:='&x';
    y := maxbill(a);
end;
/
--END OF QUESTION 5


--QUESTION 6
PROMPT PROCEDURE BLOCK
create or replace procedure dinerdetails(a number) is
    cursor diner_details is select dinerid, visitDay, tnum, numOfDiners, bill, (bill/numOfDiners) from Visits;
begin
    for diner_detail in diner_details
    loop
    if (a = diner_detail.dinerid) then
        DBMS_OUTPUT.PUT_LINE(diner_detail.visitDay || '     ' || diner_detail.tnum || '     ' || diner_detail.numOfDiners || '     ' || diner_detail.bill || '     ' || (diner_detail.bill/diner_detail.numOfDiners));
    end if;
    end loop;
end;
/
accept x char prompt 'Enter diner number: ';
declare
a number(5);
begin
a:='&x';
dinerdetails(a);
end;
/
--END OF QUESTION 6


