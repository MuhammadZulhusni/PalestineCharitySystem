package com.charity.dao;

import com.charity.model.User;
import com.charity.util.DBConnection;
import org.mindrot.jbcrypt.BCrypt;
import java.sql.*;

/**
 * UserDAO — Data Access Object for the users table.
 *
 * This class acts as the bridge between the User model and the MySQL database.
 * It belongs to the Data Access Layer in the MVC architecture, meaning all
 * database logic related to users is centralised here rather than scattered
 * across servlets or JSP pages.
 *
 * All queries use PreparedStatement to prevent SQL injection attacks.
 * Password and security answer verification uses BCrypt.checkpw() —
 * plain text values are NEVER compared directly against the database.
 *
 * Methods:
 *   - login()                  → verifies credentials, returns User object
 *   - getSecurityQuestion()    → fetches security question for forgot password Step 1
 *   - verifyAndResetPassword() → verifies answer and updates password for Step 2
 */
public class UserDAO {

    /**
     * login() — Authenticates a user by username and password.
     *
     * How it works:
     *   1. Fetches the user record from users table by username only
     *      (never by password — BCrypt hashes cannot be queried with WHERE)
     *   2. Uses BCrypt.checkpw() to verify entered password against stored hash
     *   3. If match → builds and returns a User object stored in HttpSession
     *   4. If no match or username not found → returns null
     *
     * The returned User object is stored in session by LoginServlet:
     *   session.setAttribute("user", user)
     * Every protected page then reads it:
     *   User user = (User) session.getAttribute("user")
     *
     * @param username  plain text username from login form
     * @param password  plain text password from login form
     * @return          User object if credentials valid, null otherwise
     */
    public User login(String username, String password) {

        // null by default — returned as null if login fails
        User user = null;

        // Fetch by username only — password checked in Java, not SQL
        String sql = "SELECT * FROM users WHERE username = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                // Retrieve stored BCrypt hash from database
                String storedHash = rs.getString("password");

                // BCrypt.checkpw() re-hashes the input using the salt
                // embedded in the stored hash, then compares the results
                if (BCrypt.checkpw(password, storedHash)) {

                    // Password matched — build User object
                    // Only store id, username, role in session (never password)
                    user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setRole(rs.getString("role"));
                }
                // If BCrypt.checkpw() returns false, user stays null → login fails
            }
            // If rs.next() is false, username not found → user stays null

        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Returns User on success, null on failure
        // LoginServlet checks: if (user == null) → redirect with ?error=1
        return user;
    }

    /**
     * getSecurityQuestion() — Retrieves the security question for a username.
     *
     * Called by ForgotPasswordServlet Step 1 after receiving the username.
     * The returned question key (e.g. "pet", "city") is passed as a URL
     * parameter to forgot_password.jsp Step 2, where it is mapped to
     * the full question text using questionMap.
     *
     * Returns null if the username does not exist in the database,
     * which causes ForgotPasswordServlet to redirect with ?error=notfound.
     *
     * @param username  the username entered on forgot_password.jsp Step 1
     * @return          security question key if found, null if not found
     */
    public String getSecurityQuestion(String username) {
        String sql = "SELECT security_question FROM users WHERE username = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username.trim());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("security_question");
        } catch (SQLException e) {
            e.printStackTrace();
        }
        // Returns null if username not found
        return null;
    }

    /**
     * verifyAndResetPassword() — Verifies security answer and updates password.
     *
     * Called by ForgotPasswordServlet Step 2 after all input validation passes.
     *
     * How it works:
     *   1. Fetches stored BCrypt hashed security answer from DB by username
     *   2. Uses BCrypt.checkpw() to verify the entered answer
     *      (answer is lowercased before comparison — case-insensitive)
     *   3. If answer is correct → hashes new password with BCrypt.hashpw()
     *      and runs UPDATE users SET password = ? WHERE username = ?
     *   4. Returns a status string so ForgotPasswordServlet can redirect correctly
     *
     * Return values:
     *   "ok"          = answer correct, password updated successfully
     *   "wronganswer" = BCrypt.checkpw() returned false
     *   "notfound"    = username does not exist in database
     *   "database"    = SQLException occurred during update
     *
     * @param username     the username whose password is being reset
     * @param answer       the plain text answer (already lowercased by servlet)
     * @param newPassword  the new plain text password to hash and save
     * @return             status string used by ForgotPasswordServlet for redirect
     */
    public String verifyAndResetPassword(String username, String answer, String newPassword) {

        // ── Step 1: Fetch stored BCrypt hashed answer from DB ────────
        String storedAnswer = null;
        String sqlGet = "SELECT security_answer FROM users WHERE username = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlGet)) {
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                storedAnswer = rs.getString("security_answer");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return "database";
        }

        // Username not found in database
        if (storedAnswer == null) return "notfound";

        // ── Step 2: Verify answer using BCrypt ───────────────────────
        // answer is already lowercased by ForgotPasswordServlet before calling this
        if (!BCrypt.checkpw(answer, storedAnswer)) return "wronganswer";

        // ── Step 3: Hash new password and update in database ─────────
        String newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt(12));
        String sqlUp = "UPDATE users SET password = ? WHERE username = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlUp)) {
            ps.setString(1, newHash);
            ps.setString(2, username);
            ps.executeUpdate();
            return "ok"; // Password updated successfully
        } catch (SQLException e) {
            e.printStackTrace();
            return "database";
        }
    }
}