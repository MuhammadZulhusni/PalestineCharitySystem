package com.charity.controller;

import com.charity.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * This servlet toggles a campaign's status between ACTIVE and INACTIVE.
 * Used by admin to enable/disable campaigns without deleting them.
 */
public class ToggleCampaignServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get campaign ID from request
        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect("admin_dashboard.jsp");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {

            // Get current status of campaign
            String current = "ACTIVE"; // default
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT status FROM campaigns WHERE id = ?")) {
                ps.setInt(1, Integer.parseInt(idParam));
                ResultSet rs = ps.executeQuery();
                if (rs.next()) current = rs.getString("status");
            }

            // Toggle status
            String newStatus = "ACTIVE".equals(current) ? "INACTIVE" : "ACTIVE";
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE campaigns SET status = ? WHERE id = ?")) {
                ps.setString(1, newStatus);
                ps.setInt(2, Integer.parseInt(idParam));
                ps.executeUpdate();
            }

            // Redirect back to admin dashboard
            response.sendRedirect("admin_dashboard.jsp?msg=toggled");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin_dashboard.jsp?error=db");
        }
    }
}