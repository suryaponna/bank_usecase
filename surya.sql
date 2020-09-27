﻿create table Bank_Master(acono int primary key,cname varchar(20) check(len(cname)<=10),city varchar(40) default 'Hyderabad',
balance money not null check(balance >=500), branchcode int foreign key references branchs(branchcode))

create table Branchs(branchcode int primary key,location varchar(10) not null)

alter table branchs alter column location nvarchar(10) not null

create table Transactions(acono int foreign key references bank_master(acono),ttype varchar(1) check(ttype='W' or ttype='d'),
tdate datetime not null,amt money not null)

select * from bank_master

select * from branchs

select * from transactions

insert into branchs values (524,'Bapatla'),(525,'Hyderabad'),(526,'Secunderab')
insert into branchs values(527,'Gacchibowl')
insert into branchs values(528,'KPHB')

select * from branchs

insert into bank_master values(201,'Surya','NDD',600,524)

insert into bank_master values(203,'Prasad','BPP',50000,524)

insert into bank_master values(202,'Krishna','ELR',90000,525)

insert into bank_master values(204,'Surya','GUN',600,526)

insert into bank_master values(205,'Vamshe','PNR',600,527)

insert into bank_master values(206,'Venkat','NSR',600,528)

insert into transactions values(201,'d',getdate(),25000)

insert into transactions values(201,'w',getdate(),5000)

insert into transactions values(201,'w',getdate(),5000)

insert into transactions values(201,'w',getdate(),5000)

insert into transactions values(202,'w',getdate(),500)

insert into transactions values(203,'w',getdate(),5000)

insert into transactions values(204,'d',getdate(),5000)

insert into transactions values(205,'w',getdate(),5000)

insert into transactions values(206,'d',getdate(),1000)

select * from bank_master

--1
select * from bank_master where balance >=30000
--2
select * from branchs left join bank_master on branchs.branchcode=bank_master.branchcode

--3
select * from bank_master where acono=(
select acono from(
select acono,count(*) as sam from transactions where ttype='w' group by acono having 
count(*)=
(select max(sam) from(select acono,count(*) 
as sam from transactions where ttype='w' group by acono )transactions))transactions)

--4
select branchs.location,bank_master.* from bank_master,branchs where bank_master.branchcode in
(select branchcode from(
select branchcode, sum(balance) as branchbal from bank_master group by branchcode having sum(balance) > 10000)bank_master)
and branchs.branchcode=Bank_Master.branchcode

--5 non clustered index on location

create nonclustered index clustered_location on branchs(location)
select * from branchs


--6 view with customer bal > 500
go
create view v1 with encryption as select * from bank_master where balance > 1000
select * from v1

--7 get all transaction date wise

select * from transactions order by tdate 

--8 3 max bal customer details 
select * from bank_master b where 2=(select count(distinct(balance)) from bank_master where balance > b.balance)

--10
create function interest(@a int)
returns float
as
begin
declare @c float,@bal int,@j int
SELECT @J=balance FROM bank_master WHERE acono=@a
if  @j>=100000
begin 
set @c=@j*0.1
--print 'Intrest calculated'
end
return @j+@c
end

declare @a int
set @a= dbo.interest(201)
print @a 
update bank_master set balance=@a where acono =201
select * from bank_master
select * from branchs

--11
create table trandummy(aco int,ttype varchar(1),tdate date,amt money)
alter trigger bankd on trandummy
after insert
as
begin
	declare c1 cursor scroll for select aco,ttype,amt,balance from trandummy,bank_master where aco=bank_master.acono
	declare @aco int,@ttype varchar(1),@amt money,@bal money
	open c1
	fetch last from c1 into @aco,@ttype,@amt,@bal
	if @@FETCH_STATUS = 0
	begin
		if @ttype ='d'
			update bank_master set balance=@bal+@amt where acono=@aco
		else 
			update bank_master set balance=@bal-@amt where acono=@aco
	end
	else
		print 'no records found'
	close c1
	deallocate c1			  
end
insert into trandummy values(206,'d',getdate(),25000)
