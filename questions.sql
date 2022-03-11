create or replace view students_program_count(id, count) as
	select p.student, count(*) from program_enrolments as p
	where p.student in (select s.id from students as s)
	group by p.student
	having count(*) > 4;

create or replace view Q1(unswid, name) as
	select p.id, p.name from people as p
	where p.id in (select spc.id from students_program_count as spc); 
