package com.charity.controller;

import com.charity.model.User;
import com.charity.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class DonateServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = user.getId();
        int campaignId = Integer.parseInt(request.getParameter("campaignId"));
        double amount = Double.parseDouble(request.getParameter("amount"));

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Start Transaction

            // 1. Update the Campaign Total
            String updateSQL = "UPDATE campaigns SET current_amount = IFNULL(current_amount, 0) + ? WHERE id = ?";
            try (PreparedStatement psUpdate = conn.prepareStatement(updateSQL)) {
                psUpdate.setDouble(1, amount);
                psUpdate.setInt(2, campaignId);
                psUpdate.executeUpdate();
            }

            // 2. Record the specific donation in the 'donations' table
            String insertSQL = "INSERT INTO donations (user_id, campaign_id, amount) VALUES (?, ?, ?)";
            try (PreparedStatement psInsert = conn.prepareStatement(insertSQL)) {
                psInsert.setInt(1, userId);
                psInsert.setInt(2, campaignId);
                psInsert.setDouble(3, amount);
                psInsert.executeUpdate();
            }

            conn.commit(); // Save both changes permanently
            response.sendRedirect("donor_dashboard.jsp?status=success");

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            response.sendRedirect("donor_dashboard.jsp?status=error");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}