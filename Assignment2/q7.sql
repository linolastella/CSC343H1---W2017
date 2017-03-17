-- High coverage

SET SEARCH_PATH TO markus;


DROP TABLE IF EXISTS q7;

-- You must not change this table definition.

CREATE TABLE q7 (ta varchar(100));


DROP VIEW IF EXISTS EveryAsg CASCADE;


DROP VIEW IF EXISTS ActualAsgs CASCADE;


DROP VIEW IF EXISTS AssignmentCover CASCADE;


DROP VIEW IF EXISTS ShouldGrade CASCADE;


DROP VIEW IF EXISTS DidGrade CASCADE;


DROP VIEW IF EXISTS HighCover CASCADE;

-- every grading ta crossed with every assignemnt that he or she SHOULD have marked
-- one or more group in
CREATE VIEW EveryAsg AS
SELECT DISTINCT username AS ta,
                assignment_id
FROM Grader,
     ASSIGNMENT;

-- tuple for each ta and assignment that he or she actually marked
CREATE VIEW ActualAsgs AS
SELECT DISTINCT username AS ta,
                AssignmentGroup.assignment_id AS assignment_id
FROM Grader
JOIN AssignmentGroup ON Grader.group_id = AssignmentGroup.group_id;

-- TA who marked a group for every assignment
CREATE VIEW AssignmentCover AS
SELECT ta
FROM ActualAsgs
EXCEPT
SELECT ta
FROM
    (SELECT *
     FROM EveryAsg
     EXCEPT SELECT *
     FROM ActualAsgs) NotEvery;

-- tuples for every AssignmentCover grader crossed with every student on the
-- system that they SHOULD have graded to be High Cover
CREATE VIEW ShouldGrade AS
SELECT ta,
       MarkusUser.username AS student
FROM AssignmentCover,
     MarkusUser
WHERE MarkusUser.type = 'student';

-- grader and a student he or she DID grade
CREATE VIEW DidGrade AS
SELECT ta,
       Membership.username AS student
FROM Grader
JOIN Membership ON Grader.group_id = Membership.group_id,
                   AssignmentCover
WHERE Grader.username = AssignmentCover.ta;

-- TAs who graded every student and for each assignment graded at least one group
CREATE VIEW HighCover AS
SELECT ta
FROM DidGrade
EXCEPT
SELECT ta
FROM
    (SELECT *
     FROM ShouldGrade
     EXCEPT SELECT *
     FROM DidGrade) NotHigh;

-- Final answer
INSERT INTO q7
    (SELECT *
     FROM HighCover);
