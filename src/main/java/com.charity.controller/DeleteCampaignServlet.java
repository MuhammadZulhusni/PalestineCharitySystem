package com.charity.controller;

import com.charity.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 * This servlet handles deleting a campaign from the database.
 * It gets the campaign ID and removes the record.
 */
public class DeleteCampaignServlet extends HttpServlet {

    // Handle request using GET method
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // Get campaign ID from request
        int id = Integer.parseInt(request.getParameter("id"));

        try (
                // Connect to database
                Connection conn = DBConnection.getConnection();

                // Prepare DELETE SQL query
                PreparedStatement ps = conn.prepareStatement("DELETE FROM campaigns WHERE id = ?")
        ) {
            // Set campaign ID into query
            ps.setInt(1, id);

            // Execute delete
            ps.executeUpdate();

            // Redirect with success message
            response.sendRedirect("admin_dashboard.jsp?msg=deleted");

        } catch (SQLException e) {

            // If error occurs (usually because campaign has donations = foreign key)
            // MySQL error 1451 = cannot delete because related data exists
            response.sendRedirect("admin_dashboard.jsp?msg=has_donations");
        }
    }
}