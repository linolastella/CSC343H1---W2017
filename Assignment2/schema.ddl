DROP SCHEMA IF EXISTS markus CASCADE;
CREATE SCHEMA markus;
SET search_path TO markus;

-- The possible values of a user type
CREATE TYPE usertype AS ENUM ('instructor', 'TA', 'student');

-- A person who is registered as a MarkUs user. We store their cdf 
-- user name, last name (surname), first name, and user type.
CREATE TABLE MarkusUser (
  username varchar(25) PRIMARY KEY,
  surname varchar(15) NOT NULL,
  firstname varchar(15) NOT NULL,
  type usertype NOT NULL
);

-- The possible values of the number of members.
CREATE DOMAIN members AS smallint 
   DEFAULT NULL
   CHECK (VALUE > 0);

-- An assignment is a piece of work assigned to a student markus user. We store
-- a description of the assignment, the due date (and time) of the assignment, and
-- the minimum and maximum number of students allowed to work on the assignment.
CREATE TABLE Assignment (
  assignment_id integer PRIMARY KEY,
  description varchar(100) NOT NULL,
  due_date timestamp NOT NULL,
  group_min members NOT NULL,
  group_max members NOT NULL,
  CHECK (group_max >= group_min) 
) ;

-- A file that is required for an assignment submission. We store the expected
-- file name including the extension.
CREATE TABLE Required (
  assignment_id integer REFERENCES Assignment,
  file_name varchar(25),
  PRIMARY KEY (assignment_id, file_name)
) ;

-- A group represents a number of students working together on an assignment. 
-- We store the URL of the shared repository where their submitted files are
-- stored. 
CREATE TABLE AssignmentGroup (
  group_id SERIAL PRIMARY KEY,
  assignment_id integer REFERENCES Assignment,
  repo varchar(100) NOT NULL
) ;

-- A markus user is a member of a group. We store their username of the
-- A tuple in this relation represents that a user belongs to a group. userName 
-- is their cdf user name, and gID is the group to which they belong.
CREATE TABLE Membership (
  username varchar(25) REFERENCES MarkusUser,
  group_id integer REFERENCES AssignmentGroup,
  PRIMARY KEY (username, group_id)
) ;

-- A file that was submitted by a given group. We store the name of the file, 
-- the username of the student who submitted the file, and the date and time 
-- when the file was submitted. 
CREATE TABLE Submissions (
  submission_id integer PRIMARY KEY,
  file_name varchar(25) NOT NULL,
  username varchar(25) REFERENCES MarkusUser,
  group_id integer REFERENCES AssignmentGroup,
  submission_date timestamp NOT NULL,
  UNIQUE (file_name, username, submission_date)
) ;

-- For a given group id, username is the username of the TA or instructor 
-- assigned to grade them.
CREATE TABLE Grader (
  group_id integer PRIMARY KEY REFERENCES AssignmentGroup,
  username varchar(25) REFERENCES MarkusUser
) ;

-- An item in the grading rubric for an assignment. We store the name of the 
-- rubric item, the total possible marks for the item, and the weight of the 
-- item towards the overall grade for the assignment.  The weights for an 
-- assignment do not have to sum to any particular value.  However, a typical
-- scenario might be to have them sum to 100 or to 1.0.
CREATE TABLE RubricItem (
  rubric_id integer PRIMARY KEY,
  assignment_id integer NOT NULL REFERENCES Assignment,
  name varchar(50) NOT NULL,
  out_of integer NOT NULL,
  weight real NOT NULL,
  UNIQUE (assignment_id, name)
) ;

-- The grade for a given group on a given rubric item. 
CREATE TABLE Grade (
  group_id integer REFERENCES AssignmentGroup,
  rubric_id integer REFERENCES RubricItem,
  grade integer NOT NULL,
  PRIMARY KEY (group_id, rubric_id)
) ;


-- The total amount that an assignment is out of is the weighted sum of the
-- "out of" values for its individual rubric items.  For instance, if an
-- assignment is graded on correctness out of 10 with a weight of .75, and
-- style out of 4 with a weight of .25, then the whole assignment is out of
--      4 * .25 + 10 * .75 = 8.5
-- The "total mark" that a group earned on an assignment is the weighted sum
-- of its grades on the rubric items for that assignment.  For example, if
-- a group earned 8 on correctness (of the 10 that it was marked out of) and
-- 2 on style (of the 4 that it was marked out of), then their total mark is
--      2 * .25 + 8 * .75 = 6.5 (out of 8.5)
-- As a percentage, their grade is
--      6.5 / 8.5 * 100 = 76.47058823529412


-- The mark for a group on an assignment. We store the "total mark" (as 
-- defined above), not a percentage. We also store a boolean indicating whether
-- or not the result has been made available for the group members to see on 
-- Markus.
-- You may assume that if a group has a value for mark recorded in this table,
-- it was computed correctly from tables RubricItem and Grade, and is therefore
-- consistent with those tables.
CREATE TABLE Result (
  group_id integer PRIMARY KEY REFERENCES AssignmentGroup,
  mark real NOT NULL,
  released boolean DEFAULT false
) ;