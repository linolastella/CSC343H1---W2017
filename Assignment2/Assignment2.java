import java.sql.*;
import java.util.ArrayList;

public class Assignment2 {

    // A connection to the database
    Connection connection;

    Assignment2() throws SQLException {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    /**
     * Connects to the database and sets the search path.
     *
     * Establishes a connection to be used for this session, assigning it to the
     * instance variable 'connection'. In addition, sets the search path to
     * markus.
     *
     * @param url
     *            the url for the database
     * @param username
     *            the username to be used to connect to the database
     * @param password
     *            the password to be used to connect to the database
     * @return true if connecting is successful, false otherwise
     */
    public boolean connectDB(String URL, String username, String password) {
        try {
            connection = DriverManager.getConnection(URL, username, password);
            String queryString = "SET search_path TO markus";
            PreparedStatement ps = connection.prepareStatement(queryString);
            ps.execute();
            return true;

        } catch (SQLException se) {
            return false;
        }
    }

    /**
     * Closes the database connection.
     *
     * @return true if the closing was successful, false otherwise
     */
    public boolean disconnectDB() {
        try {
            connection.close();
            return true;
        } catch (SQLException se) {
            return false;
        }
    }

    /**
     * Assigns a grader for a group for an assignment.
     *
     * Returns false if the groupID does not exist in the AssignmentGroup table,
     * if some grader has already been assigned to the group, or if grader is
     * not either a TA or instructor.
     *
     * @param groupID
     *            id of the group
     * @param grader
     *            username of the grader
     * @return true if the operation was successful, false otherwise
     */
    public boolean assignGrader(int groupID, String grader) {
        try {
            String firstQuery = "SELECT COUNT(*) FROM MarkusUser " +
                                "WHERE username = ? AND type = 'student'";
            String secondQuery = "SELECT COUNT(*) FROM AssignmentGroup " +
                                 "WHERE group_id = ?";
            String thirdQuery = "SELECT COUNT(*) FROM Grader WHERE group_id = ?";

            PreparedStatement ps1 = connection.prepareStatement(firstQuery);
            PreparedStatement ps2 = connection.prepareStatement(secondQuery);
            PreparedStatement ps3 = connection.prepareStatement(thirdQuery);

            ps1.setString(1, grader);
            ps2.setInt(1, groupID);
            ps3.setInt(1, groupID);

            ResultSet rs1 = ps1.executeQuery();
            ResultSet rs2 = ps2.executeQuery();
            ResultSet rs3 = ps3.executeQuery();

            if (rs1.next() && rs2.next() && rs3.next()) {
                int isStudent = rs1.getInt("count");
                int validGroup = rs2.getInt("count");
                int graderAssigned = rs3.getInt("count");

                if (isStudent != 0 || validGroup != 1 || graderAssigned != 0) {
                    return false;
                }
            }

            String insertStatement = "INSERT INTO Grader VALUES (?, ?)";
            PreparedStatement ps = connection.prepareStatement(insertStatement);
            ps.setInt(1, groupID);
            ps.setString(2, grader);
            ps.executeUpdate();

            return true;

        } catch (SQLException se) {
            return false;
        }
    }

    /**
     * Adds a member to a group for an assignment.
     *
     * Records the fact that a new member is part of a group for an assignment.
     * Does nothing (but returns true) if the member is already declared to be
     * in the group.
     *
     * Does nothing and returns false if any of these conditions hold: - the
     * group is already at capacity, - newMember is not a valid username or is
     * not a student, - there is no assignment with this assignment ID, or - the
     * group ID has not been declared for the assignment.
     *
     * @param assignmentID
     *            id of the assignment
     * @param groupID
     *            id of the group to receive a new member
     * @param newMember
     *            username of the new member to be added to the group
     * @return true if the operation was successful, false otherwise
     */
    public boolean recordMember(int assignmentID, int groupID, String newMember) {
        PreparedStatement pStatement;
        ResultSet rs;
        String queryString;

        try {
            // heck if groupID already at capacity or not declared
            queryString =
            "SELECT space_left, assignment_id FROM " +
                "(SELECT group_max - COUNT(username) AS space_left, " +
                "assignment_id, group_id " +
                "FROM (Assignment NATURAL JOIN AssignmentGroup) " +
                                "NATURAL LEFT JOIN Membership " +
                "GROUP BY group_id, group_max, assignment_id) GroupSpace " +
                    "WHERE group_id = ? AND assignment_id = ?";

            pStatement = connection.prepareStatement(queryString);
            pStatement.setInt(1, groupID);
            pStatement.setInt(2, assignmentID);
            rs = pStatement.executeQuery();

            if (rs.next()) {
                int capacity = rs.getInt("space_left");
                if (capacity == 0) {
                    return false;
                }
            } else {
                // table is empty, so group not declared or assignment not valid
                return false;
            }

            // check newMember not valid or not a student
            queryString =
                "SELECT COUNT(*) FROM MarkusUser WHERE type = 'student' " +
                "AND username = ?";

            pStatement = connection.prepareStatement(queryString);
            pStatement.setString(1, newMember);
            rs = pStatement.executeQuery();

            if (rs.next()) {
                int isValid = rs.getInt("count");
                if (isValid != 1) {
                    return false;
                }
            }

            // passed every condition, the tuple (newMember, groupID) can be added
            queryString = "INSERT INTO Membership VALUES (?, ?)";
            pStatement = connection.prepareStatement(queryString);
            pStatement.setString(1, newMember);
            pStatement.setInt(2, groupID);
            pStatement.executeUpdate();
            return true;

        } catch (SQLException se) {
            return false;
        }
    }

    /**
     * Creates student groups for an assignment.
     *
     * Finds all students who are defined in the Users table and puts each of
     * them into a group for the assignment. Suppose there are n. Each group
     * will be of the maximum size allowed for the assignment (call that k),
     * except for possibly one group of smaller size if n is not divisible by k.
     * Note that k may be as low as 1.
     *
     * The choice of which students to put together is based on their grades on
     * another assignment, as recorded in table Results. Starting from the
     * highest grade on that other assignment, the top k students go into one
     * group, then the next k students go into the next, and so on. The last n %
     * k students form a smaller group.
     *
     * In the extreme case that there are no students, does nothing and returns
     * true.
     *
     * Students with no grade recorded for the other assignment come at the
     * bottom of the list, after students who received zero. When there is a tie
     * for grade (or non-grade) on the other assignment, takes students in order
     * by username, using alphabetical order from A to Z.
     *
     * When a group is created, its group ID is generated automatically because
     * the group_id attribute of table AssignmentGroup is of type SERIAL. The
     * value of attribute repo is repoPrefix + "/group_" + group_id
     *
     * Does nothing and returns false if there is no assignment with ID
     * assignmentToGroup or no assignment with ID otherAssignment, or if any
     * group has already been defined for this assignment.
     *
     * @param assignmentToGroup
     *            the assignment ID of the assignment for which groups are to be
     *            created
     * @param otherAssignment
     *            the assignment ID of the other assignment on which the
     *            grouping is to be based
     * @param repoPrefix
     *            the prefix of the URL for the group's repository
     * @return true if successful and false otherwise
     */
    public boolean createGroups(int assignmentToGroup, int otherAssignment,
            String repoPrefix) {

        PreparedStatement pStatement;
        ResultSet rs;
        String queryString;

        try {
            // exteme case: no students in the database
            pStatement = connection.prepareStatement(
                          "SELECT COUNT(*) FROM MarkusUser WHERE type = 'student'");
            rs = pStatement.executeQuery();

            if (rs.next()) {
                int numStudents = rs.getInt("count");
                if (numStudents == 0) {
                    return true;
                }
            }

            // check assignments exist and no groups have been created yet.
            // Observe that the number of groups declared to work on assignmentToGroup
            // must be 0 and the number of occurences of assignmentToGroup and
            // otherAssignment in the Assignment table must be 2. So their sum must be 2
            queryString =
                "SELECT count1 + count2 AS total FROM (SELECT COUNT(*) AS count1 " +
                  "FROM AssignmentGroup WHERE assignment_id = ?) NoGroups " +
                "CROSS JOIN (SELECT COUNT(*) AS count2 FROM Assignment " +
                  "WHERE assignment_id = ? OR assignment_id = ?) NumAssignments";

            pStatement = connection.prepareStatement(queryString);
            pStatement.setInt(1, assignmentToGroup);
            pStatement.setInt(2, assignmentToGroup);
            pStatement.setInt(3, otherAssignment);
            rs = pStatement.executeQuery();

            if (rs.next()) {
                int total = rs.getInt("total");
                if (total != 2) {
                    return false;
                }
            }

            // passed every test, implementation of the algorithm
            queryString =
                "SELECT username FROM (SELECT * FROM Result NATURAL JOIN " +
                                      "Membership NATURAL JOIN AssignmentGroup" +
                                      " WHERE assignment_id = ?) Students " +
                "NATURAL RIGHT JOIN MarkusUser WHERE type = 'student'" +
                "ORDER BY mark DESC NULLS LAST, username";
            pStatement = connection.prepareStatement(queryString);
            pStatement.setInt(1, otherAssignment);
            rs = pStatement.executeQuery();

            ArrayList<String> students = new ArrayList<String>();
            while (rs.next()) {
                String studentID = rs.getString("username");
                students.add(studentID);
            }

            pStatement = connection.prepareStatement(
                            "SELECT group_max FROM Assignment " +
                            "WHERE assignment_id = ?");
            pStatement.setInt(1, assignmentToGroup);
            rs = pStatement.executeQuery();
            int maxAllowed = 1;
            if (rs.next()) {
                maxAllowed = rs.getInt("group_max");
            }

            pStatement = connection.prepareStatement(
                            "SELECT MAX(group_id) FROM AssignmentGroup");
            rs = pStatement.executeQuery();
            int nextGroup = 0;
            if (rs.next()) {
                nextGroup = rs.getInt(1);
            }

            pStatement = connection.prepareStatement(
                            "SELECT setval('AssignmentGroup_group_id_seq', ?)");
            pStatement.setInt(1, nextGroup);
            pStatement.executeQuery();

            int i = 0;
            while (students.size() > i) {

                queryString = "INSERT INTO AssignmentGroup VALUES (?, ?, ?)";

                int groupNumber = getSerial();
                pStatement = connection.prepareStatement(queryString);
                pStatement.setInt(1, groupNumber);
                pStatement.setInt(2, assignmentToGroup);
                pStatement.setString(3, repoPrefix + "/group_" + groupNumber);
                pStatement.executeUpdate();

                if (students.size() <= maxAllowed) {
                    // make a group with all of them

                    while (students.size() != 0) {
                        queryString = "INSERT INTO Membership Values (?, ?)";

                        pStatement = connection.prepareStatement(queryString);
                        pStatement.setString(1, students.get(0));
                        pStatement.setInt(2, groupNumber);
                        pStatement.executeUpdate();

                        students.remove(0);
                    }

                } else {
                    // make a group with maxAllowed students

                    for (int j = 0; j < maxAllowed; j++) {

                        queryString = "INSERT INTO Membership Values (?, ?)";

                        pStatement = connection.prepareStatement(queryString);
                        pStatement.setString(1, students.get(0));
                        pStatement.setInt(2, groupNumber);
                        pStatement.executeUpdate();

                        students.remove(0);
                    }
                }
            }

            return true;

        } catch (SQLException se) {
            return false;
        }
    }

    /**
     * Helper method: return the next serial number for createGroups.
     *
     * @return correct serial number on success, 0 otherwise
     */
    private int getSerial() {
        try {
            int output = 0;
            PreparedStatement pStatement = connection.prepareStatement(
                "SELECT nextval('AssignmentGroup_group_id_seq')");
            ResultSet rs = pStatement.executeQuery();

            if (rs.next()) {
                output = rs.getInt(1);
            }
            return output;

        } catch (SQLException se) {
            return 0;
        }
    }

    public static void main(String[] args) {
        try {
            Assignment2 a2 = new Assignment2();

            a2.connectDB("jdbc:postgresql://localhost:5432/csc343h-lastell1", "lastell1", "");

            System.out.println(a2.assignGrader(2000, "t1")); // already assigned
            System.out.println(a2.assignGrader(2007, "s1")); // not a ta nor instructor
            System.out.println(a2.assignGrader(2011, "t1")); // not a group
            System.out.println(a2.assignGrader(2007, "t1")); // valid

            System.out.println(a2.recordMember(1000, 2000, "s3"));  // group already at capacity
            System.out.println(a2.recordMember(1001, 2001, "s30")); // not valid student
            System.out.println(a2.recordMember(1001, 2001, "i3"));  // not student type
            System.out.println(a2.recordMember(1111, 2000, "s3"));  // invalid assignment
            System.out.println(a2.recordMember(1000, 2001, "s1"));  // group not declared for a.
            System.out.println(a2.recordMember(1001, 2001, "s4"));  // valid

            a2.disconnectDB();

        } catch (SQLException se) {
            System.out.println("Boo!");
        }
    }
}
