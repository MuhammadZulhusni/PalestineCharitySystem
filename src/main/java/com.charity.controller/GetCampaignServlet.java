package com.charity.controller;

import com.charity.dao.CampaignDAO;
import com.charity.model.Campaign;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * This servlet fetches campaign details by ID and returns JSON data.
 * Used for AJAX requests or API calls.
 */
public class GetCampaignServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Set response type as JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Get campaign ID from request
        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.setStatus(400);
            response.getWriter().write("{\"error\":\"Missing id\"}");
            return;
        }

        try {
            int id = Integer.parseInt(idParam);

            // Fetch campaign using DAO
            CampaignDAO dao = new CampaignDAO();
            Campaign c = dao.getCampaignById(id);

            // If campaign not found
            if (c == null) {
                response.setStatus(404);
                response.getWriter().write("{\"error\":\"Campaign not found\"}");
                return;
            }

            // Calculate progress percentage
            double pct = c.getTargetAmount() > 0
                    ? Math.min((c.getCurrentAmount() / c.getTargetAmount()) * 100, 100)
                    : 0;

            // Check if campaign is complete
            boolean complete = c.getCurrentAmount() >= c.getTargetAmount();

            // Build JSON response
            String json = "{\"id\":" + c.getId() +
                    ",\"title\":\"" + escape(c.getTitle()) + "\"" +
                    ",\"description\":\"" + escape(c.getDescription()) + "\"" +
                    ",\"targetAmount\":" + c.getTargetAmount() +
                    ",\"currentAmount\":" + c.getCurrentAmount() +
                    ",\"progressPct\":\"" + String.format("%.1f", pct) + "\"" +
                    ",\"status\":\"" + c.getStatus() + "\"" +
                    ",\"complete\":" + complete + "}";

            response.getWriter().write(json);

        } catch (NumberFormatException e) {
            response.setStatus(400);
            response.getWriter().write("{\"error\":\"Invalid id\"}");
        }
    }

    // Escape special characters for JSON safety
    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}