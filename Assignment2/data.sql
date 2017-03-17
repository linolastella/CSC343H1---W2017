-- If there is already any data in these tables, empty it out.

TRUNCATE TABLE Result CASCADE;
TRUNCATE TABLE Grade CASCADE;
TRUNCATE TABLE RubricItem CASCADE;
TRUNCATE TABLE Grader CASCADE;
TRUNCATE TABLE Submissions CASCADE;
TRUNCATE TABLE Membership CASCADE;
TRUNCATE TABLE AssignmentGroup CASCADE;
TRUNCATE TABLE Required CASCADE;
TRUNCATE TABLE Assignment CASCADE;
TRUNCATE TABLE MarkusUser CASCADE;


-- Now insert data from scratch.

INSERT INTO MarkusUser VALUES ('i1', 'iln1', 'ifn1', 'instructor'),
                              ('t1', 'tln1', 'tfn1', 'TA'),
                              ('t2', 'tln2', 'tfn2', 'TA'),
                              ('t3', 'tln3', 'tfn3', 'TA'),
                              ('t4', 'tln4', 'tfn4', 'TA'),
                              ('t5', 'tln5', 'tfn5', 'TA'),
                              ('s1', 'sln1', 'sfn1', 'student'),
                              ('s2', 'sln2', 'sfn2', 'student'),
                              ('s3', 'sln3', 'sfn3', 'student'),
                              ('s4', 'sln4', 'sfn4', 'student'),
                              ('s5', 'sln5', 'sfn5', 'student'),
                              ('s6', 'sln6', 'sfn6', 'student'),
                              ('s7', 'sln7', 'sfn7', 'student'),
                              ('s8', 'sln8', 'sfn8', 'student'),
                              ('s9', 'sln9', 'sfn9', 'student'),
                              ('s10', 'sln10', 'sfn10', 'student'),
                              ('s11', 'sln11', 'sfn11', 'student');
;


INSERT INTO Assignment VALUES (1000, 'A1', '2017-02-08 20:00', 1, 2),
                              (1001, 'A2', '2017-03-11 20:00', 1, 5),
                              (1002, 'A3', '2017-04-04 20:00', 1, 2);

INSERT INTO Required VALUES (1000, 'A1.pdf'),
                            (1001, 'A2.pdf'),
                            (1002, 'A3.pdf');

INSERT INTO AssignmentGroup VALUES (2000, 1000, 'repo1_url'),
                                   (2001, 1001, 'repo2_url'),
                                   (2002, 1000, 'repo3_url'),
                                   (2003, 1002, 'repo4_url'),
                                   (2004, 1000, 'repo5_url'),
                                   (2005, 1002, 'repo6_url'),
                                   (2006, 1000, 'repo7_url'),
                                   (2007, 1002, 'repo8_url'),
                                   (2008, 1001, 'repo9_url'),
                                   (2009, 1002, 'repo10_url'),
                                   (2010, 1001, 'repo11_url'),
                                   (2011, 1002, 'repo11_url'),
                                   (2012, 1002, 'repo12_url'),
                                   (2013, 1002, 'repo13_url'),
                                   (2014, 1000, 'repo14_url');

INSERT INTO Membership VALUES ('s1', 2000),
                              ('s2', 2000),
                              ('s3', 2001),
                              ('s4', 2002),
                              ('s5', 2002),
                              ('s6', 2003),
                              ('s7', 2004),
                              ('s1', 2005),
                              ('s3', 2006),
                              ('s2', 2007),
                              ('s1', 2008),
                              ('s2', 2008),
                              ('s5', 2008),
                              ('s4', 2008),
                              ('s5', 2009),
                              ('s7', 2009),
                              ('s7', 2010),
                              ('s3', 2011),
                              ('s4', 2011),
                              ('s8', 2012),
                              ('s9', 2012),
                              ('s10', 2013),
                              ('s11', 2013),
                              ('s6', 2014),
                              ('s8', 2014);

INSERT INTO Submissions VALUES (3000, 'A1.pdf', 's1', 2000, '2017-02-01 10:53'),
                               (3001, 'A2.pdf', 's3', 2001, '2017-03-03 02:20'),
                               (3002, 'A1.pdf', 's4', 2002, '2017-01-29 23:11'),
                               (3003, 'A3.pdf', 's6', 2003, '2017-03-28 12:00'),
                               (3004, 'A1.pdf', 's7', 2004, '2017-02-08 19:59'),
                               (3005, 'A3.pdf', 's1', 2005, '2017-04-01 22:01'),
                               (3006, 'A1.pdf', 's3', 2006, '2017-01-25 20:51'),
                               (3007, 'A3.pdf', 's2', 2007, '2017-03-25 10:49'),
                               (3008, 'A2.pdf', 's1', 2008, '2017-03-03 03:20'),
                               (3009, 'A3.pdf', 's5', 2009, '2017-04-01 12:51'),
                               (3010, 'A2.pdf', 's7', 2010, '2017-03-03 13:20'),
                               (3011, 'A3.pdf', 's3', 2011, '2017-04-01 22:02'),
                               (3012, 'A3.pdf', 's8', 2012, '2017-04-01 23:23'),
                               (3013, 'A3.pdf', 's11', 2013, '2017-04-01 13:03'),
                               (3014, 'A1.pdf', 's2', 2000, '2017-02-01 10:52');

INSERT INTO Grader VALUES (2000, 't1'),
                          (2001, 't1'),
                          (2002, 't5'),
                          (2003, 't3'),
                          (2004, 't2'),
                          (2005, 't5'),
                          (2006, 't1'),
                          (2007, 't1'),
                          (2008, 't1'),
                          (2009, 't1'),
                          (2010, 't2'),
                          (2011, 't1'),
                          (2012, 't1'),
                          (2013, 't1'),
                          (2014, 't3');

INSERT INTO RubricItem VALUES (4000, 1000, 'style', 4, 0.25),
                              (4001, 1000, 'tester', 12, 0.75),
                              (4002, 1001, 'style', 4, 0.25),
                              (4003, 1001, 'tester', 10, 0.75),
                              (4004, 1002, 'correctness', 100, 1);

INSERT INTO Grade VALUES (2000, 4000, 3),
                         (2000, 4001, 9),
                         (2001, 4002, 2),
                         (2001, 4003, 8),
                         (2002, 4000, 4),
                         (2002, 4001, 12),
                         (2004, 4000, 1),
                         (2004, 4001, 10),
                         (2006, 4000, 0),
                         (2006, 4001, 0),
                         (2005, 4004, 0),
                         (2007, 4004, 51),
                         (2008, 4002, 0),
                         (2008, 4003, 10),
                         (2009, 4004, 69.7),
                         (2010, 4002, 3),
                         (2010, 4003, 6.5),
                         (2011, 4004, 100),
                         (2012, 4004, 100),
                         (2013, 4004, 100);

INSERT INTO Result VALUES (2000, 7.5, true),
                          (2001, 6.5, true),
                          (2002, 10, true),
                          (2004, 7.75, true),
                          (2005, 0.0, true),
                          (2006, 0.0, true),
                          (2007, 51, true),
                          (2008, 7.5, true),
                          (2009, 69.7, true),
                          (2010, 5.625, true),
                          (2011, 100, true),
                          (2012, 100, true),
                          (2013, 100, true);
