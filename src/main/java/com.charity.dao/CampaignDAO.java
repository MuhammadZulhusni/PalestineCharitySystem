package com.charity.dao;

import com.charity.model.Campaign;
import com.charity.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CampaignDAO {

    public List<Campaign> getAllCampaigns() {
        List<Campaign> list = new ArrayList<>();
        String sql = "SELECT * FROM campaigns";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Campaign c = new Campaign();
                c.setId(rs.getInt("id"));
                c.setTitle(rs.getString("title"));
                c.setDescription(rs.getString("description"));
                c.setTargetAmount(rs.getDouble("target_amount"));
                c.setCurrentAmount(rs.getDouble("current_amount"));
                c.setStatus(rs.getString("status") != null ? rs.getString("status") : "ACTIVE");
                list.add(c);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Campaign> getActiveCampaigns() {
        List<Campaign> list = new ArrayList<>();
        String sql = "SELECT * FROM campaigns WHERE status = 'ACTIVE'";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Campaign c = new Campaign();
                c.setId(rs.getInt("id"));
                c.setTitle(rs.getString("title"));
                c.setDescription(rs.getString("description"));
                c.setTargetAmount(rs.getDouble("target_amount"));
                c.setCurrentAmount(rs.getDouble("current_amount"));
                c.setStatus("ACTIVE");
                list.add(c);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public Campaign getCampaignById(int id) {
        String sql = "SELECT * FROM campaigns WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Campaign c = new Campaign();
                c.setId(rs.getInt("id"));
                c.setTitle(rs.getString("title"));
                c.setDescription(rs.getString("description"));
                c.setTargetAmount(rs.getDouble("target_amount"));
                c.setCurrentAmount(rs.getDouble("current_amount"));
                c.setStatus(rs.getString("status") != null ? rs.getString("status") : "ACTIVE");
                return c;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }
}