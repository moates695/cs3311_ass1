-- comp3311 22T1 Assignment 1

---------------------------------------------------------------------
-- QUESTION 1
---------------------------------------------------------------------

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

---------------------------------------------------------------------
-- QUESTION 2
---------------------------------------------------------------------

-- find all tutor role ids
create or replace view tutor_ids(tutor_id) as
	select id from staff_roles
	where name = 'Course Tutor';
;

-- find all tutors and count
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

-- link to unswid and name
create or replace view Q2(unswid, name, course_cnt) as
	select p.unswid, p.name, mt.cnt from people as p
	inner join max_tutors as mt on p.id = mt.staff
;

---------------------------------------------------------------------
-- QUESTION 3
---------------------------------------------------------------------  

-- find orgunit ids for School of Law
create or replace view law_ids(id) as
	select id from orgunits
	where name = 'School of Law'
;

-- find course ids of all law subjects
create or replace view law_course(id) as
	select c.id from courses as c
	inner join subjects as s on c.subject = s.id
	inner join law_ids as li on s.offeredby = li.id
;

-- find all enrolments in law courses
create or replace view law_enrolments(student) as
	select ce.student from course_enrolments as ce
	where ce.course in (select id from law_courses)
	and ce.mark > 85
;

-- link distinct international students and law courses
create or replace view law_enrolments_intl(student) as
	select distinct le.student from law_enrolments as le
	where le.student in (select id from students where stype='intl')
;

-- link with unswid, name
create or replace view Q3(unswid, name) as
	select p.unswid, p.name from people as p
	where p.id in (select student from law_enrolments_intl)
;

---------------------------------------------------------------------
-- QUESTION 4
---------------------------------------------------------------------

-- find ids and terms for COMP9020
create or replace view subject_COMP9020(id) as
	select s.id from subjects as s
	where s.code = 'COMP9020'
;

-- find ids and terms for COMP9331
create or replace view subject_COMP9331(id) as
	select s.id from subjects as s
	where s.code = 'COMP9331'
;

-- find students enrolled in COMP9020 and the term
create or replace view enrolments_COMP9020(student, term) as
	select ce.student, c.term from courses as c
	inner join course_enrolments as ce on c.id = ce.course
	inner join subject_COMP9020 as s on c.subject = s.id
;

-- find students enrolled in COMP9331 and the term
create or replace view enrolments_COMP9331(student, term) as
	select ce.student, c.term from courses as c
	inner join course_enrolments as ce on c.id = ce.course
	inner join subject_COMP9331 as s on c.subject = s.id
;

-- find students enrolled in both at same time
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

-- link unswid and name
create or replace view Q4(unswid, name) as
	select p.unswid, p.name from people as p
	where p.id in (select id from local_enrolments_both) 
;

---------------------------------------------------------------------
-- QUESTION 5
---------------------------------------------------------------------

-- find subject ids for COMP3311
create or replace view subject_COMP3311(id) as
	select id from subjects
	where code = 'COMP3311'
;

-- find courses that are COMP3311 
create or replace view courses_COMP3311(id) as
	select id, term from courses
	where subject in (select id from subject_COMP3311)
;	

-- find not null mark enrolments in COMP3311
create or replace view enrolments_COMP3311(course, mark) as
	select ce.course, ce.mark from course_enrolments as ce
	where ce.course in (select id from courses_COMP3311)
	and ce.mark is not null
;	

-- find count of all marks per course
create or replace view all_COMP3311(course, cnt) as
	select course, count(*) from enrolments_COMP3311
	group by course
;

-- find courses with fail marks (omits courses with no fails
-- but this is rectified in combine_COMP3311)
create or replace view courses_with_fails(course) as
	select course from enrolments_COMP3311
	where mark < 50
;

-- find count of all fail marks per course
create or replace view fails_COMP3311(course, cnt) as
	select course, count(*) from courses_with_fails
	group by course
;

-- find fail rate for each course
create or replace view combine_COMP3311(course, rate) as
	select a.course,
	case
		when f.course is null then 1::numeric(5,4)
		else (f.cnt::float/a.cnt)::numeric(5,4)
	end
	from all_COMP3311 as a
	left outer join fails_COMP3311 as f on a.course = f.course
;

-- link with term
create or replace view term_rate(term, rate) as
	select c.term, com.rate from courses_COMP3311 as c
	inner join combine_COMP3311 as com on c.id = com.course
;

-- link with terms.name and filter years
create or replace view name_rate_a(term, rate) as
	select t.name, tr.rate from terms as t
	inner join term_rate as tr on t.id = tr.term
	where t.year >= 2009
	and t.year <= 2012
;

-- return all minimum fail rates
create or replace view Q5a(term, min_fail_rate) as
	select term, rate from name_rate_a
	where rate = (select min(rate) from name_rate_a)
;

-- link with terms.name and filter years
create or replace view name_rate_b(term, rate) as
	select t.name, tr.rate from terms as t
	inner join term_rate as tr on t.id = tr.term
	where t.year >= 2016
	and t.year <= 2019
;

-- return all minimum fail rates
create or replace view Q5b(term, min) as
	select term, rate from name_rate_b
	where rate = (select min(rate) from name_rate_b)
;

--------------------------------------------------------------------
--  QUESTION 6
---------------------------------------------------------------------

-- join id, code, mark together
create or replace view enrolments_codes(id, code, mark) as
	select p.id, s.code, ce.mark from course_enrolments as ce
	inner join courses as c on ce.course = c.id
	inner join subjects as s on c.subject= s.id
	inner join students as stu on ce.student = stu.id
	inner join people as p on stu.id = p.id
;

-- return students mark for the given course
create or replace function 
	Q6(id integer, code text) returns integer
as $$
	select mark from enrolments_codes
	where $1 = id
	and $2 = code
$$ language sql;

---------------------------------------------------------------------
-- QUESTION 7
---------------------------------------------------------------------

-- return all postgraduate COMP courses for the given period
create or replace function 
	Q7(year integer, session text) returns table (code text)
as $$
	select distinct s.code from terms as t
	inner join courses as c on t.id = c.term
	inner join subjects as s on c.subject = s.id
	where s.career = 'PG'
	and s.code like 'COMP%'
	and t.year = $1
	and t.session = $2
$$ language sql;

---------------------------------------------------------------------
-- QUESTION 8
--------------------------------------------------------------------

-- helper function, returns data needed for Q8 function
create or replace function
	q8_data(zid integer) returns table (term integer, mark integer, grade gradeType, uoc integer)
as $$
	select c.term, ce.mark, ce.grade, sub.uoc from course_enrolments as ce
	inner join students as stu on ce.student = stu.id
	inner join people as p on stu.id = p.id
	inner join courses as c on ce.course = c.id
	inner join subjects as sub on c.subject = sub.id
	where p.unswid = $1
	order by c.term
$$ language sql;

-- returns the academic transcript for a student defined by zid
create or replace function
	Q8(zid integer) returns setof TermTranscriptRecord
as $$
declare
	rec record;
	result TermTranscriptRecord;
	t integer := 0;
	t_cnt integer := 0;
	t_wsum integer := 0;
	t_pass_uoc integer := 0;
	t_all_uoc integer := 0;
	wsum integer := 0;
	pass_uoc integer := 0;
	all_uoc integer := 0;
begin
	for rec in
		select * from q8_data($1) 	
	loop
		if (t_cnt > 0 and t <> rec.term) then
			wsum := wsum + t_wsum;
			pass_uoc := pass_uoc + t_pass_uoc;
			all_uoc := all_uoc + t_all_uoc;

			result.term := cast(termName(t) as char(4));
			case
				when t_all_uoc = 0 then result.termwam := null;
				when t_wsum = 0 then result.termwam := null;
				else result.termwam := (t_wsum::float/t_all_uoc)::numeric(3,0);
			end case;
			case
				when t_pass_uoc = 0 then result.termuocpassed := null;
				else result.termuocpassed := t_pass_uoc;
			end case;
			return next result;

			t_wsum := 0;
			t_pass_uoc := 0;
			t_all_uoc := 0;
			t_cnt := 0;
		end if;
		if (rec.grade in ('SY','PT','PC','PS','CR','DN','HD','A','B','C','XE','T','PE','RC','RS')) then
			t_pass_uoc := t_pass_uoc + rec.uoc;
		end if;
		if (rec.mark is not null and rec.grade is not null) then
			t_wsum := t_wsum + (rec.mark * rec.uoc);
			t_all_uoc := t_all_uoc + rec.uoc;
		end if;
		t_cnt := t_cnt + 1;
		t := rec.term;
	end loop;
	if (t_cnt > 0) then
		wsum := wsum + t_wsum;
		pass_uoc := pass_uoc + t_pass_uoc;
		all_uoc := all_uoc + t_all_uoc;

		result.term := cast(termName(rec.term) as char(4));
		case
			when t_all_uoc = 0 then result.termwam := null;
			when t_wsum = 0 then result.termwam := null;
			else result.termwam := (t_wsum::float/t_all_uoc)::numeric(3,0);
		end case;
		case
			when t_pass_uoc = 0 then result.termuocpassed := null;
			else result.termuocpassed := t_pass_uoc;
		end case;
		return next result;

		result.term := 'OVAL';
		case
			when all_uoc = 0 then result.termwam := null;
			when wsum = 0 then result.termwam := null;
			else result.termwam := (wsum::float/all_uoc)::numeric(3,0);
		end case;
		case
			when pass_uoc = 0 then result.termuocpassed := null;
			else result.termuocpassed := pass_uoc;
		end case;
		return next result;
	end if;
	return;
end;
$$ language plpgsql;

---------------------------------------------------------------------
-- QUESTION 9
---------------------------------------------------------------------

-- find all subject, stream and program codes and ao_groups
create or replace view all_group_members(code, ao_group) as
	select s.code, sgm.ao_group from subject_group_members as sgm
	inner join subjects as s on sgm.subject = s.id
	union
	select s.code, sgm.ao_group from stream_group_members as sgm
	inner join streams as s on sgm.stream = s.id
	union
	select p.code, pgm.ao_group from program_group_members as pgm
	inner join programs as p on pgm.program = p.id
;

-- extract all subject, stream and program codes and their type
create or replace view all_codes(code, gtype) as
	select code, 'subject' from subjects
	union
	select code, 'stream' from streams
	union
	select code, 'program' from programs
;

-- return all members of the academic group defined by gid
create or replace function
	Q9(gid integer) returns setof AcObjRecord
as $$
declare
	rec record;
	result AcObjRecord;
	group_rec record;
	pattern text := '';
	num_patterns integer := 0;
	i integer;
	single text := '';
begin
	-- check that gid exists
	if (gid not in (select id from acad_object_groups)) then
		raise 'No such group %', $1;
	end if;
	-- retrive all patterns and enumerate groups
	for rec in
		select * from acad_object_groups
		where id = $1
	       	or parent = $1	
	loop
		if (rec.gdefby = 'query' or rec.negated = true or rec.definition like '%FREE%' or 
		    rec.definition like '%GEN%' or rec.definition like '%F=%') then
			continue;
		elsif (rec.gdefby = 'pattern') then
			pattern := pattern||','||rec.definition;
		else
			for group_rec in
				select * from all_group_members
				where ao_group = rec.id
			loop
				result.objtype := rec.gtype;
				result.objcode := group_rec.code;
				return next result;
			end loop;
		end if;
	end loop;
	-- return all objects matching a pattern
	select (char_length(pattern)-char_length(replace(pattern,',','')))
	into num_patterns;
	for i in 1..(num_patterns + 1) loop
		select split_part(pattern, ',', i) 
		into single;
		single := '('||replace(
			       replace(
			       replace(
			       replace(
			       replace(single,
				       '#','_'),
				       '{',''),
				       '}',''),
				       ';','|'),
				       ',','|')||')';
		if (single like '%#%' or single like '%[%' or single like '%_%') then
			for rec in
				select * from all_codes
				where code similar to single
			loop
				result.objtype := rec.gtype;
				result.objcode := rec.code;
				return next result;
			end loop;
		else
			continue;
		end if;
	end loop;
	--for rec in
	--	select * from all_codes
	--	where code similar to '('||replace(
	--				   replace(
	--				   replace(
	--				   replace(
	--				   replace(pattern,
	--					   '#','_'),
	--					   '{',''),
	--					   '}',''),
	--					   ';','|'),
	--					   ',','|')||')'
	--	loop
	--	result.objtype := rec.gtype;
	--	result.objcode := rec.code;
	--	return next result;
	--end loop;
	--return;
end;
$$ language plpgsql;

---------------------------------------------------------------------
-- QUESTION 10
---------------------------------------------------------------------

create or replace view prereqs(aog_id, subjcode, definition) as
	select aog.id, s.code, aog.definition from subject_prereqs as sp
	inner join rules as r on sp.rule = r.id
	inner join acad_object_groups as aog on r.ao_group = aog.id
	inner join subjects as s on sp.subject = s.id
;

create or replace view code_members(code, ao_group) as
	select s.code, sgm.ao_group from subject_group_members as sgm
	inner join subjects as s on sgm.subject = s.id
;

create or replace function
	Q10(code text) returns setof text
as $$
declare
	rec record;
	result text;
	sub_rec record;
begin
	for rec in
		select * from prereqs
		where code similar to '('||replace(definition,',','|')||')'
	loop
		result := rec.subjcode;
		return next result;
		for sub_rec in
			select * from code_members
			where ao_group = rec.aog_id
		loop
			result := sub_rec.code;
			return next result;
		end loop;
	end loop;
end;
$$ language plpgsql;

