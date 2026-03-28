package com.charity.controller;

import com.charity.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

/**
 * This servlet handles updating campaign details.
 * It updates title and target amount in the database.
 */
public class EditCampaignServlet extends HttpServlet {

    // Handle request using GET method
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // Get data from request
        int id = Integer.parseInt(request.getParameter("id"));
        String title = request.getParameter("title");
        double target = Double.parseDouble(request.getParameter("target"));

        try (
                // Connect to database
                Connection conn = DBConnection.getConnection();

                // Prepare UPDATE SQL query
                PreparedStatement ps = conn.prepareStatement(
                        "UPDATE campaigns SET title = ?, target_amount = ? WHERE id = ?")
        ) {
            // Set values into query
            ps.setString(1, title);
            ps.setDouble(2, target);
            ps.setInt(3, id);

            // Execute update
            ps.executeUpdate();

            // Redirect with success message
            response.sendRedirect("admin_dashboard.jsp?msg=updated");

        } catch (Exception e) {
            // Handle error
            e.printStackTrace();

            // Redirect with error message
            response.sendRedirect("admin_dashboard.jsp?error=db");
        }
    }
}