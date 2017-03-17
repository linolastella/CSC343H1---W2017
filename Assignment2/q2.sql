-- Getting soft

SET SEARCH_PATH TO markus;


DROP TABLE IF EXISTS q2;

-- You must not change this table definition.

CREATE TABLE q2 ( ta_name varchar(100),
                          average_mark_all_assignments real, mark_change_first_last real);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)

DROP VIEW IF EXISTS tired_grader CASCADE;


DROP VIEW IF EXISTS grader_average CASCADE;


DROP VIEW IF EXISTS num_students CASCADE;


DROP VIEW IF EXISTS grading_info CASCADE;


DROP VIEW IF EXISTS assignment_and_max CASCADE;


DROP VIEW IF EXISTS graded_at_least_ten CASCADE;


DROP VIEW IF EXISTS graded_every_assignment CASCADE;

-- Define views for your intermediate steps here.

CREATE VIEW graded_every_assignment AS
SELECT username
FROM
    (SELECT DISTINCT username,
                     assignment_id
     FROM Grader
     NATURAL JOIN AssignmentGroup) Groups_graded
GROUP BY username
HAVING COUNT(assignment_id) =
    (SELECT COUNT(*)
     FROM ASSIGNMENT);


CREATE VIEW graded_at_least_ten AS
SELECT username
FROM ASSIGNMENT
NATURAL JOIN
    (SELECT group_id,
            username,
            assignment_id
     FROM Grader
     NATURAL JOIN RESULT
     NATURAL JOIN AssignmentGroup) Groups_graded
GROUP BY username
HAVING COUNT(group_id) >= 10;


CREATE VIEW assignment_and_max AS
SELECT assignment_id,
       SUM(out_of * weight) AS max_mark,
       due_date
FROM ASSIGNMENT NATURAL
LEFT JOIN RubricItem
GROUP BY assignment_id;


CREATE VIEW grading_info AS
SELECT username,
       group_id,
       (100 * mark / max_mark) AS percent,
       assignment_id,
       due_date
FROM Grader
NATURAL JOIN RESULT
NATURAL JOIN AssignmentGroup
NATURAL JOIN assignment_and_max;


CREATE VIEW num_students AS
SELECT group_id,
       COUNT(username) AS students
FROM Membership
GROUP BY group_id;


CREATE VIEW grader_average AS
SELECT username,
       assignment_id,
       due_date,
       (SUM(percent * students) / SUM(students)) AS average
FROM grading_info
NATURAL JOIN num_students
GROUP BY username,
         assignment_id,
         due_date;


CREATE VIEW tired_grader AS
    (SELECT username
     FROM MarkusUser
     WHERE TYPE = 'TA')
EXCEPT
    (SELECT G1.username
     FROM grader_average G1
     CROSS JOIN grader_average G2
     WHERE G1.username = G2.username
         AND G1.due_date < G2.due_date
         AND G1.average >= G2.average);

-- Final answer.

INSERT INTO q2 

    (SELECT firstname || ' ' || surname,
            AVG(average),
            MAX(average) - MIN(average)
     FROM grader_average
     NATURAL JOIN MarkusUser
     NATURAL JOIN (
                       (SELECT *
                        FROM graded_every_assignment) INTERSECT
                       (SELECT *
                        FROM graded_at_least_ten) INTERSECT
                       (SELECT *
                        FROM tired_grader)) NAMES
     GROUP BY firstname,
              surname);
