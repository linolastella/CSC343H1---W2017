-- Never solo by choice

SET SEARCH_PATH TO markus;


DROP TABLE IF EXISTS q8;

-- You must not change this table definition.

CREATE TABLE q8 ( username varchar(25),
                           group_average real, solo_average real);


DROP VIEW IF EXISTS Submitters CASCADE;


DROP VIEW IF EXISTS GroupStudents CASCADE;


DROP VIEW IF EXISTS NotSolo CASCADE;


DROP VIEW IF EXISTS Solo CASCADE;


DROP VIEW IF EXISTS NeverSolo CASCADE;


DROP VIEW IF EXISTS OutOf CASCADE;


DROP VIEW IF EXISTS GroupAve CASCADE;


DROP VIEW IF EXISTS SoloAve CASCADE;


DROP VIEW IF EXISTS Answer CASCADE;


-- students who submitted a file for every assignment they worked on
CREATE VIEW Submitters AS
SELECT username
FROM Membership
EXCEPT
SELECT username
FROM
    (SELECT username,
            group_id
     FROM Membership
     EXCEPT SELECT username,
                   group_id
     FROM Submissions) Skippers;

-- each tuple is a student  who worked on a group assignment;
-- a tuple for each seperate group assignment that student worked in
CREATE VIEW GroupStudents AS
SELECT AssignmentGroup.group_id AS group_id,
       username
FROM ASSIGNMENT,
     AssignmentGroup,
     Membership
WHERE Assignment.assignment_id=AssignmentGroup.assignment_id
    AND group_max > 1
    AND AssignmentGroup.group_id=Membership.group_id;

-- student from GroupStudents who worked with at least one other person on a group assignment
CREATE VIEW NotSolo AS
SELECT GS1.group_id AS group_id,
       GS1.username AS username
FROM GroupStudents AS GS1,
     GroupStudents AS GS2
WHERE GS1.group_id = GS2.group_id
    AND GS1.username <> GS2.username;

-- GroupStudents who worked solo on an assignment that allowed groups
CREATE VIEW Solo AS
SELECT *
FROM GroupStudents
EXCEPT
SELECT *
FROM NotSolo;

-- student who never worked solo when able to work in group and contributed to group
CREATE VIEW NeverSolo AS
SELECT DISTINCT Submitters.username
FROM
    (SELECT username
     FROM GroupStudents
     EXCEPT SELECT username
     FROM Solo) NeverAlone,
     Submitters
WHERE NeverAlone.username = Submitters.username;

-- Total mark each assignment is out of
CREATE VIEW OutOf AS
SELECT assignment_id,
       SUM (out_of*weight) AS total
FROM RubricItem
GROUP BY assignment_id;

-- average mark of each NeverSolo from all group assignments
CREATE VIEW GroupAve AS
SELECT NS.username AS username,
       avg(mark/total) AS group_average
FROM NeverSolo AS NS,
     Membership AS Mem,
     AssignmentGroup AS AG,
     ASSIGNMENT AS Ast,
                   OutOf,
                   RESULT
WHERE NS.username = Mem.username
    AND Mem.group_id = AG.group_id
    AND AG.assignment_id = Ast.assignment_id
    AND group_max > 1
    AND AG.assignment_id = OutOf.assignment_id
    AND AG.group_id = Result.group_id
GROUP BY NS.username ;

-- average mark of each NeverSolo from all non-group assignments
-- no tuple for student if never did any non-group assignments
CREATE VIEW SoloAve AS
SELECT NS.username AS username,
       avg(mark/total) AS solo_average
FROM NeverSolo AS NS,
     Membership AS Mem,
     AssignmentGroup AS AG,
     ASSIGNMENT AS Ast,
                   OutOf,
                   RESULT
WHERE NS.username = Mem.username
    AND Mem.group_id = AG.group_id
    AND AG.assignment_id = Ast.assignment_id
    AND group_max = 1
    AND AG.assignment_id = OutOf.assignment_id
    AND AG.group_id = Result.group_id
GROUP BY NS.username ;

-- combine table of group and non-group assignment averages for
-- NeverSolos
-- solo_average is NULL if doesn't exist for a student
CREATE VIEW Answer AS
SELECT GA.username AS username,
       group_average,
       solo_average
FROM GroupAve AS GA
LEFT JOIN SoloAve AS SA ON GA.username = SA.username;

-- Final answer

INSERT INTO q8
SELECT *
FROM Answer;
