-- Solo superior

SET SEARCH_PATH TO markus;


DROP TABLE IF EXISTS q3;

-- You must not change this table definition.

CREATE TABLE q3 ( assignment_id integer, description varchar(100),
                 num_solo integer, average_solo real, num_collaborators integer,
				 average_collaborators real, average_students_per_submission real);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)

DROP VIEW IF EXISTS non_solo_marks CASCADE;


DROP VIEW IF EXISTS non_solo_groups CASCADE;


DROP VIEW IF EXISTS solo_marks CASCADE;


DROP VIEW IF EXISTS solo_groups CASCADE;


DROP VIEW IF EXISTS assignment_and_max CASCADE;

-- Define views for your intermediate steps here.

CREATE VIEW assignment_and_max AS
SELECT assignment_id,
       SUM(out_of * weight) AS max_mark
FROM ASSIGNMENT NATURAL
LEFT JOIN RubricItem
GROUP BY assignment_id;


CREATE VIEW solo_groups AS
SELECT group_id,
       assignment_id
FROM AssignmentGroup
NATURAL JOIN (
                  (SELECT DISTINCT group_id
                   FROM Membership)
              EXCEPT
                  (SELECT DISTINCT M1.group_id
                   FROM Membership M1
                   INNER JOIN Membership M2 ON M1.group_id = M2.group_id
                   AND M1.username <> M2.username)) Solos;


CREATE VIEW solo_marks AS
SELECT solo_groups.group_id,
       solo_groups.assignment_id,
       mark * 100 / max_mark AS percentage
FROM solo_groups
CROSS JOIN assignment_and_max
CROSS JOIN RESULT
WHERE solo_groups.group_id = Result.group_id
    AND solo_groups.assignment_id = assignment_and_max.assignment_id;


CREATE VIEW non_solo_groups AS
SELECT group_id,
       assignment_id,
       COUNT(username) AS num_students
FROM Membership
NATURAL JOIN (
                  (SELECT group_id,
                          assignment_id
                   FROM AssignmentGroup)
              EXCEPT
                  (SELECT *
                   FROM solo_groups)) Non_solos
GROUP BY group_id,
         assignment_id;


CREATE VIEW non_solo_marks AS
SELECT non_solo_groups.group_id,
       non_solo_groups.assignment_id,
       mark * 100 / max_mark AS percentage,
       num_students
FROM non_solo_groups
CROSS JOIN assignment_and_max
CROSS JOIN RESULT
WHERE non_solo_groups.group_id = Result.group_id
    AND non_solo_groups.assignment_id = assignment_and_max.assignment_id;

-- Final answer.

INSERT INTO q3 

    (SELECT Solos.assignment_id,
            description,
            num_solo,
            average_solo,
            num_collaborators,
            average_collaborators,
            (num_solo + num_collaborators) / (num_solo + num_proper_groups)
     FROM
         (SELECT Assignment.assignment_id,
                 description,
                 count(group_id) AS num_solo,
                 avg(percentage) AS average_solo
          FROM solo_marks
          FULL JOIN ASSIGNMENT ON Assignment.assignment_id = solo_marks.assignment_id
          GROUP BY Assignment.assignment_id) Solos
     FULL JOIN
         (SELECT Assignment.assignment_id,
                 COUNT(group_id) AS num_proper_groups,
                 COALESCE(SUM(num_students), 0) AS num_collaborators,
                 AVG(percentage) AS average_collaborators
          FROM non_solo_marks
          FULL JOIN ASSIGNMENT ON Assignment.assignment_id = non_solo_marks.assignment_id
          GROUP BY Assignment.assignment_id) Non_solos ON Solos.assignment_id = Non_solos.assignment_id);
