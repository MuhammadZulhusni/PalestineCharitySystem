package com.charity.dao;

import com.charity.model.Donation;
import com.charity.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DonationDAO — Data Access Object for the donations table.
 *
 * This class centralises all database operations related to donations,
 * moving SQL out of DonateServlet and JSP files into a proper DAO layer.
 * This completes the MVC architecture by ensuring no SQL exists in
 * the Controller (Servlet) or View (JSP) layers.
 *
 * Methods:
 *   - insertDonation()         → used by DonateServlet when donor submits donation
 *   - updateCampaignTotal()    → used by DonateServlet to update current_amount
 *   - getDonationsByUser()     → used by donor_dashboard.jsp history table
 *   - getDonationsByCampaign() → used by get_campaign_donors.jsp
 *   - getAllDonations()        → used by admin_dashboard.jsp donation log
 *   - countUniqueDonors()      → used by admin_dashboard.jsp stat card
 *   - getDonorStats()          → used by donor_dashboard.jsp stat cards
 *
 * All methods that return lists now return List<Donation> using the
 * Donation model class instead of raw Object[] arrays, completing
 * the MVC model layer for the donations table.
 */
public class DonationDAO {

    /**
     * insertDonation() — Inserts a new donation record into the donations table.
     *
     * Called by DonateServlet after verifying the user is logged in
     * and the amount is valid.
     * Must be called inside a transaction together with updateCampaignTotal().
     * Uses the connection passed from DonateServlet so both operations
     * share the same transaction scope.
     *
     * @param conn        the active database connection (passed from servlet for transaction)
     * @param userId      the id of the donor from the HTTP session
     * @param campaignId  the id of the campaign being donated to
     * @param amount      the donation amount in RM
     */
    public void insertDonation(Connection conn, int userId, int campaignId, double amount)
            throws SQLException {
        String sql = "INSERT INTO donations (user_id, campaign_id, amount) VALUES (?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, campaignId);
            ps.setDouble(3, amount);
            ps.executeUpdate();
        }
    }

    /**
     * updateCampaignTotal() — Updates the current_amount of a campaign.
     *
     * Uses IFNULL to safely handle null current_amount (defaults to 0).
     * Must be called inside a transaction together with insertDonation().
     * If either operation fails, the transaction is rolled back so
     * the donation record and campaign total stay in sync.
     *
     * @param conn        the active database connection (passed from servlet for transaction)
     * @param campaignId  the id of the campaign to update
     * @param amount      the amount to add to current_amount
     */
    public void updateCampaignTotal(Connection conn, int campaignId, double amount)
            throws SQLException {
        String sql = "UPDATE campaigns SET current_amount = IFNULL(current_amount, 0) + ? WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, amount);
            ps.setInt(2, campaignId);
            ps.executeUpdate();
        }
    }

    /**
     * getDonationsByUser() — Retrieves all donations made by a specific donor.
     *
     * JOINs donations with campaigns to get campaign title.
     * Sorted newest first.
     * Maps each row to a Donation object with campaignTitle and donationDate populated.
     * Used by donor_dashboard.jsp to display personal donation history table.
     *
     * @param userId  the id of the logged-in donor
     * @return        List of Donation objects with title, amount, donation_date
     */
    public List<Donation> getDonationsByUser(int userId) {
        List<Donation> list = new ArrayList<>();
        String sql = "SELECT c.title, d.amount, d.donation_date " +
                "FROM donations d " +
                "JOIN campaigns c ON d.campaign_id = c.id " +
                "WHERE d.user_id = ? ORDER BY d.donation_date DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Donation d = new Donation();
                d.setUserId(userId);
                d.setCampaignTitle(rs.getString("title"));
                d.setAmount(rs.getDouble("amount"));
                d.setDonationDate(rs.getTimestamp("donation_date"));
                list.add(d);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /**
     * getDonationsByCampaign() — Retrieves all donations for a specific campaign.
     *
     * JOINs donations with users to get donor username.
     * Sorted newest first.
     * Maps each row to a Donation object with username and donationDate populated.
     * Used by get_campaign_donors.jsp which is fetched via AJAX
     * in the admin View Campaign modal.
     *
     * @param campaignId  the id of the campaign to fetch donors for
     * @return            List of Donation objects with username, amount, donation_date
     */
    public List<Donation> getDonationsByCampaign(int campaignId) {
        List<Donation> list = new ArrayList<>();
        String sql = "SELECT u.username, d.amount, d.donation_date " +
                "FROM donations d " +
                "JOIN users u ON d.user_id = u.id " +
                "WHERE d.campaign_id = ? ORDER BY d.donation_date DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, campaignId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Donation d = new Donation();
                d.setCampaignId(campaignId);
                d.setUsername(rs.getString("username"));
                d.setAmount(rs.getDouble("amount"));
                d.setDonationDate(rs.getTimestamp("donation_date"));
                list.add(d);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /**
     * getAllDonations() — Retrieves all donations across all campaigns.
     *
     * JOINs donations with users and campaigns to get both username and title.
     * Sorted newest first.
     * Maps each row to a Donation object with username, campaignTitle,
     * amount, and donationDate populated.
     * Used by admin_dashboard.jsp Global Donation Log section.
     *
     * @return  List of Donation objects with donation_date, username, title, amount
     */
    public List<Donation> getAllDonations() {
        List<Donation> list = new ArrayList<>();
        String sql = "SELECT d.donation_date, u.username, c.title, d.amount " +
                "FROM donations d " +
                "JOIN users u ON d.user_id = u.id " +
                "JOIN campaigns c ON d.campaign_id = c.id " +
                "ORDER BY d.donation_date DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Donation d = new Donation();
                d.setUsername(rs.getString("username"));
                d.setCampaignTitle(rs.getString("title"));
                d.setAmount(rs.getDouble("amount"));
                d.setDonationDate(rs.getTimestamp("donation_date"));
                list.add(d);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /**
     * countUniqueDonors() — Counts the number of unique donors.
     *
     * Uses COUNT(DISTINCT user_id) to avoid counting the same
     * donor multiple times if they donated more than once.
     * Used by admin_dashboard.jsp Unique Donors stat card.
     *
     * @return  total count of unique donors, or 0 if none
     */
    public int countUniqueDonors() {
        String sql = "SELECT COUNT(DISTINCT user_id) FROM donations";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    /**
     * getDonorStats() — Retrieves personal summary stats for a donor.
     *
     * Returns three values in one query:
     *   total        = SUM of all donations by this user
     *   cnt          = COUNT of all donations by this user
     *   top_campaign = campaign title where this user donated the most
     *                  (subquery using GROUP BY + ORDER BY SUM DESC LIMIT 1)
     *
     * Returns raw Object[] because this query returns mixed types
     * (double, int, String) that do not map cleanly to a single
     * Donation object — it is a stats aggregate, not a single record.
     *
     * Used by donor_dashboard.jsp to populate the 3 personal stat cards:
     *   Total Donated | Donations Made | Top Campaign
     *
     * @param userId  the id of the logged-in donor
     * @return        Object array: {totalDonated (double), count (int), topCampaign (String)}
     */
    public Object[] getDonorStats(int userId) {
        String sql = "SELECT SUM(d.amount) as total, COUNT(*) as cnt, " +
                "(SELECT c2.title FROM donations d2 " +
                " JOIN campaigns c2 ON d2.campaign_id = c2.id " +
                " WHERE d2.user_id = ? " +
                " GROUP BY d2.campaign_id ORDER BY SUM(d2.amount) DESC LIMIT 1) as top_campaign " +
                "FROM donations d WHERE d.user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new Object[]{
                        rs.getDouble("total"),
                        rs.getInt("cnt"),
                        rs.getString("top_campaign") != null ? rs.getString("top_campaign") : "—"
                };
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return new Object[]{0.0, 0, "—"};
    }
}