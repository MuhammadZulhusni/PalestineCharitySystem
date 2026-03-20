<%@ page import="com.charity.util.DBConnection, java.sql.*" %>
<%
    String id = request.getParameter("id");
    String sql = "SELECT u.username, d.amount, d.donation_date FROM donations d " +
                 "JOIN users u ON d.user_id = u.id " +
                 "WHERE d.campaign_id = ? ORDER BY d.donation_date DESC";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, Integer.parseInt(id));
        ResultSet rs = ps.executeQuery();

        boolean hasData = false;
        while(rs.next()) {
            hasData = true;
%>
    <tr>
        <td style="text-align:left; padding:9px 10px; border-bottom:1px solid rgba(128,128,128,0.1); font-size:13px; font-weight:500;">
            <%= rs.getString("username") %>
        </td>
        <td style="text-align:right; padding:9px 10px; border-bottom:1px solid rgba(128,128,128,0.1); font-size:13px; font-weight:600; color:#00c96e;">
            RM <%= String.format("%.2f", rs.getDouble("amount")) %>
        </td>
        <td style="text-align:right; padding:9px 10px; border-bottom:1px solid rgba(128,128,128,0.1); font-size:11.5px; opacity:.65;">
            <%= rs.getTimestamp("donation_date") %>
        </td>
    </tr>
<%
        }
        if(!hasData) {
            out.print("<tr><td colspan='3' style='text-align:center; padding:24px; font-size:13px; opacity:.5;'>No donations yet for this campaign.</td></tr>");
        }
    } catch(Exception e) {
        out.print("<tr><td colspan='3' style='text-align:center; padding:16px; color:#ff4f5e; font-size:13px;'>Error loading donor data.</td></tr>");
    }
%>