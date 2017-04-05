DROP SCHEMA IF EXISTS job_search CASCADE;
CREATE SCHEMA job_search;
SET search_path TO job_search;

-- Count not enforce:
-- 1)

-- Additional constraint:
-- 1) There is only one student with given first name, last name and DOB.
-- 2) A student cannot have two degrees with the same name from the same
--    institution.
--    (e.g. two Bachelor of Art from U of T)
-- 3) An interviewer can assess one specific resume for a particular job
--    position only once.
--    (e.g. sID S001 can assess resume R001 for the position P001 only once)


-- Possible values of a required skill.
CREATE TYPE skill AS ENUM ('SQL', 'LaTeX', 'Python', 'R', 'Scheme');

-- Possible levels of a degree
CREATE TYPE degree_level AS ENUM ('certificate', 'undergraduate',
                                  'professional', 'masters', 'doctoral');

-- Possible values of a skill level and importance.
CREATE DOMAIN scaled_value AS smallint
    DEFAULT NULL
    CHECK (VALUE > 0 AND VALUE < 6);

-- Possible values of an assessment score.
CREATE DOMAIN score AS integer
    DEFAULT NULL
    CHECK (VALUE >= 0 AND VALUE <= 100);

-- Postings with related positions.
CREATE TABLE Postings (
    pID SERIAL PRIMARY KEY,
    position text NOT NULL
);

-- Details on particular questions.
CREATE TABLE Questions (
    qID SERIAL PRIMARY KEY,
    question text NOT NULL
);

-- Postings with related information on the skills required for the job.
CREATE TABLE PostingSkills (
    pID SERIAL REFERENCES Postings,
    required_skill skill,
    level scaled_value NOT NULL,
    importance scaled_value NOT NULL,
    PRIMARY KEY (pID, required_skill)
);

-- Questions an interviewer is encouraged to ask for a given job.
CREATE TABLE PostingQuestions (
    pID SERIAL REFERENCES Postings,
    qID SERIAL REFERENCES Questions,
    PRIMARY KEY (pID, qID)
);

-- Students' personal information.
CREATE TABLE Students (
    forename text,
    surname text,
    DOB date,
    citizenship text NOT NULL,
    address text NOT NULL,
    telephone text NOT NULL,
    email text NOT NULL,
    PRIMARY KEY (forename, surname, DOB)
);

-- Students' resumes.
CREATE TABLE Resumes (
    rID SERIAL PRIMARY KEY,
    summary text,
    forename text,
    surname text,
    DOB date,
    FOREIGN KEY (forename, surname, DOB) REFERENCES Students
);

-- A student's honorifics.
CREATE TABLE StudentHonorifics (
    rID SERIAL REFERENCES Resumes,
    honorific text,
    PRIMARY KEY (rID, honorific)
);

-- A student's titles.
CREATE TABLE StudentTitles (
    rID SERIAL REFERENCES Resumes,
    title text,
    PRIMARY KEY (rId, title)
);

-- A student's major.
CREATE TABLE Majors (
    rID SERIAL REFERENCES Resumes,
    major text,
    PRIMARY KEY (rID, major)
);

-- A student's minor.
CREATE TABLE Minors (
    rID SERIAL REFERENCES Resumes,
    minor text,
    PRIMARY KEY (rID, minor)
);

-- Information on a student's degree.
CREATE TABLE Degrees (
    rID SERIAL REFERENCES Resumes,
    degree_name text,
    institution text,
    honours text DEFAULT 'no',
    start_date date NOT NULL,
    end_date date NOT NULL,
    PRIMARY KEY (rID, degree_name, institution)
);

-- A student's working experience.
CREATE TABLE Experiences (
    rID SERIAL REFERENCES Resumes,
    title text,
    location text,
    description text,
    start_date date,
    end_date date,
    PRIMARY KEY (rID, title, location, start_date, end_date)
);

-- A student's technical skills.
CREATE TABLE StudentSkills (
    rID SERIAL REFERENCES Resumes,
    technical_skill skill,
    level scaled_value NOT NULL,
    PRIMARY KEY (rID, technical_skill)
);

-- Interviewer's personal information.
CREATE TABLE Interviewers (
    sID SERIAL PRIMARY KEY,
    forename text NOT NULL,
    surname text NOT NULL
);

-- An interviewer's honorifics.
CREATE TABLE InterviewerHonorifics (
    sID SERIAL REFERENCES Interviewers,
    honorifics text,
    PRIMARY KEY (sID, honorifics)
);

-- An interviewer's titles.
CREATE TABLE InterviewerTitles (
    sID SERIAL REFERENCES Interviewers,
    title text,
    PRIMARY KEY (sId, title)
);

-- Interviews details.
CREATE TABLE Interviews (
    rID SERIAL REFERENCES Resumes,
    pID SERIAL REFERENCES Postings,
    sID SERIAL REFERENCES Interviewers,
    date_and_time timestamp NOT NULL,
    location text NOT NULL,
    tech_proficiency score NOT NULL,
    communication score NOT NULL,
    enthusiasm score NOT NULL,
    collegiality score NOT NULL,
    PRIMARY KEY (rID, pID, sID)
);

-- Answers given on an interview.
CREATE TABLE Answers (
    rID SERIAL,
    pID SERIAL,
    sID SERIAL,
    qID SERIAL REFERENCES Questions,
    answer text NOT NULL,
    FOREIGN KEY (rID, pID, sID) REFERENCES Interviews,
    PRIMARY KEY (rID, pID, sID, qID)
);
