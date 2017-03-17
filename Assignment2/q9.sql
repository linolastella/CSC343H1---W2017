-- Inseparable

SET SEARCH_PATH TO markus;


DROP TABLE IF EXISTS q9;

-- You must not change this table definition.

CREATE TABLE q9 ( student1 varchar(25),
                           student2 varchar(25));


DROP VIEW IF EXISTS GroupAssignments CASCADE;


DROP VIEW IF EXISTS GroupAsgs CASCADE;


DROP VIEW IF EXISTS GroupAsgPairs CASCADE;


DROP VIEW IF EXISTS Students CASCADE;


DROP VIEW IF EXISTS GroupAsgShouldPairs CASCADE;


DROP VIEW IF EXISTS NotAlwaysPaired CASCADE;


DROP VIEW IF EXISTS Buddies CASCADE;


-- Filter Assignments for those that allow groups of 2 or more and get a tuple
-- for each username for each group
CREATE VIEW GroupAsgs AS
SELECT Assignment.assignment_id AS assignment_id,
       Membership.group_id AS group_id,
       username AS student1
FROM ASSIGNMENT,
     AssignmentGroup,
     Membership
WHERE Assignment.assignment_id = AssignmentGroup.assignment_id
    AND AssignmentGroup.group_id=Membership.group_id
    AND group_max > 1;

-- tuples of pairs of students who worked together on an assignment
CREATE VIEW GroupAsgPairs AS
SELECT GroupAsgs.assignment_id AS assignment_id,
       GroupAsgs.group_id AS group_id,
       GroupAsgs.student1 AS student1,
       GroupAsgs2.student1 AS student2
FROM GroupAsgs,
     GroupAsgs AS GroupAsgs2
WHERE GroupAsgs.group_id=GroupAsgs2.group_id
    AND GroupAsgs.student1<GroupAsgs2.student1; -- get just the usernames of students who worked in a group project

CREATE VIEW Students AS
SELECT DISTINCT student1 AS student2
FROM GroupAsgs;

-- all the tuples that SHOULD exist if all the students from GroupAsgs paired
-- up with everyone else on every group assignment
CREATE VIEW GroupAsgShouldPairs AS
SELECT assignment_id,
       group_id,
       student1,
       student2
FROM GroupAsgs,
     Students
WHERE student1 < student2;

-- all the students who were not paired at least once for a group assignment
CREATE VIEW NotAlwaysPaired AS
SELECT *
FROM GroupAsgShouldPairs
EXCEPT
SELECT *
FROM GroupAsgPairs;

-- pairs of students who worked together on every group assignment
CREATE VIEW Buddies AS
SELECT DISTINCT student1,
                student2
FROM GroupAsgPairs
EXCEPT
SELECT student1,
       student2
FROM NotAlwaysPaired;

-- Final answer

INSERT INTO q9
SELECT *
FROM Buddies;
