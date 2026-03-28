package com.charity.model;

/**
 * Donation — Model class representing a donation record in the system.
 *
 * This class maps directly to the donations table in the MySQL database.
 * It is a simple JavaBean (POJO — Plain Old Java Object) with private
 * fields and public getters and setters.
 *
 * In the MVC architecture, this class acts as the Model layer for donation data.
 * It is used to carry donation information between the database and the application:
 *   - DAO layer    : DonationDAO fills Donation objects from a database ResultSet
 *   - Controller   : DonateServlet reads donation data from the HTTP request
 *   - View layer   : JSP pages loop through List<Donation> to display history tables
 *
 * Relationships:
 *   - Each Donation belongs to one User   (via userId → users.id)
 *   - Each Donation belongs to one Campaign (via campaignId → campaigns.id)
 *   - This is the junction between User and Campaign in the database
 */
public class Donation {

    // Unique identifier for each donation — maps to id (PK) in donations table
    private int id;

    // The donor who made this donation — maps to user_id (FK → users.id)
    private int userId;

    // The campaign that received this donation — maps to campaign_id (FK → campaigns.id)
    private int campaignId;

    // The amount donated in Ringgit Malaysia (RM)
    // Updated in campaigns.current_amount each time a donation is made
    private double amount;

    // The exact date and time the donation was submitted
    // Set automatically by MySQL: DEFAULT CURRENT_TIMESTAMP
    private java.sql.Timestamp donationDate;

    // Optional: campaign title — not in donations table but useful for display
    // Populated via JOIN with campaigns table in DonationDAO queries
    private String campaignTitle;

    // Optional: donor username — not in donations table but useful for display
    // Populated via JOIN with users table in DonationDAO queries
    private String username;

    /**
     * Default no-argument constructor required for JavaBean conventions.
     * Used when creating an empty Donation object before populating fields
     * e.g. Donation d = new Donation(); d.setAmount(50.00);
     */
    public Donation() {}

    // ══════════════════════════════════════════════════════════
    // GETTERS AND SETTERS
    // All fields are private (encapsulation) so they can only be
    // accessed through these public getter and setter methods.
    //   get = read the value of a field
    //   set = update the value of a field
    // ══════════════════════════════════════════════════════════

    /**
     * Returns the donation's unique database id.
     * Used to identify individual donation records.
     */
    public int getId() { return id; }

    /**
     * Sets the donation id.
     * Called by DonationDAO when mapping a ResultSet row.
     */
    public void setId(int id) { this.id = id; }

    /**
     * Returns the id of the donor who made this donation.
     * Foreign key referencing users.id.
     * Used in SQL: WHERE d.user_id = ?
     */
    public int getUserId() { return userId; }

    /**
     * Sets the user id.
     * Called by DonationDAO when mapping a ResultSet row,
     * or by DonateServlet when reading user.getId() from session.
     */
    public void setUserId(int userId) { this.userId = userId; }

    /**
     * Returns the id of the campaign that received this donation.
     * Foreign key referencing campaigns.id.
     * Used in SQL: WHERE d.campaign_id = ?
     */
    public int getCampaignId() { return campaignId; }

    /**
     * Sets the campaign id.
     * Called by DonationDAO when mapping a ResultSet row,
     * or by DonateServlet when reading campaignId from the form.
     */
    public void setCampaignId(int campaignId) { this.campaignId = campaignId; }

    /**
     * Returns the donation amount in Ringgit Malaysia.
     * Used for display in donation history tables and stat card calculations.
     */
    public double getAmount() { return amount; }

    /**
     * Sets the donation amount.
     * Called by DonationDAO or DonateServlet when reading amount from form.
     */
    public void setAmount(double amount) { this.amount = amount; }

    /**
     * Returns the timestamp when the donation was submitted.
     * Set automatically by MySQL DEFAULT CURRENT_TIMESTAMP.
     * Displayed in donation history tables.
     */
    public java.sql.Timestamp getDonationDate() { return donationDate; }

    /**
     * Sets the donation timestamp.
     * Called by DonationDAO when mapping rs.getTimestamp("donation_date").
     */
    public void setDonationDate(java.sql.Timestamp donationDate) {
        this.donationDate = donationDate;
    }

    /**
     * Returns the campaign title associated with this donation.
     * Not stored in the donations table — populated via JOIN with campaigns.
     * Used in donor_dashboard.jsp donation history table to show campaign name.
     * Returns null if not populated (e.g. when title is not needed).
     */
    public String getCampaignTitle() { return campaignTitle; }

    /**
     * Sets the campaign title from a JOIN query result.
     * Called by DonationDAO.getDonationsByUser() after JOIN with campaigns.
     */
    public void setCampaignTitle(String campaignTitle) {
        this.campaignTitle = campaignTitle;
    }

    /**
     * Returns the donor username associated with this donation.
     * Not stored in the donations table — populated via JOIN with users.
     * Used in admin_dashboard.jsp donation log to show donor name.
     * Returns null if not populated (e.g. when username is not needed).
     */
    public String getUsername() { return username; }

    /**
     * Sets the username from a JOIN query result.
     * Called by DonationDAO.getAllDonations() after JOIN with users.
     */
    public void setUsername(String username) { this.username = username; }
}