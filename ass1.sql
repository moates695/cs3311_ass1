-- comp3311 22T1 Assignment 1

-- Q1
-- students.id references people.id
-- program_enrolments.student references students.id

-- eliminate (student, program) pair duplicates
create or replace view distinctprograms(student) as
	select student from program_enrolments
	group by (student, program)
	having student in (select s.id from students as s)
;

-- group students to find number of distinct programs > 4
create or replace view nprograms(student, cnt) as
	select student, count(*) from distinctprograms
	group by student
	having count(*) > 4
;

-- link to unswid and name
create or replace view Q1(unswid, name) as
	select p.unswid, p.name from people as p
	where p.id in (select np.student from nprograms as np)
;

-- Q2
-- 'Course Tutor' in staff_roles.names
-- course_staff.role references staff_roles.id
-- course_staff.staff references staff.id
-- staff.id references people.id

-- find all tutor role ids
create or replace view tutor_ids(tutor_id) as
	select id from staff_roles
	where name = 'Course Tutor';
;

-- find all tutors with count
create or replace view course_tutors(staff, cnt) as
	select staff, count(*) from course_staff
	where role in (select * from tutor_ids)
	group by staff
;
	
-- find all tutors with max count
create or replace view max_tutors(staff, cnt) as
	select staff, cnt from course_tutors
	where cnt = (select max(cnt) from course_tutors)
;

-- link unswid, name and cnt
create or replace view Q2(unswid, name, course_cnt) as
	select p.unswid, p.name, mt.cnt from people as p
	inner join max_tutors as mt on p.id = mt.staff
;

-- Q3
-- 'intl' in students.stype
-- 'School of Law' in orgunits.name
-- subjects.offeredby references orgunits.id
-- course_enrolments.student references students.id
-- course_enrolments.course references courses.id
-- courses.subject references subjects.id  

-- find orgunit ids for School of Law
create or replace view law_ids(id) as
	select id from orgunits
	where name = 'School of Law'
;

-- find subjects offered by School of Law
create or replace view law_subjects(id) as 
	select s.id from subjects as s
	where s.offeredby in (select id from law_ids)
;

-- find course ids that are law subjects
create or replace view law_courses(id) as
	select c.id from courses as c
      	where c.subject in (select id from law_subjects)
;	

-- find all enrolments in law courses
create or replace view law_enrolments(student) as
	select ce.student from course_enrolments as ce
	where ce.course in (select id from law_courses)
	and ce.mark > 85
;

-- find international students ids
create or replace view intl_students(id) as
	select s.id from students as s
	where s.stype = 'intl'
;

-- link distinct international students and law courses
create or replace view law_enrolments_intl(student) as
	select distinct le.student from law_enrolments as le
	where le.student in (select id from intl_students)
;

-- link with unswid, name
create or replace view Q3(unswid, name) as
	select p.unswid, p.name from people as p
	where p.id in (select student from law_enrolments_intl)
;


-- Q4
-- 'local' in students.stype
-- courses.subject references subjects.id
-- course_enrolments.course regerences courses.id
-- course enrolments.student references students.id 

-- find course ids and terms for COMP9020
create or replace view course_COMP9020(id, term) as
	select c.id, c.term from courses as c
	where c.subject in (select id from subject_COMP9020)
;

-- find course ids and terms for COMP9331
create or replace view course_COMP9331(id, term) as
	select c.id, c.term from courses as c
	where c.subject in (select id from subject_COMP9331)
;

-- find all students and term enrolled in COMP9020
create or replace view enrolments_COMP9020(student, term) as
	select ce.student, cc.term from course_enrolments as ce
	inner join course_COMP9020 as cc on ce.course = cc.id
;

-- find all students and term enrolled in COMP9331
create or replace view enrolments_COMP9331(student, term) as
	select ce.student, cc.term from course_enrolments as ce
	inner join course_COMP9331 as cc on ce.course = cc.id
;

-- find students ernolled in both at same time
create or replace view enrolments_both(student) as
	select distinct e.student from enrolments_COMP9020 as e
	where (e.student, e.term) in (select student, term from enrolments_COMP9331)
;

-- find local students who are enrolled in both
create or replace view local_enrolments_both(id) as
	select s.id from students as s
	where s.id in (select student from enrolments_both)
	and s.stype = 'local'
;

-- link unswid and name to local students enrolled in both
create or replace view Q4(unswid, name) as
	select p.unswid, p.name from people as p
	where p.id in (select id from local_enrolments_both) 
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

