create table stockssymbolsaddon
(
 SYMBOL char(16) not null primary key,
 COUNT number not null,
 FIRST number not null,
 LAST number not null
);

create table stocksdailyaddon
(
 SYMBOL char(16) not null,
 TIMESTAMP number not null,
 OPEN number not null,
 HIGH number not null,
 LOW number not null,
 CLOSE number not null,
 VOLUME number not null
);

create table users
(
 USERID varchar(32) not null primary key,
 PASSWORD varchar(32) not null,
 EMAIL varchar(64)
);

create table portfolios
(
 ID number not null primary key,
 NAME varchar(50) not null,
 CASH number not null,
 OWNER varchar(32),
 foreign key (OWNER) references users,
 CONSTRAINT combo_unique UNIQUE(NAME, OWNER)
);


create table holdings
(
 SYMBOL char(16) not null,
 PORTFOLIOID number not null,
 COUNT number not null,
 foreign key (PORTFOLIOID) references portfolios 
);


--increments portfolio id with each insert
CREATE SEQUENCE test_sequence
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER inc_id
BEFORE INSERT
ON portfolios
REFERENCING NEW AS NEW
FOR EACH ROW
BEGIN
SELECT test_sequence.nextval INTO :NEW.ID FROM dual;
END;
/

commit;