package com.charity.controller;

import com.charity.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.charity.model.User;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * This servlet handles deleting a user by admin.
 * It ensures security checks before deleting the user.
 */
public class DeleteUserServlet extends HttpServlet {

    // Handle request using GET method
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get user ID from request
        String idParam = request.getParameter("id");

        // If no ID provided, go back
        if (idParam == null) {
            response.sendRedirect("admin_dashboard.jsp?section=users");
            return;
        }

        // Check logged-in user (must be ADMIN)
        User sessionUser = (User) request.getSession().getAttribute("user");

        if (sessionUser == null || !"ADMIN".equals(sessionUser.getRole())) {
            // Not logged in or not admin = redirect to login
            response.sendRedirect("login.jsp");
            return;
        }

        int targetId = Integer.parseInt(idParam);

        try (Connection conn = DBConnection.getConnection()) {

            // Check target user is NOT the same as logged-in admin
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT username FROM users WHERE id = ?")) {

                ps.setInt(1, targetId);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    String targetUsername = rs.getString("username");

                    // Prevent admin from deleting themselves
                    if (targetUsername.equals(sessionUser.getUsername())) {
                        response.sendRedirect("admin_dashboard.jsp?msg=cannot_self_delete&section=users");
                        return;
                    }
                }
            }

            // Delete related donations first (avoid foreign key error)
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM donations WHERE user_id = ?")) {

                ps.setInt(1, targetId);
                ps.executeUpdate();
            }

            // Delete user from database
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM users WHERE id = ?")) {

                ps.setInt(1, targetId);
                ps.executeUpdate();
            }

            // Redirect with success message
            response.sendRedirect("admin_dashboard.jsp?msg=user_deleted&section=users");

        } catch (Exception e) {
            // Handle error
            e.printStackTrace();
            response.sendRedirect("admin_dashboard.jsp?msg=error&section=users");
        }
    }
}