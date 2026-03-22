package com.charity.dao;

import com.charity.model.User;
import com.charity.util.DBConnection;
import org.mindrot.jbcrypt.BCrypt;
import java.sql.*;

/**
 UserDAO = Data Access Object for the users table.
 * This class acts as the bridge between the User model and the MySQL database.
 * It belongs to the Data Access Layer in the MVC architecture, meaning all
 * database logic related to users is centralised here rather than scattered
 * across servlets or JSP pages.

 * All queries use PreparedStatement to prevent SQL injection attacks.
 * Password verification uses BCrypt.checkpw() the plain text password
 */

public class UserDAO {

    /**
     * login() = Authenticates a user by username and password.

     * How it works:
     *   1. Fetches the user record from the users table by username only
     *      (never by password = we cannot query by a BCrypt hash)
     *   2. If a record is found, uses BCrypt.checkpw() to verify whether
     *      the entered plain text password matches the stored BCrypt hash
     *   3. If the password matches, builds and returns a User object
     *      containing the user's id, username, and role
     *   4. If the username does not exist or password is wrong, returns null

     * The returned User object is stored in the HttpSession by LoginServlet
     * so that all pages can identify who is logged in via:
     *   User user = (User) session.getAttribute("user");
     *
     * @param username  the username entered on the login form
     * @param password  the plain text password entered on the login form
     * @return          a User object if credentials are valid, null otherwise
     */
    public User login(String username, String password) {

        // null by default = returned as null if login fails
        User user = null;

        // Fetch user by username only, password comparison is done in Java
        // using BCrypt, NOT in SQL, because BCrypt hashes cannot be compared
        // with a simple SQL WHERE clause
        String sql = "SELECT * FROM users WHERE username = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            // Bind the username parameter to prevent SQL injection
            ps.setString(1, username);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                // Retrieve the stored BCrypt hash from the database
                String storedHash = rs.getString("password");

                // BCrypt.checkpw() re-hashes the entered password using the
                // same salt embedded in the stored hash and compares results.
                if (BCrypt.checkpw(password, storedHash)) {

                    // Password matched, build the User object
                    // Only store id, username, and role in session (not password)
                    user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setRole(rs.getString("role"));
                }
                // If BCrypt.checkpw() returns false, user remains null
                // meaning login will fail silently with an error message
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Returns a User object on success, or null on failure
        // LoginServlet checks: if (user == null) = show error message
        return user;
    }
}