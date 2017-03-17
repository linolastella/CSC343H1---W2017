-- Steady work

SET SEARCH_PATH TO markus;


DROP TABLE IF EXISTS q6;

-- You must not change this table definition.

CREATE TABLE q6 ( group_id integer, first_file varchar(25), first_time TIMESTAMP,
                  first_submitter varchar(25), last_file varchar(25), last_time TIMESTAMP,
                  last_submitter varchar(25), elapsed_time interval);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)

DROP VIEW IF EXISTS last_submissions CASCADE;


DROP VIEW IF EXISTS first_submissions CASCADE;


DROP VIEW IF EXISTS A1_groups CASCADE;

-- Define views for your intermediate steps here.

CREATE VIEW A1_groups AS
SELECT group_id
FROM ASSIGNMENT
NATURAL JOIN AssignmentGroup
WHERE description = 'A1';


CREATE VIEW first_submissions AS
SELECT group_id,
       file_name AS first_file,
       submission_date AS first_time,
       username AS first_submitter
FROM A1_groups NATURAL
LEFT JOIN Submissions S1
WHERE submission_date <= ALL
        (SELECT submission_date
         FROM Submissions S2
         WHERE S1.group_id = S2.group_id);


CREATE VIEW last_submissions AS
SELECT group_id,
       file_name AS last_file,
       submission_date AS last_time,
       username AS last_submitter
FROM A1_groups NATURAL
LEFT JOIN Submissions S1
WHERE submission_date >= ALL
        (SELECT submission_date
         FROM Submissions S2
         WHERE S1.group_id = S2.group_id);

-- Final answer.

INSERT INTO q6

    (SELECT group_id,
            first_file,
            first_time,
            first_submitter,
            last_file,
            last_time,
            last_submitter,
            AGE(last_time, first_time)
     FROM first_submissions NATURAL FULL JOIN last_submissions);
