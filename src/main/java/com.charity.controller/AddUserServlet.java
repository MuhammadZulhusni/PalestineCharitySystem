package com.charity.controller;

import com.charity.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.mindrot.jbcrypt.BCrypt;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * This servlet handles adding a new user by admin.
 * It gets user data from form, validates it, hashes password,
 * and saves the user into the database.
 */
public class AddUserServlet extends HttpServlet {

    // Handle request (using GET here)
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get input values from form
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String role     = request.getParameter("role");
        String sq       = request.getParameter("security_question");
        String sa       = request.getParameter("security_answer");

        // Check required fields (basic validation)
        if (username == null || password == null || role == null) {
            response.sendRedirect("admin_dashboard.jsp?msg=error&section=users");
            return;
        }

        // Allow only ADMIN or DONOR role (default = DONOR)
        if (!role.equals("ADMIN") && !role.equals("DONOR")) role = "DONOR";

        // If security question/answer not provided, set empty
        if (sq == null) sq = "";
        if (sa == null) sa = "";

        try (Connection conn = DBConnection.getConnection()) {

            // Check if username already exists
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT id FROM users WHERE username = ?")) {

                ps.setString(1, username);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    // Username already in DB
                    response.sendRedirect("admin_dashboard.jsp?msg=user_exists&section=users");
                    return;
                }
            }

            // Hash password and security answer for security
            String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(12));
            String hashedAnswer   = sa.isEmpty()
                    ? ""
                    : BCrypt.hashpw(sa.toLowerCase().trim(), BCrypt.gensalt(12));

            // Insert new user into database
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO users (username, password, role, security_question, security_answer) VALUES (?, ?, ?, ?, ?)")) {

                ps.setString(1, username);
                ps.setString(2, hashedPassword);
                ps.setString(3, role);
                ps.setString(4, sq);
                ps.setString(5, hashedAnswer);

                ps.executeUpdate();
            }

            // Redirect with success message
            response.sendRedirect("admin_dashboard.jsp?msg=user_added&section=users");

        } catch (Exception e) {
            // Print error and redirect if something goes wrong
            e.printStackTrace();
            response.sendRedirect("admin_dashboard.jsp?msg=error&section=users");
        }
    }
}