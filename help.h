Welcome to our help page
thanks for using this simple DBMS
here is help and manual
-------------------------------------------- Create ------------------------------------------------------------
first of all you should create Database using syntax create database DbName ..for example: create database os
then use the database by typing: use os
then you should create table using create table tblname ,for ex:create table students
a message will be appeard to you requesting the numbers of fields of that table 
then you will enter a number 
after that you will be asked about the field name and if it is primary key or not ,it's type and other properties

-------------------------------------------- Insert ------------------------------------------------------------
to insert a value in that table you should follow the syntax insert into tblname for ex: insert into students
a message will be appeard asking about the value of the record 

-------------------------------------------- select ------------------------------------------------------------

to select data from Database you should follow the syntax select all from tblname for ex: select all from students 
you also could use select statement with where condition 

----------------------------------------------Delete------------------------------------------------------------
to delete a record in database you should type delete from tblName where var = val  for ex:delete from students where id = 1
-----------------------------------------------------------------------------------------------------------------

----------------------------------------------update-------------------------------------------------------------

to update a record in database you should follow the structure update tblName set colName = colVal where col2Name = col2Val
for ex: update students set name = Ahmed where id = 1

---------------------------------------------Truncate------------------------------------------------------------

to delete a table but keep it's structure you use truncate by this syntax : truncate from tblNAme

----------------------------------------------Drop---------------------------------------------------------------

to drop table use "drop table tblName" for ex: drop table students

------------------------------------------------ALter------------------------------------------------------------

to modify table structure use Alter by typing alter table tblName add colName datatype
or you can use alter table tblName drop column colName 
