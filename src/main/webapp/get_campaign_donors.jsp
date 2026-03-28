<%@ page import="com.charity.util.DBConnection, java.sql.*" %>
<%--
    This is NOT a full HTML page. It is a JSP fragment that returns only
    <tr> table rows (no <html>, <head>, or <body> tags).

    How it is used:
      - Called via AJAX fetch() from admin_dashboard.jsp viewDetails() function
      - URL: get_campaign_donors.jsp?id={campaignId}
      - The returned HTML rows are injected directly into the donor history
        table inside the SweetAlert2 View Campaign modal

    What it does:
      - Reads the campaign id from the URL parameter ?id=
      - Runs an inline SQL JOIN query:
          SELECT username, amount, donation_date
          FROM donations JOIN users ON user_id = users.id
          WHERE campaign_id = ?
          ORDER BY donation_date DESC (newest first)
      - Loops through results and outputs one <tr> per donation
      - If no donations exist → outputs a "No donations yet" message row
      - If a database error occurs → outputs a red error message row
--%>
<%
    // ── READ CAMPAIGN ID FROM URL PARAMETER ─────────────────────
    // Passed by viewDetails(id, ...) in admin_dashboard.jsp as:
    //   fetch('get_campaign_donors.jsp?id=' + id)
    String id = request.getParameter("id");

    // ── SQL QUERY ────────────────────────────────────────────────
    // JOIN donations with users to get the donor's username.
    // Filtered by campaign_id so only donors for THIS campaign are shown.
    // Sorted newest donation first.
    String sql = "SELECT u.username, d.amount, d.donation_date FROM donations d " +
                 "JOIN users u ON d.user_id = u.id " +
                 "WHERE d.campaign_id = ? ORDER BY d.donation_date DESC";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        // Bind campaign id safely using PreparedStatement (prevents SQL injection)
        ps.setInt(1, Integer.parseInt(id));
        ResultSet rs = ps.executeQuery();

        boolean hasData = false; // Track whether any donations exist

        // ── LOOP THROUGH RESULTS ─────────────────────────────────
        // Each row in the ResultSet becomes one <tr> in the modal table
        while(rs.next()) {
            hasData = true;
%>
    <tr>
        <%-- Donor username — left aligned --%>
        <td style="text-align:left; padding:9px 10px; border-bottom:1px solid rgba(128,128,128,0.1); font-size:13px; font-weight:500;">
            <%= rs.getString("username") %>
        </td>

        <%-- Donation amount — right aligned, green color --%>
        <td style="text-align:right; padding:9px 10px; border-bottom:1px solid rgba(128,128,128,0.1); font-size:13px; font-weight:600; color:#00c96e;">
            RM <%= String.format("%.2f", rs.getDouble("amount")) %>
        </td>

        <%-- Donation timestamp — right aligned, faded (opacity 65%) --%>
        <td style="text-align:right; padding:9px 10px; border-bottom:1px solid rgba(128,128,128,0.1); font-size:11.5px; opacity:.65;">
            <%= rs.getTimestamp("donation_date") %>
        </td>
    </tr>
<%
        } // end while

        // ── EMPTY STATE ──────────────────────────────────────────
        // Shown if no donations have been made to this campaign yet
        if(!hasData) {
            out.print("<tr><td colspan='3' style='text-align:center; padding:24px; font-size:13px; opacity:.5;'>No donations yet for this campaign.</td></tr>");
        }

    } catch(Exception e) {
        // ── ERROR STATE ──────────────────────────────────────────
        // Shown if a database error occurs (e.g. invalid id, connection failure)
        out.print("<tr><td colspan='3' style='text-align:center; padding:16px; color:#ff4f5e; font-size:13px;'>Error loading donor data.</td></tr>");
    }
%>