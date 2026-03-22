package com.charity.model;

/**
 * Campaign Model class representing a charity campaign in the system.
 *
 * This class maps directly to the campaigns table in the MySQL database.
 *
 * In the MVC architecture, this class acts as the Model layer for campaign data.
 * It is used to carry campaign information between the three layers:
 *   - DAO layer    : CampaignDAO fills Campaign objects from a database ResultSet
 *   - Controller   : GetCampaignServlet converts a Campaign object to JSON for AJAX
 *   - View layer   : JSP pages loop through List<Campaign> to display campaign cards
 *
 * The status field controls campaign availability:
 *   - "ACTIVE"   : campaign is visible to donors and accepts donations
 *   - "INACTIVE" : campaign is hidden from donors and locked from donations
 *                  toggled by the admin using ToggleCampaignServlet
 */
public class Campaign {

    // Unique identifier for each campaign, maps to id (PK) in campaigns table
    private int id;

    // Display name of the campaign e.g. "Emergency Food Parcels for Gaza Families"
    // Shown in campaign cards on both admin and donor dashboards
    private String title;

    // Brief summary of what the campaign supports
    // Shown below the title in campaign cards
    private String description;

    // The fundraising goal in Ringgit Malaysia (RM)
    // Used to calculate the progress percentage:
    //   pct = (currentAmount / targetAmount) * 100
    private double targetAmount;

    // The total amount donated to this campaign so far
    // Updated by DonateServlet each time a donation is submitted:
    //   UPDATE campaigns SET current_amount = current_amount + ? WHERE id = ?
    private double currentAmount;

    // Campaign availability status either "ACTIVE" or "INACTIVE"
    // Controls whether the donate form appears on the donor dashboard
    // Toggled by ToggleCampaignServlet when admin clicks Activate/Deactivate
    private String status;

    /**
     * getStatus(), Returns the campaign status with a null-safe fallback.
     *
     * Returns "ACTIVE" as the default if the status field is null.
     * This handles edge cases where old campaign records in the database
     * were created before the status column was added via ALTER TABLE,
     * preventing NullPointerException in JSP when checking:
     *   "INACTIVE".equals(c.getStatus())
     */
    public String getStatus() {
        return status != null ? status : "ACTIVE";
    }

    /**
     * Sets the campaign status.
     * Value should be either "ACTIVE" or "INACTIVE".
     * Called by CampaignDAO when mapping a ResultSet row to a Campaign object.
     */
    public void setStatus(String status) { this.status = status; }

    /**
     * Default no-argument constructor required for JavaBean conventions.
     */
    public Campaign() {}


    // GETTERS AND SETTERS
    // All fields are private (encapsulation) so they can only be
    // accessed through these public getter and setter methods.
    //   get = read the value of a field
    //   set = update the value of a field

    /**
     * Returns the campaign's unique database id.
     * Used in servlet URL parameters e.g. editCampaign?id=3
     * and in SQL queries e.g. WHERE id = ?
     */
    public int getId() { return id; }

    /**
     * Sets the campaign id.
     * Called by CampaignDAO when mapping a ResultSet row.
     */
    public void setId(int id) { this.id = id; }

    /**
     * Returns the campaign title.
     * Displayed as the heading of each campaign card on the dashboard.
     */
    public String getTitle() { return title; }

    /**
     * Sets the campaign title.
     */
    public void setTitle(String title) { this.title = title; }

    /**
     * Returns the campaign description.
     * Displayed below the title in campaign cards and inside the View modal.
     */
    public String getDescription() { return description; }

    /**
     * Sets the campaign description.
     */
    public void setDescription(String description) {
        this.description = description;
    }

    /**
     * Returns the fundraising target amount in RM.
     * Used to calculate progress percentage and displayed as the campaign goal.
     */
    public double getTargetAmount() { return targetAmount; }

    /**
     * Sets the fundraising target amount.
     */
    public void setTargetAmount(double targetAmount) {
        this.targetAmount = targetAmount;
    }

    /**
     * Returns the total amount raised so far in RM.
     * Used alongside getTargetAmount() to calculate progress:
     *   double pct = (getCurrentAmount() / getTargetAmount()) * 100
     * Also used to determine if a campaign is fully funded:
     *   boolean complete = getCurrentAmount() >= getTargetAmount()
     */
    public double getCurrentAmount() { return currentAmount; }

    /**
     * Sets the current amount raised.
     * Called by CampaignDAO when mapping a ResultSet row.
     */
    public void setCurrentAmount(double currentAmount) {
        this.currentAmount = currentAmount;
    }
}