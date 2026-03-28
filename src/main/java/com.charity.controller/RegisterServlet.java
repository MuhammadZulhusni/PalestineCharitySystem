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
import java.sql.SQLException;

/**
 * This servlet handles new user registration for donors.
 * It validates input, hashes password and security answer,
 * then inserts the user into the database.
 */
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get form input values
        String username        = request.getParameter("username");
        String password        = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String secQuestion     = request.getParameter("securityQuestion");
        String secAnswer       = request.getParameter("securityAnswer");

        // Validate required fields
        if (username == null || username.trim().isEmpty() ||
                password == null || confirmPassword == null ||
                secQuestion == null || secAnswer == null || secAnswer.trim().isEmpty()) {
            response.sendRedirect("register.jsp?error=1"); // missing input
            return;
        }

        // Check password confirmation
        if (!password.equals(confirmPassword)) {
            response.sendRedirect("register.jsp?error=mismatch");
            return;
        }

        // Validate password strength
        if (password.length() < 8 ||
                !password.matches(".*[A-Z].*") ||
                !password.matches(".*[a-z].*") ||
                !password.matches(".*\\d.*") ||
                !password.matches(".*[^a-zA-Z0-9].*")) {
            response.sendRedirect("register.jsp?error=weak");
            return;
        }

        // Hash password and security answer
        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(12));
        String hashedAnswer   = BCrypt.hashpw(secAnswer.trim().toLowerCase(), BCrypt.gensalt(12));

        // SQL query to insert new donor user
        String sql = "INSERT INTO users (username, password, role, security_question, security_answer) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username.trim());
            ps.setString(2, hashedPassword);
            ps.setString(3, "DONOR"); // default role
            ps.setString(4, secQuestion);
            ps.setString(5, hashedAnswer);

            int rows = ps.executeUpdate();

            if (rows > 0) {
                response.sendRedirect("login.jsp?msg=registered"); // registration successful
            } else {
                response.sendRedirect("register.jsp?error=1"); // failed to insert
            }

        } catch (SQLException e) {
            e.printStackTrace();

            // Handle duplicate username
            if (e.getMessage().toLowerCase().contains("duplicate") ||
                    e.getMessage().toLowerCase().contains("unique")) {
                response.sendRedirect("register.jsp?error=taken"); // username taken
            } else {
                response.sendRedirect("register.jsp?error=database"); // other DB error
            }
        }
    }
}