package com.charity.dao;

import com.charity.model.User;
import com.charity.util.DBConnection;
import org.mindrot.jbcrypt.BCrypt;
import java.sql.*;

/**
 * UserDAO, User Data Access Object
 * This class handles ALL database tasks related to the users table.
 *
 * Think of it as the "middleman" between the servlet and the database:
 *   Servlet  to  calls UserDAO  to  UserDAO talks to MySQL  to  returns result
 *
 * Security rules applied in this class:
 *    PreparedStatement   = prevents SQL Injection on every query
 *    BCrypt.checkpw()    = passwords are NEVER compared as plain text
 *    BCrypt.hashpw()     = new passwords are always hashed before saving
 *
 * Methods in this class:
 *   1. login()                  = check username & password, return User or null
 *   2. getSecurityQuestion()    = get security question by username (Forgot Password Step 1)
 *   3. verifyAndResetPassword() = verify answer & save new password  (Forgot Password Step 2)
 */
public class UserDAO {

    // METHOD 1: login()
    // PURPOSE : Checks if the username and password entered are correct.
    //           Returns a User object if valid, or null if invalid.
    // CALLED BY: LoginServlet = after user submits the login form
    public User login(String username, String password) {

        // STEP 1 : Start with null.
        //          If login fails at any point, null is returned automatically.
        User user = null;

        // STEP 2 : Prepare the SQL query.
        //          We only search by USERNAME here.
        //          We do NOT put the password inside the SQL query because
        //          BCrypt passwords are hashed, cannot be matched with WHERE.
        String sql = "SELECT * FROM users WHERE username = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            // STEP 3 : Insert the username into the SQL query safely
            //          using PreparedStatement (prevents SQL Injection).
            ps.setString(1, username);

            // STEP 4 : Run the query and get the result.
            ResultSet rs = ps.executeQuery();

            // STEP 5 : Check if a row was found for that username.
            if (rs.next()) {

                // STEP 6 : Retrieve the hashed password stored in the database.
                //          This is a BCrypt hash, e.g: "$2a$12$abc123..."
                String storedHash = rs.getString("password");

                // STEP 7 : Use BCrypt to verify the password.
                //          BCrypt.checkpw() takes the plain text password the user typed
                //          and the stored hash from the database, then compares them.
                //          It does NOT decrypt, it re-hashes and compares.
                if (BCrypt.checkpw(password, storedHash)) {

                    // STEP 8 : Password is correct! Build the User object.
                    //          We store id, username, and role in the session.
                    user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setRole(rs.getString("role"));
                }
                // If BCrypt.checkpw() returns false, password was wrong, user stays null
            }
            // If rs.next() is false, username was not found, user stays null

        } catch (SQLException e) {
            e.printStackTrace();
            // If a database error occurs = user stays null
        }

        // STEP 9 : Return the result.
        //          LoginServlet checks:
        //            if (user != null) = login success & save user in session
        //            if (user == null) = login failed  & redirect with ?error=1
        return user;
    }


    // METHOD 2: getSecurityQuestion()
    // PURPOSE : Looks up the security question for a given username.
    //           Used in "Forgot Password" — Step 1.
    // CALLED BY: ForgotPasswordServlet, after user enters their username
    public String getSecurityQuestion(String username) {

        // STEP 1 : Prepare the SQL query.
        //          We only need the security_question column for this username.
        String sql = "SELECT security_question FROM users WHERE username = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            // STEP 2 : Insert the username safely using PreparedStatement.
            //          .trim() removes any accidental spaces the user may have typed.
            ps.setString(1, username.trim());

            // STEP 3 : Run the query.
            ResultSet rs = ps.executeQuery();

            // STEP 4 : If a row is found, return the security question key.
            //          Example values: "pet", "city", "mother"
            //          The JSP (forgot_password.jsp) maps this key to a full question text.
            if (rs.next()) return rs.getString("security_question");

        } catch (SQLException e) {
            e.printStackTrace();
        }

        // STEP 5 : If username was not found, return null.
        //          ForgotPasswordServlet checks:
        //            if (question == null) = redirect with ?error=notfound
        return null;
    }


    // METHOD 3: verifyAndResetPassword()
    // PURPOSE : Verifies the user's security answer, then resets their password.
    //           Used in "Forgot Password"  Step 2.
    // CALLED BY: ForgotPasswordServlet, after user submits the answer & new password
    //
    // RETURN VALUES (used by ForgotPasswordServlet to decide the redirect):
    //   "ok"          = success, password was updated
    //   "wronganswer" = security answer was incorrect
    //   "notfound"    = username does not exist in database
    //   "database"    = a database error occurred
    // ════════════════════════════════════════════════════════════════════════
    public String verifyAndResetPassword(String username, String answer, String newPassword) {

        // STEP 1: Fetch the stored (hashed) security answer from the database ──
        String storedAnswer = null;
        String sqlGet = "SELECT security_answer FROM users WHERE username = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlGet)) {

            // Insert username safely into the query
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();

            // If a row exists, grab the hashed security answer
            if (rs.next()) {
                storedAnswer = rs.getString("security_answer");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            // Database error during fetch = return "database"
            return "database";
        }

        // STEP 2: Check if the username actually exists
        //    If storedAnswer is still null, no row was found for that username.
        if (storedAnswer == null) return "notfound";

        // STEP 3: Verify the security answer using BCrypt
        //    The answer was already lowercased by ForgotPasswordServlet before
        //    calling this method (case-insensitive comparison).
        //    BCrypt.checkpw() compares the plain text answer with the stored hash.
        if (!BCrypt.checkpw(answer, storedAnswer)) return "wronganswer";

        // STEP 4: Hash the new password and save it to the database
        //    BCrypt.gensalt(12) generates a random salt with cost factor 12.
        //    BCrypt.hashpw() combines the new password + salt into a secure hash.
        String newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt(12));

        String sqlUp = "UPDATE users SET password = ? WHERE username = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlUp)) {

            // Set the new hashed password and the target username
            ps.setString(1, newHash);
            ps.setString(2, username);

            // Run the UPDATE query
            ps.executeUpdate();

            // STEP 5: Return "ok" to signal success
            //    ForgotPasswordServlet will redirect to login page with success message.
            return "ok";

        } catch (SQLException e) {
            e.printStackTrace();
            // Database error during update, return "database"
            return "database";
        }
    }
}