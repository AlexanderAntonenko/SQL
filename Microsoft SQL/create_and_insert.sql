CREATE SEQUENCE sq_ai_table
START WITH 1 
INCREMENT BY 1 
NOMAXVALUE;

CREATE TABLE game (
idgame INTEGER NOT NULL,
GDate DATE NOT NULL,
Gtime CHAR (6) NOT NULL,
title VARCHAR2(40),
number_of_races INTEGER NOT NULL,
place INTEGER CONSTRAINT check_place
CHECK (place BETWEEN 0 and 12)
);

ALTER TABLE game ADD CONSTRAINT game_pk PRIMARY KEY ( idgame );

CREATE TABLE horse (
idhorse INTEGER NOT NULL,
nickname VARCHAR2(40) NOT NULL,
HDate DATE NOT NULL,
owner_idowner INTEGER,
jockey_idjockey INTEGER,
gender VARCHAR2(8) CONSTRAINT check_gender
CHECK (gender IN ('M', 'V'))
);

ALTER TABLE horse ADD CONSTRAINT horse_pk PRIMARY KEY ( idhorse );

CREATE TABLE jockey (
idjockey INTEGER NOT NULL,
name VARCHAR2(40) NOT NULL,
address VARCHAR2 (40) NOT NULL,
weight INTEGER CONSTRAINT check_weight
CHECK (weight BETWEEN 0 and 120),
height INTEGER CONSTRAINT check_height
CHECK (height BETWEEN 0 and 200),
JDate DATE NOT NULL
);

ALTER TABLE jockey ADD CONSTRAINT jockey_pk PRIMARY KEY ( idjockey );

CREATE TABLE ownerr (
idowner INTEGER NOT NULL,
name VARCHAR2(40) NOT NULL,
address VARCHAR2 (40) NOT NULL
);

ALTER TABLE ownerr ADD CONSTRAINT owner_pk PRIMARY KEY ( idowner );

CREATE TABLE runn (
horse_position INTEGER CONSTRAINT check_h_pos
CHECK (horse_position BETWEEN 1 and 12),
horse_idhorse INTEGER NOT NULL,
game_idgame INTEGER NOT NULL
);

ALTER TABLE runn ADD CONSTRAINT runn_pk PRIMARY KEY ( horse_idhorse,game_idgame );

ALTER TABLE horse
ADD CONSTRAINT horse_jockey_fk FOREIGN KEY ( jockey_idjockey )
REFERENCES jockey ( idjockey );

ALTER TABLE horse
ADD CONSTRAINT horse_owner_fk FOREIGN KEY ( owner_idowner )
REFERENCES ownerr ( idowner );

ALTER TABLE runn
ADD CONSTRAINT runn_game_fk FOREIGN KEY ( game_idgame )
REFERENCES game ( idgame );

ALTER TABLE runn
ADD CONSTRAINT runn_horse_fk FOREIGN KEY ( horse_idhorse )
REFERENCES horse ( idhorse );


INSERT INTO jockey VALUES
(1002, 'SMITH', 'aaa', 75, 175, to_date('28.10.1999','dd-mm-yyyy'));
INSERT INTO jockey VALUES
(1003, 'Misha', 'bbb', 80, 180, to_date('28.10.1997','dd-mm-yyyy'));
INSERT INTO jockey VALUES
(1004, 'Sasha', 'ccc', 70, 185, to_date('28.10.1995','dd-mm-yyyy'));

INSERT INTO ownerr VALUES
(1001, 'Nikita', 'ccc');

INSERT INTO horse VALUES
(sq_ai_table.NEXTVAL, 'A', to_date('28.10.2008','dd-mm-yyyy'), 1001, 1002, 'M');
INSERT INTO horse VALUES
(sq_ai_table.NEXTVAL, 'B', to_date('28.10.2010','dd-mm-yyyy'), 1001, 1003, 'M');
INSERT INTO horse VALUES
(sq_ai_table.NEXTVAL, 'C', to_date('28.10.2012','dd-mm-yyyy'), 1001, 1004, 'V');

INSERT INTO game VALUES
(2000, to_date('28.10.2019','dd-mm-yyyy'), '17.00', 'AB', 3, 10);

INSERT INTO runn VALUES
(1, 1, 2000);
INSERT INTO runn VALUES
(2, 2, 2000);
INSERT INTO runn VALUES
(3, 3, 2000);

CREATE INDEX horse_id ON horse(idhorse);