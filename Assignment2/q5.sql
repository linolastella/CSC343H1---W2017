-- Uneven workloads

SET SEARCH_PATH TO markus;


DROP TABLE IF EXISTS q5;

-- You must not change this table definition.

CREATE TABLE q5 ( assignment_id integer, username varchar(25),
                                                  num_assigned integer);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)

DROP VIEW IF EXISTS assignment_range CASCADE;


DROP VIEW IF EXISTS grader_assignment CASCADE;

-- Define views for your intermediate steps here.

CREATE VIEW grader_assignment AS
SELECT assignment_id,
       username,
       COUNT(Grader.group_id) AS num_assigned
FROM Grader
NATURAL JOIN AssignmentGroup
GROUP BY username,
         assignment_id;


CREATE VIEW assignment_range AS
SELECT assignment_id
FROM
    (SELECT assignment_id,
            MAX(num_assigned) - MIN(num_assigned) AS range
     FROM grader_assignment
     GROUP BY assignment_id) Ranges
WHERE range > 10;

-- Final answer.

INSERT INTO q5 

    (SELECT assignment_id,
            username,
            num_assigned
     FROM grader_assignment
     NATURAL JOIN assignment_range);
