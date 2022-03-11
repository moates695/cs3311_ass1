-- comp3311 22T1 Assignment 1

-- Q1
-- students.id references people.id
-- program_enrolments.student references students.id

create or replace view distinctprograms(student) as
	select student from program_enrolments
	group by (student, program)
	having student in (select s.id from students as s)
;

create or replace view nprograms(student, cnt) as
	select student, count(*) from distinctprograms
	group by student
	having count(*) > 4
;

create or replace view Q1(unswid, name) as
	select p.unswid, p.name from people as p
	where p.id in (select np.student from nprograms as np)
;

-- Q2
-- 'Course Tutor' in staff_roles.name
-- course_staff.course references courses.id
-- course_staff.role references staff_roles.id
-- course_staff.staff references staff.id
-- staff.id references people.id

create or replace view tutor_ids(tutor_id) as
	select id from staff_roles
	where name = 'Course Tutor';
;

create or replace view course_tutors(staff, cnt) as
	select staff, count(*) from course_staff
	where role in (select * from tutor_ids)
	group by staff
;
	
select staff from 

create or replace view Q2(unswid, name, course_cnt) as
	select
;


-- Q3
create or replace view Q3(unswid, name)
as
--... SQL statements, possibly using other views/functions defined by you ...
;


-- Q4
create or replace view Q4(unswid, name)
as
--... SQL statements, possibly using other views/functions defined by you ...
;


-- Q5a
create or replace view Q5a(term, min_fail_rate)
as
--... SQL statements, possibly using other views/functions defined by you ...
;


-- Q5b
create or replace view Q5b(term, min_fail_rate)
as
--... SQL statements, possibly using other views/functions defined by you ...
;


-- Q6
create or replace function 
	Q6(id integer,code text) returns integer
as $$
--... SQL statements, possibly using other views/functions defined by you ...
$$ language sql;


-- Q7
create or replace function 
	Q7(year integer, session text) returns table (code text)
as $$
--... SQL statements, possibly using other views/functions defined by you ...
$$ language sql;


-- Q8
create or replace function
	Q8(zid integer) returns setof TermTranscriptRecord
as $$
--... SQL statements, possibly using other views/functions defined by you ...
$$ language plpgsql;


-- Q9
create or replace function 
	Q9(gid integer) returns setof AcObjRecord
as $$
--... SQL statements, possibly using other views/functions defined by you ...
$$ language plpgsql;


-- Q10
create or replace function
	Q10(code text) returns setof text
as $$
--... SQL statements, possibly using other views/functions defined by you ...
$$ language plpgsql;

