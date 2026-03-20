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

public class AddUserServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String role     = request.getParameter("role");
        String sq       = request.getParameter("security_question");
        String sa       = request.getParameter("security_answer");

        if (username == null || password == null || role == null) {
            response.sendRedirect("admin_dashboard.jsp?msg=error&section=users");
            return;
        }

        if (!role.equals("ADMIN") && !role.equals("DONOR")) role = "DONOR";

        // default empty string if not provided
        if (sq == null) sq = "";
        if (sa == null) sa = "";

        try (Connection conn = DBConnection.getConnection()) {
            // Check if username already exists
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT id FROM users WHERE username = ?")) {
                ps.setString(1, username);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    response.sendRedirect("admin_dashboard.jsp?msg=user_exists&section=users");
                    return;
                }
            }
            // Hash password and security answer
            String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(12));
            String hashedAnswer   = sa.isEmpty() ? "" : BCrypt.hashpw(sa.toLowerCase().trim(), BCrypt.gensalt(12));

            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO users (username, password, role, security_question, security_answer) VALUES (?, ?, ?, ?, ?)")) {
                ps.setString(1, username);
                ps.setString(2, hashedPassword);
                ps.setString(3, role);
                ps.setString(4, sq);
                ps.setString(5, hashedAnswer);
                ps.executeUpdate();
            }
            response.sendRedirect("admin_dashboard.jsp?msg=user_added&section=users");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin_dashboard.jsp?msg=error&section=users");
        }
    }
}