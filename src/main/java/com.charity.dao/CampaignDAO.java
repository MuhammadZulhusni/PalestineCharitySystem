package com.charity.dao;

import com.charity.model.Campaign;
import com.charity.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * CampaignDAO — Data Access Object for the campaigns table.

 * This class acts as the bridge between the Campaign model and the MySQL database.
 * It belongs to the Data Access Layer in the MVC architecture, meaning all
 * database logic related to campaigns is centralised here rather than being
 * written directly inside JSP pages or servlet files.

 * It contains three methods:
 *   - getAllCampaigns()    = used by admin dashboard (sees ALL campaigns)
 *   - getActiveCampaigns() = used by donor dashboard (sees ACTIVE only)
 *   - getCampaignById()   = used by edit modal via AJAX (fetches one campaign)

 * getAllCampaigns() and getActiveCampaigns() use Statement (no parameters needed).
 * getCampaignById() uses PreparedStatement to bind the id parameter safely
 * and prevent SQL injection.
 */
public class CampaignDAO {

    /**
     * getAllCampaigns() = Retrieves ALL campaigns from the database.
     * How it works:
     *   1. Runs SELECT * FROM campaigns with no filter
     *   2. Loops through every row in the result set
     *   3. Maps each row to a Campaign object and adds it to the list
     *   4. Returns the full list regardless of campaign status
     * Used by:
     *   - admin_dashboard.jsp, so the admin can see and manage ALL campaigns
     *     including ACTIVE, INACTIVE, and fully funded ones

     * NOT used by donor_dashboard.jsp, donors use getActiveCampaigns() instead
     * to prevent inactive campaigns from appearing on their view.

     * @return  List of all Campaign objects, or empty list if none exist
     */
    public List<Campaign> getAllCampaigns() {

        // Initialise an empty list to hold results
        List<Campaign> list = new ArrayList<>();

        // No WHERE filter = retrieve every campaign regardless of status
        String sql = "SELECT * FROM campaigns";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            // Loop through each row returned by the query
            while (rs.next()) {

                // Map the current database row to a Campaign object
                Campaign c = new Campaign();
                c.setId(rs.getInt("id"));
                c.setTitle(rs.getString("title"));
                c.setDescription(rs.getString("description"));
                c.setTargetAmount(rs.getDouble("target_amount"));
                c.setCurrentAmount(rs.getDouble("current_amount"));

                // Null-safe status assignment, if status column is null
                // in the database (e.g. old records before column was added),
                // default to "ACTIVE" to avoid NullPointerException in JSP
                c.setStatus(rs.getString("status") != null
                        ? rs.getString("status")
                        : "ACTIVE");

                // Add the mapped Campaign object to the result list
                list.add(c);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Returns the full list, empty list if no campaigns exist
        return list;
    }

    /**
     * getActiveCampaigns() Retrieves only ACTIVE campaigns from the database.
     * How it works:
     *   1. Runs SELECT * FROM campaigns WHERE status = 'ACTIVE'
     *   2. Only rows where status equals 'ACTIVE' are included
     *   3. Maps each row to a Campaign object and adds it to the list
     *   4. Returns the filtered list

     * Used by:
     *   - donor_dashboard.jsp, so donors only see campaigns that are
     *     currently open for donations. Campaigns that the admin has
     *     deactivated using the Deactivate button will NOT appear here.
     *
     * @return  List of active Campaign objects only, or empty list if none exist
     */
    public List<Campaign> getActiveCampaigns() {

        // Initialise an empty list to hold results
        List<Campaign> list = new ArrayList<>();

        // WHERE filter ensures only ACTIVE campaigns are returned
        String sql = "SELECT * FROM campaigns WHERE status = 'ACTIVE'";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            // Loop through each active campaign row
            while (rs.next()) {

                // Map the current database row to a Campaign object
                Campaign c = new Campaign();
                c.setId(rs.getInt("id"));
                c.setTitle(rs.getString("title"));
                c.setDescription(rs.getString("description"));
                c.setTargetAmount(rs.getDouble("target_amount"));
                c.setCurrentAmount(rs.getDouble("current_amount"));

                // Status is guaranteed to be ACTIVE due to the WHERE clause,
                // so we set it directly without a null check
                c.setStatus("ACTIVE");

                // Add the mapped Campaign object to the result list
                list.add(c);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Returns filtered list, empty list if no active campaigns exist
        return list;
    }

    /**
     * getCampaignById() = Retrieves a single campaign by its primary key id.
     * How it works:
     *   1. Runs SELECT * FROM campaigns WHERE id = ? using PreparedStatement
     *   2. Binds the given id as a parameter to prevent SQL injection
     *   3. If a matching row is found, maps it to a Campaign object and returns it
     *   4. If no matching row is found, returns null

     * Used by:
     *   - GetCampaignServlet, called via AJAX when the admin opens the
     *     Edit Campaign modal. The servlet calls this method, converts the
     *     returned Campaign object to JSON, and sends it back to the browser
     *     so the modal fields are pre-populated with the current values.

     * Uses PreparedStatement (unlike the other two methods) because the
     * campaign id is a dynamic parameter that comes from user input via
     * the URL query string, so it must be bound safely to prevent SQL injection.

     * @param id  the primary key of the campaign to retrieve
     * @return    a Campaign object if found, or null if no match exists
     */
    public Campaign getCampaignById(int id) {

        // Use PreparedStatement with ? placeholder for the id parameter
        String sql = "SELECT * FROM campaigns WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            // Bind the id parameter safely, prevents SQL injection
            ps.setInt(1, id);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                // A matching campaign was found, map the row to a Campaign object
                Campaign c = new Campaign();
                c.setId(rs.getInt("id"));
                c.setTitle(rs.getString("title"));
                c.setDescription(rs.getString("description"));
                c.setTargetAmount(rs.getDouble("target_amount"));
                c.setCurrentAmount(rs.getDouble("current_amount"));

                // Null-safe status assignment, defaults to "ACTIVE"
                // if the status column is null for any reason
                c.setStatus(rs.getString("status") != null
                        ? rs.getString("status")
                        : "ACTIVE");

                // Return the single Campaign object immediately
                return c;
            }
            // If rs.next() is false, no campaign with that id was found

        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Returns null if campaign not found or a database error occurred
        // GetCampaignServlet handles this by returning a 404 JSON response
        return null;
    }
}