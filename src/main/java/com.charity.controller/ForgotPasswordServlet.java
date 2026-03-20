package com.charity.controller;

import com.charity.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.mindrot.jbcrypt.BCrypt;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class ForgotPasswordServlet extends HttpServlet {

    // Step 1: user submits username → return their security question
    // Step 2: user submits answer + new password → update if correct

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String step = request.getParameter("step");

        if ("1".equals(step)) {
            // Look up the security question for the username
            String username = request.getParameter("username");
            if (username == null || username.trim().isEmpty()) {
                response.sendRedirect("forgot_password.jsp?error=nousername");
                return;
            }

            String question = null;
            String sql = "SELECT security_question FROM users WHERE username = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, username.trim());
                ResultSet rs = ps.executeQuery();
                if (rs.next()) question = rs.getString("security_question");
            } catch (Exception e) { e.printStackTrace(); }

            if (question == null) {
                response.sendRedirect("forgot_password.jsp?error=notfound");
                return;
            }

            response.sendRedirect("forgot_password.jsp?step=2&username="
                    + java.net.URLEncoder.encode(username.trim(), "UTF-8")
                    + "&question=" + java.net.URLEncoder.encode(question, "UTF-8"));

        } else if ("2".equals(step)) {
            String username    = request.getParameter("username");
            String answer      = request.getParameter("answer");
            String newPassword = request.getParameter("newPassword");
            String confirmNew  = request.getParameter("confirmNew");

            if (username == null || answer == null || newPassword == null || confirmNew == null) {
                response.sendRedirect("forgot_password.jsp?error=missing");
                return;
            }

            if (!newPassword.equals(confirmNew)) {
                response.sendRedirect("forgot_password.jsp?step=2&username="
                        + java.net.URLEncoder.encode(username, "UTF-8")
                        + "&error=mismatch");
                return;
            }

            if (newPassword.length() < 8 ||
                    !newPassword.matches(".*[A-Z].*") ||
                    !newPassword.matches(".*[a-z].*") ||
                    !newPassword.matches(".*\\d.*") ||
                    !newPassword.matches(".*[^a-zA-Z0-9].*")) {
                response.sendRedirect("forgot_password.jsp?step=2&username="
                        + java.net.URLEncoder.encode(username, "UTF-8")
                        + "&error=weak");
                return;
            }

            // Verify answer
            String storedAnswer = null;
            String storedQuestion = null;
            String sqlGet = "SELECT security_answer, security_question FROM users WHERE username = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sqlGet)) {
                ps.setString(1, username);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    storedAnswer   = rs.getString("security_answer");
                    storedQuestion = rs.getString("security_question");
                }
            } catch (Exception e) { e.printStackTrace(); }

            if (storedAnswer == null || !BCrypt.checkpw(answer.trim().toLowerCase(), storedAnswer)) {
                response.sendRedirect("forgot_password.jsp?step=2&username="
                        + java.net.URLEncoder.encode(username, "UTF-8")
                        + "&question=" + java.net.URLEncoder.encode(storedQuestion != null ? storedQuestion : "", "UTF-8")
                        + "&error=wronganswer");
                return;
            }

            // Update password
            String newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt(12));
            String sqlUp = "UPDATE users SET password = ? WHERE username = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sqlUp)) {
                ps.setString(1, newHash);
                ps.setString(2, username);
                ps.executeUpdate();
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("forgot_password.jsp?error=database");
                return;
            }

            response.sendRedirect("forgot_password.jsp?msg=pwreset");
        }
    }
}