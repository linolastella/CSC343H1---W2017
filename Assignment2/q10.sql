-- A1 report

SET SEARCH_PATH TO markus;


DROP TABLE IF EXISTS q10;

-- You must not change this table definition.

CREATE TABLE q10 ( group_id integer, mark real, compared_to_average real, status varchar(5));

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)

DROP VIEW IF EXISTS A1groups CASCADE;


DROP VIEW IF EXISTS A1Result CASCADE;


DROP VIEW IF EXISTS Average CASCADE;

DROP VIEW IF EXISTS Compare CASCADE;


DROP VIEW IF EXISTS A1Rubric CASCADE;


DROP VIEW IF EXISTS OutOf CASCADE;


DROP VIEW IF EXISTS A1id CASCADE;


-- get all group_id for A1
CREATE VIEW A1groups AS
SELECT group_id
FROM AssignmentGroup
JOIN ASSIGNMENT ON AssignmentGroup.assignment_id = Assignment.assignment_id
WHERE description = 'A1'
    OR description ='a1';

-- A1 id
CREATE VIEW A1id AS
SELECT DISTINCT assignment_id
FROM ASSIGNMENT
WHERE description = 'A1'
    OR description = 'a1';

-- get the weighted grades for each item in A1
CREATE VIEW A1Rubric AS
SELECT out_of*weight AS points
FROM RubricItem,
     A1id
WHERE RubricItem.assignment_id = A1id.assignment_id;

-- total marks assigment 1 is out of
CREATE VIEW OutOf AS
SELECT sum(points)AS total
FROM A1Rubric;

-- get all percentage marks for A1
CREATE VIEW A1Result AS
SELECT A1Groups.group_id AS group_id,
       mark/total AS perc_mark
FROM A1groups
LEFT JOIN RESULT ON Result.group_id=A1groups.group_id,
                    OutOf;

-- average of A1 marks
CREATE VIEW Average AS
SELECT avg(perc_mark) AS avmark
FROM A1Result;

-- filter Results table to have only the A1 groups and
-- also put in a (const) column for the average
CREATE VIEW Compare AS
SELECT group_id,
       perc_mark AS mark,
       perc_mark-avmark AS compared_to_average
FROM A1Result,
     Average;

-- Final answer.

INSERT INTO q10
SELECT DISTINCT group_id,
                mark,
                compared_to_average,
                CASE
                    WHEN compared_to_average IS NULL THEN NULL
                    WHEN compared_to_average > 0 THEN 'above'
                    WHEN compared_to_average < 0 THEN 'below'
                    ELSE 'at'
                END AS status
FROM Compare;
