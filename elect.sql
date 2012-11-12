-- do a little math
select 1+1 as One_Plus_One from dual;

--
-- Political parties
--
create table parties (
  name        varchar(32) not null primary key,
  chairperson varchar(32) not null unique
);

--
-- Some parties
--
insert into parties (name,chairperson) values ('Democratic', 'Terry McAuliffe');
insert into parties (name,chairperson) values ('Republican', 'Ed Gillespie');
insert into parties (name,chairperson) values ('Green', 'Ralph Nader');
insert into parties (name,chairperson) values ('Independent', 'None');

-- Maybe we want a description too... a few weeks later
-- 
alter table parties add description varchar(32);

-- and update our data
update parties set description='Democratic National Committee' where name='Democratic';
update parties set description='Republican National Committee' where name='Republican';

--
-- Here's how we get our party names back
--
select name from parties;

--
-- Hmm. That might be useful enough to have a view
--
-- a view is basically a table that consists of a query
--
create view party_names as select name from parties;

--
-- then we can say
--
select * from party_names;



--
-- Offices to run for
--
create table offices (
  id          number not null primary key,
  name        varchar(32) not null,
  description varchar(32)
);

--
-- Let's make an office
--
insert into offices values (0, 'President','President of the United States');

--
-- Hmm maybe we ought to say where the offices are
--
--
alter table offices add state varchar(32);
alter table offices add county varchar(32);
alter table offices add city  varchar(32);
alter table offices add district number;
alter table offices add ward number;

--
-- OK, so now we can say something like
--
insert into offices (id, name,state) values (1,'Governor', 'California');
insert into offices (id, name,state,city) values (2,'Alderman', 'Illinois', 'Evanston');

--
-- Candidates are those people who are registered to run somewhere for something at sometime
--
create table candidates (
  ssn         number not null primary key,
  first_name  varchar(32) not null,
  last_name   varchar(32) not null,
    constraint unique_cand unique (first_name,last_name),
  party       varchar(32) not null references parties(name)
);


insert into candidates values (123456789, 'Ahnald', 'Schwarzenegger', 'Republican');
insert into candidates values (123456790, 'Gary', 'Coleman', 'Independent');
insert into candidates values (123456791, 'Cruz', 'Bustamante', 'Democratic');
insert into candidates values (123456792, 'Gray', 'Davis', 'Democratic');
insert into candidates values (123456793, 'George', 'Bush', 'Republican');
insert into candidates values (123456794, 'Howard', 'Dean', 'Democratic');
insert into candidates values (123456795, 'Wesley', 'Clark', 'Democratic');

--
-- The races.  A race is for a particular office in a particular year
--
create table races (
  raceid       number not null primary key,
  officeid     number not null references offices(id),
  year        number not null
);

--
-- Create some races
-- I'm using insert into ... select so that I can look up the office id by name
--
insert into races select 0, offices.id, 2004 from offices where offices.name='President';
insert into races select 1, offices.id, 2003 from offices where offices.name='Governor' and offices.state='California';


--
-- challengers are candidates who are competing in a race
--
create table challengers (
  raceid number       not null references races(raceid),
  candidatessn number not null references candidates(ssn)
);

--
-- Presidential race challengers
--
insert into challengers select 0, candidates.ssn from candidates where candidates.last_name='Bush' and candidates.first_name='George';
insert into challengers select 0, candidates.ssn from candidates where candidates.last_name='Clark' and candidates.first_name='Wesley';
insert into challengers select 0, candidates.ssn from candidates where candidates.last_name='Dean' and candidates.first_name='Howard';

--
-- California governor race challengers
--
insert into challengers select 1, candidates.ssn from candidates where candidates.last_name='Davis' and candidates.first_name='Gray';
insert into challengers select 1, candidates.ssn from candidates where candidates.last_name='Coleman' and candidates.first_name='Gary';
insert into challengers select 1, candidates.ssn from candidates where candidates.last_name='Bustamante' and candidates.first_name='Cruz';
insert into challengers select 1, candidates.ssn from candidates where candidates.last_name='Schwarzenegger' and candidates.first_name='Ahnald';


--
-- High level view of races
--
-- "distinct" means "unique"
--
create view race_summary as 
  select distinct offices.name as name, races.year as year, offices.state as state, offices.county as county, 
                  offices.city as city, offices.district, offices.ward 
  from offices, races 
  where offices.id=races.officeid;

--
-- A view of all the california recall candidates
--
-- This uses two features.  First, it does a three-way join 
-- (a cartesian product of the candidates, challengers, and races sets)
-- Second, it does a sub-select so that I can find the office id by name
create view california_recall_candidates as 
  select candidates.last_name, candidates.first_name, candidates.party 
  from candidates, challengers, races 
  where candidates.ssn=challengers.candidatessn and races.raceid=challengers.raceid and races.year=2003 
    and races.officeid in 
      (select id from offices where offices.name='Governor' and offices.state='California');


--
-- Each vote gets a unique number
--
-- This sequence supplies it.
--
create sequence vote_num start with 0 increment by 1
                minvalue 0 nocycle cache 1024 noorder;

--
-- All votes ever seen
-- A vote has a unique identifer, and is for a particular
-- candidate in a particular race
--
create table votes (
  id           number not null primary key,
  raceid       number not null references races(raceid),
  candidatessn number not null references candidates(ssn)
);

--
-- OK, now let's see all the tables we have created
--
select table_name from user_tables;

--
-- Make some votes for the recall election
--
-- a bunch of ahnald voters...
--
-- This syntax is basically so that I don't have to remember ssns, etc. 
-- Notice that the select does a two-way join.
insert into votes select vote_num.nextval, races.raceid, candidates.ssn from races, candidates where races.year=2003 and races.officeid in (select id from offices where offices.name='Governor' and offices.state='California') and candidates.ssn in (select ssn from candidates where last_name='Schwarzenegger');
insert into votes select vote_num.nextval, races.raceid, candidates.ssn from races, candidates where races.year=2003 and races.officeid in (select id from offices where offices.name='Governor' and offices.state='California') and candidates.ssn in (select ssn from candidates where last_name='Schwarzenegger');
insert into votes select vote_num.nextval, races.raceid, candidates.ssn from races, candidates where races.year=2003 and races.officeid in (select id from offices where offices.name='Governor' and offices.state='California') and candidates.ssn in (select ssn from candidates where last_name='Schwarzenegger');
insert into votes select vote_num.nextval, races.raceid, candidates.ssn from races, candidates where races.year=2003 and races.officeid in (select id from offices where offices.name='Governor' and offices.state='California') and candidates.ssn in (select ssn from candidates where last_name='Schwarzenegger');
insert into votes select vote_num.nextval, races.raceid, candidates.ssn from races, candidates where races.year=2003 and races.officeid in (select id from offices where offices.name='Governor' and offices.state='California') and candidates.ssn in (select ssn from candidates where last_name='Schwarzenegger');
insert into votes select vote_num.nextval, races.raceid, candidates.ssn from races, candidates where races.year=2003 and races.officeid in (select id from offices where offices.name='Governor' and offices.state='California') and candidates.ssn in (select ssn from candidates where last_name='Schwarzenegger');
insert into votes select vote_num.nextval, races.raceid, candidates.ssn from races, candidates where races.year=2003 and races.officeid in (select id from offices where offices.name='Governor' and offices.state='California') and candidates.ssn in (select ssn from candidates where last_name='Schwarzenegger');


-- a few bustamante voters
insert into votes select vote_num.nextval, races.raceid, candidates.ssn from races, candidates where races.year=2003 and races.officeid in (select id from offices where offices.name='Governor' and offices.state='California') and candidates.ssn in (select ssn from candidates where last_name='Bustamante');
insert into votes select vote_num.nextval, races.raceid, candidates.ssn from races, candidates where races.year=2003 and races.officeid in (select id from offices where offices.name='Governor' and offices.state='California') and candidates.ssn in (select ssn from candidates where last_name='Bustamante');
insert into votes select vote_num.nextval, races.raceid, candidates.ssn from races, candidates where races.year=2003 and races.officeid in (select id from offices where offices.name='Governor' and offices.state='California') and candidates.ssn in (select ssn from candidates where last_name='Bustamante');
insert into votes select vote_num.nextval, races.raceid, candidates.ssn from races, candidates where races.year=2003 and races.officeid in (select id from offices where offices.name='Governor' and offices.state='California') and candidates.ssn in (select ssn from candidates where last_name='Bustamante');

-- a coleman voter
insert into votes select vote_num.nextval, races.raceid, candidates.ssn from races, candidates where races.year=2003 and races.officeid in (select id from offices where offices.name='Governor' and offices.state='California') and candidates.ssn in (select ssn from candidates where last_name='Coleman');

-- davis voters
insert into votes select vote_num.nextval, races.raceid, candidates.ssn from races, candidates where races.year=2003 and races.officeid in (select id from offices where offices.name='Governor' and offices.state='California') and candidates.ssn in (select ssn from candidates where last_name='Davis');
insert into votes select vote_num.nextval, races.raceid, candidates.ssn from races, candidates where races.year=2003 and races.officeid in (select id from offices where offices.name='Governor' and offices.state='California') and candidates.ssn in (select ssn from candidates where last_name='Davis');
insert into votes select vote_num.nextval, races.raceid, candidates.ssn from races, candidates where races.year=2003 and races.officeid in (select id from offices where offices.name='Governor' and offices.state='California') and candidates.ssn in (select ssn from candidates where last_name='Davis');


-- See who is winning in the california race
--
-- This is kind of a complex query.  We join five tables, hunting for votes
-- cast in the california election in 2003.  Then we group those votes by
-- their candidates and their political parties, then we count the votes
-- in each of the groupings
select candidates.last_name as name, parties.name as party, count(*) 
from votes,races,challengers,candidates,parties 
where votes.raceid=races.raceid and votes.candidatessn=challengers.candidatessn and races.year=2003 
  and races.officeid in 
    (select id from offices where offices.name='Governor' and offices.state='California') 
  and challengers.raceid=races.raceid and candidates.ssn=challengers.candidatessn 
  and parties.name=candidates.party 
group by (candidates.last_name,parties.name);

-- 
-- finally, we delete all the things we had in the database
--

drop table votes;
drop sequence vote_num;
drop view california_recall_candidates;
drop view race_summary;
drop table challengers;
drop table races;
drop table candidates;
drop table offices;
drop view party_names;
drop table parties;

