package com.charity.controller;

import com.charity.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * ForgotPasswordServlet — Handles the 2-step forgot password flow.
 *
 * Step 1 (/forgotPassword POST with step=1):
 *   - Reads username from form
 *   - Calls UserDAO.getSecurityQuestion() to look up the user's question
 *   - Redirects to forgot_password.jsp?step=2 with username + question
 *
 * Step 2 (/forgotPassword POST with step=2):
 *   - Reads username, answer, newPassword, confirmNew from form
 *   - Validates password strength and match
 *   - Calls UserDAO.verifyAndResetPassword() to check BCrypt answer
 *     and update the password hash in the database
 *   - Redirects with success or error message accordingly
 *
 * All database logic is delegated to UserDAO — no inline SQL here.
 */
public class ForgotPasswordServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Read which step the form is on (1 = find account, 2 = reset password)
        String step = request.getParameter("step");

        // ── STEP 1: FIND ACCOUNT BY USERNAME ────────────────────────
        if ("1".equals(step)) {

            String username = request.getParameter("username");

            // Validate — username must not be empty
            if (username == null || username.trim().isEmpty()) {
                response.sendRedirect("forgot_password.jsp?error=nousername");
                return;
            }

            // Call UserDAO to look up security question by username
            UserDAO userDAO = new UserDAO();
            String question = userDAO.getSecurityQuestion(username.trim());

            // If username not found in DB → redirect with error
            if (question == null) {
                response.sendRedirect("forgot_password.jsp?error=notfound");
                return;
            }

            // Username found — redirect to Step 2 with username + question key
            response.sendRedirect("forgot_password.jsp?step=2"
                    + "&username=" + java.net.URLEncoder.encode(username.trim(), "UTF-8")
                    + "&question=" + java.net.URLEncoder.encode(question, "UTF-8"));

            // ── STEP 2: VERIFY ANSWER AND RESET PASSWORD ─────────────────
        } else if ("2".equals(step)) {

            String username    = request.getParameter("username");
            String answer      = request.getParameter("answer");
            String newPassword = request.getParameter("newPassword");
            String confirmNew  = request.getParameter("confirmNew");

            // Validate — all fields must be present
            if (username == null || answer == null || newPassword == null || confirmNew == null) {
                response.sendRedirect("forgot_password.jsp?error=missing");
                return;
            }

            // Check passwords match (server-side check in addition to JS check)
            if (!newPassword.equals(confirmNew)) {
                response.sendRedirect("forgot_password.jsp?step=2"
                        + "&username=" + java.net.URLEncoder.encode(username, "UTF-8")
                        + "&error=mismatch");
                return;
            }

            // Validate password strength (server-side check in addition to JS check)
            // Must be: 8+ chars, one uppercase, one lowercase, one digit, one special char
            if (newPassword.length() < 8 ||
                    !newPassword.matches(".*[A-Z].*") ||
                    !newPassword.matches(".*[a-z].*") ||
                    !newPassword.matches(".*\\d.*") ||
                    !newPassword.matches(".*[^a-zA-Z0-9].*")) {
                response.sendRedirect("forgot_password.jsp?step=2"
                        + "&username=" + java.net.URLEncoder.encode(username, "UTF-8")
                        + "&error=weak");
                return;
            }

            // Call UserDAO to verify security answer and update password
            // UserDAO handles: BCrypt.checkpw() for answer + BCrypt.hashpw() for new password
            UserDAO userDAO = new UserDAO();
            String result = userDAO.verifyAndResetPassword(
                    username,
                    answer.trim().toLowerCase(), // lowercase for case-insensitive comparison
                    newPassword
            );

            // Handle result from UserDAO
            if ("wronganswer".equals(result)) {
                // Answer was wrong — fetch security question again to re-display it
                String q = userDAO.getSecurityQuestion(username);
                response.sendRedirect("forgot_password.jsp?step=2"
                        + "&username=" + java.net.URLEncoder.encode(username, "UTF-8")
                        + "&question=" + java.net.URLEncoder.encode(q != null ? q : "", "UTF-8")
                        + "&error=wronganswer");
                return;
            }

            if ("notfound".equals(result)) {
                response.sendRedirect("forgot_password.jsp?error=notfound");
                return;
            }

            if ("database".equals(result)) {
                response.sendRedirect("forgot_password.jsp?error=database");
                return;
            }

            // result = "ok" — password updated successfully
            // Redirect to forgot_password.jsp with success message
            // SweetAlert2 on that page detects ?msg=pwreset and shows success modal
            response.sendRedirect("forgot_password.jsp?msg=pwreset");
        }
    }
}