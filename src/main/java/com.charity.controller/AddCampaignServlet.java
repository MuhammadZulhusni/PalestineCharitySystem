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
 * This servlet handles adding a new campaign into the database.
 * It gets data from the form and saves it into the campaigns table.
 */
public class AddCampaignServlet extends HttpServlet {

    // Handle form submission using POST method
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // Get input values from form
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        double target = Double.parseDouble(request.getParameter("target"));

        // SQL query to insert new campaign (current amount starts with 0)
        String sql = "INSERT INTO campaigns (title, description, target_amount, current_amount) VALUES (?, ?, ?, 0.0)";

        try (
                // Connect to database
                Connection conn = DBConnection.getConnection();

                // Prepare SQL statement
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            // Set values into SQL query
            ps.setString(1, title);
            ps.setString(2, description);
            ps.setDouble(3, target);

            // Execute insert query
            ps.executeUpdate();

            // Redirect to dashboard with success message
            response.sendRedirect("admin_dashboard.jsp?msg=created");

        } catch (SQLException e) {
            // Print error if database fails
            e.printStackTrace();

            // Redirect with error message
            response.sendRedirect("admin_dashboard.jsp?error=db");
        }
    }
}