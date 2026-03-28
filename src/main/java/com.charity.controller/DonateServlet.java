package com.charity.controller;

import com.charity.dao.DonationDAO;
import com.charity.model.User;
import com.charity.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

/**
 * DonateServlet — Handles donation form submission from donor_dashboard.jsp.
 *
 * Flow:
 *   1. Verify user is logged in via HttpSession
 *   2. Read campaignId and amount from the POST form
 *   3. Open a single DB connection and start a transaction
 *   4. Call DonationDAO.updateCampaignTotal() to add amount to campaign
 *   5. Call DonationDAO.insertDonation() to record the donation
 *   6. Commit if both succeed, rollback if either fails
 *   7. Redirect with ?status=success or ?status=error
 *
 * Why transaction is important:
 *   Both operations (UPDATE campaigns + INSERT donations) must succeed together.
 *   If INSERT succeeds but UPDATE fails, the campaign total would be wrong.
 *   If UPDATE succeeds but INSERT fails, the donation would not be recorded.
 *   Using conn.setAutoCommit(false) + conn.commit() / conn.rollback() ensures
 *   both operations succeed or both are undone — keeping data consistent.
 *
 * The connection is passed to DonationDAO methods so both operations
 * share the same transaction. DonationDAO does NOT open its own connection
 * for these two methods — it uses the one provided by this servlet.
 */
public class DonateServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── ACCESS CONTROL ───────────────────────────────────────────
        // Get session without creating a new one (false = don't create)
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // If no user in session → redirect to login
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // ── READ FORM DATA ───────────────────────────────────────────
        int    userId     = user.getId();
        int    campaignId = Integer.parseInt(request.getParameter("campaignId"));
        double amount     = Double.parseDouble(request.getParameter("amount"));

        // ── TRANSACTION ──────────────────────────────────────────────
        // Single connection shared between both DAO calls
        // so they run inside the same transaction
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            // Disable auto-commit to start manual transaction
            // This means nothing is saved until conn.commit() is called
            conn.setAutoCommit(false);

            DonationDAO donationDAO = new DonationDAO();

            // Step 1: Add donated amount to campaign's current_amount
            // Uses: UPDATE campaigns SET current_amount = IFNULL(current_amount,0) + ? WHERE id = ?
            donationDAO.updateCampaignTotal(conn, campaignId, amount);

            // Step 2: Insert new donation record into donations table
            // Uses: INSERT INTO donations (user_id, campaign_id, amount) VALUES (?, ?, ?)
            donationDAO.insertDonation(conn, userId, campaignId, amount);

            // Both operations succeeded — save changes permanently
            conn.commit();

            // Redirect back to donor dashboard with success alert
            response.sendRedirect("donor_dashboard.jsp?status=success");

        } catch (SQLException e) {

            // Something went wrong — undo BOTH operations
            // so campaign total and donation records stay in sync
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }

            e.printStackTrace();

            // Redirect back to donor dashboard with error alert
            response.sendRedirect("donor_dashboard.jsp?status=error");

        } finally {

            // Always close the connection whether success or failure
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}