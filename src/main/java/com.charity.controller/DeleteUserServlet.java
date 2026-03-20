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

public class DeleteUserServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect("admin_dashboard.jsp?section=users");
            return;
        }

        // Server-side guard: prevent admin from deleting themselves
        User sessionUser = (User) request.getSession().getAttribute("user");
        if (sessionUser == null || !"ADMIN".equals(sessionUser.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        int targetId = Integer.parseInt(idParam);

        // Double-check target is not the logged-in admin
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT username FROM users WHERE id = ?")) {
                ps.setInt(1, targetId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    String targetUsername = rs.getString("username");
                    if (targetUsername.equals(sessionUser.getUsername())) {
                        response.sendRedirect("admin_dashboard.jsp?msg=cannot_self_delete&section=users");
                        return;
                    }
                }
            }

            // Delete donations first (FK constraint)
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM donations WHERE user_id = ?")) {
                ps.setInt(1, targetId);
                ps.executeUpdate();
            }

            // Delete user
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM users WHERE id = ?")) {
                ps.setInt(1, targetId);
                ps.executeUpdate();
            }

            response.sendRedirect("admin_dashboard.jsp?msg=user_deleted&section=users");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin_dashboard.jsp?msg=error&section=users");
        }
    }
}