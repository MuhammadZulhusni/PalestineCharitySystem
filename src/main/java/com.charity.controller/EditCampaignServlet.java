package com.charity.controller;

import com.charity.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class EditCampaignServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String title = request.getParameter("title");
        double target = Double.parseDouble(request.getParameter("target"));

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE campaigns SET title = ?, target_amount = ? WHERE id = ?")) {
            ps.setString(1, title);
            ps.setDouble(2, target);
            ps.setInt(3, id);
            ps.executeUpdate();
            response.sendRedirect("admin_dashboard.jsp?msg=updated");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin_dashboard.jsp?error=db");
        }
    }
}