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

public class DeleteCampaignServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM campaigns WHERE id = ?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
            response.sendRedirect("admin_dashboard.jsp?msg=deleted");
        } catch (SQLException e) {
            // MySQL error 1451 is the code for Foreign Key constraint violations (donations exist)
            response.sendRedirect("admin_dashboard.jsp?msg=has_donations");
        }
    }
}