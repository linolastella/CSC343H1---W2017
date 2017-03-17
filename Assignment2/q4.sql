-- Grader report

SET SEARCH_PATH TO markus;


DROP TABLE IF EXISTS q4;

-- You must not change this table definition.

CREATE TABLE q4 ( assignment_id integer, username varchar(25),
                  num_marked integer, num_not_marked integer, min_mark real, max_mark real);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)

DROP VIEW IF EXISTS grader_assignment CASCADE;


DROP VIEW IF EXISTS assignment_and_max CASCADE;

-- Define views for your intermediate steps here.

CREATE VIEW assignment_and_max AS
SELECT assignment_id,
       SUM(out_of * weight) AS max_mark
FROM ASSIGNMENT NATURAL
LEFT JOIN RubricItem
GROUP BY assignment_id;


CREATE VIEW grader_assignment AS
SELECT username,
       assignment_id,
       Grader.group_id
FROM Grader
NATURAL JOIN AssignmentGroup;

-- Final answer.

INSERT INTO q4 

    (SELECT assignment_id,
            username,
            COUNT(Result.group_id),
            COUNT(grader_assignment.group_id) - COUNT(Result.group_id),
            MIN(mark * 100 / max_mark),
            MAX(mark * 100 / max_mark)
     FROM (assignment_and_max
           NATURAL JOIN grader_assignment)
     LEFT JOIN RESULT ON Result.group_id = grader_assignment.group_id
     GROUP BY username,
              assignment_id);
