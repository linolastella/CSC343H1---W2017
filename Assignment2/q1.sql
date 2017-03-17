-- Distributions

SET search_path TO markus;


DROP TABLE IF EXISTS q1;

-- You must not change this table definition.

CREATE TABLE q1 ( assignment_id integer, average_mark_percent real,
	num_80_100 integer, num_60_79 integer, num_50_59 integer, num_0_49 integer);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)

DROP VIEW IF EXISTS assignment_marks CASCADE;


DROP VIEW IF EXISTS group_marks CASCADE;

-- Define views for your intermediate steps here.

CREATE VIEW group_marks AS
SELECT group_id,
       Grade.rubric_id,
       assignment_id,
       out_of,
       weight,
       grade
FROM RubricItem
CROSS JOIN Grade
WHERE RubricItem.rubric_id = Grade.rubric_id;


CREATE VIEW assignment_marks AS
SELECT assignment_id,
       group_id,
       SUM(grade * weight) * 100/SUM(out_of * weight) AS percentage
FROM group_marks NATURAL
FULL JOIN ASSIGNMENT
GROUP BY assignment_id,
         group_id;

-- Final answer.

INSERT INTO q1

    (SELECT assignment_id,
            AVG(percentage),
            SUM(CASE
                    WHEN percentage >= 80 THEN 1
                    ELSE 0
                END),
            SUM(CASE
                    WHEN percentage >= 60
                         AND percentage < 80 THEN 1
                    ELSE 0
                END),
            SUM(CASE
                    WHEN percentage >= 50
                         AND percentage < 60 THEN 1
                    ELSE 0
                END),
            SUM(CASE
                    WHEN percentage < 50 THEN 1
                    ELSE 0
                END)
     FROM assignment_marks
     GROUP BY assignment_id);
