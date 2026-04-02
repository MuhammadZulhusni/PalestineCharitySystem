package com.charity.controller;

import com.charity.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

// CLASS: ForgotPasswordServlet
// PURPOSE : Handles the full "Forgot Password" flow across 2 steps.
// URL     : /forgotPassword  (POST only)
//
// FLOW OVERVIEW:
//   Step 1 = User enters username = servlet finds their security question
//   Step 2 = User answers question & enters new password = servlet resets it
//
// This servlet contains NO SQL. All database work is done by UserDAO.

public class ForgotPasswordServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // STEP 0 : Read which step the user is on.
        //          The JSP sends a hidden input: <input type="hidden" name="step" value="1">
        //          step = "1" means: find the account
        //          step = "2" means: verify answer and reset password
        String step = request.getParameter("step");

        // STEP 1: FIND ACCOUNT BY USERNAME
        // User submitted the first form with just their username.
        // Goal: find their security question and redirect to Step 2.
        if ("1".equals(step)) {

            // STEP 1.1 = Read the username from the form input
            String username = request.getParameter("username");

            // STEP 1.2 = Validate: username must not be blank
            //            If empty = redirect back with error flag
            if (username == null || username.trim().isEmpty()) {
                response.sendRedirect("forgot_password.jsp?error=nousername");
                return;
            }

            // STEP 1.3 = Ask UserDAO to look up the security question for this username.
            //            UserDAO runs: SELECT security_question FROM users WHERE username = ?
            UserDAO userDAO = new UserDAO();
            String question = userDAO.getSecurityQuestion(username.trim());

            // STEP 1.4 = If question is null, the username does not exist in the database.
            //            Redirect back with error so JSP can show "Account not found".
            if (question == null) {
                response.sendRedirect("forgot_password.jsp?error=notfound");
                return;
            }

            // STEP 1.5 = Username was found. Redirect to Step 2.
            //            Pass username and question key as URL parameters.
            //            URLEncoder.encode() makes them safe for URLs (handles spaces, etc.)
            //            JSP will use the question key to display the full question text.
            response.sendRedirect("forgot_password.jsp?step=2"
                    + "&username=" + java.net.URLEncoder.encode(username.trim(), "UTF-8")
                    + "&question=" + java.net.URLEncoder.encode(question, "UTF-8"));


            // STEP 2: VERIFY ANSWER AND RESET PASSWORD
            // User submitted the second form with: security answer & new password.
            // Goal: verify the answer, validate the password, update the database.
        } else if ("2".equals(step)) {

            // STEP 2.1 : Read all four fields from the form
            String username    = request.getParameter("username");    // hidden field carried from Step 1
            String answer      = request.getParameter("answer");      // answer to security question
            String newPassword = request.getParameter("newPassword"); // new password
            String confirmNew  = request.getParameter("confirmNew");  // confirm new password

            // STEP 2.2 — Validate: all four fields must be present (not null)
            //            This is a server-side safety check in case JavaScript was bypassed.
            if (username == null || answer == null || newPassword == null || confirmNew == null) {
                response.sendRedirect("forgot_password.jsp?error=missing");
                return;
            }

            // STEP 2.3 — Check that new password and confirm password are the same.
            //            This is also checked by JavaScript on the JSP,
            //            but we always re-check on the server for security.
            if (!newPassword.equals(confirmNew)) {
                response.sendRedirect("forgot_password.jsp?step=2"
                        + "&username=" + java.net.URLEncoder.encode(username, "UTF-8")
                        + "&error=mismatch");
                return;
            }

            // STEP 2.4 — Validate password strength (server-side).
            //            Rules: at least 8 characters,
            //                   contains at least one uppercase letter (A-Z),
            //                   contains at least one lowercase letter (a-z),
            //                   contains at least one digit (0-9),
            //                   contains at least one special character (non-alphanumeric).
            //            Also checked by JavaScript on the JSP, but always re-validated here.
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

            // STEP 2.5 — Call UserDAO to do two things:
            //              (a) Verify the security answer using BCrypt.checkpw()
            //              (b) If correct, hash the new password and UPDATE the database
            //            Note: answer is lowercased here before passing to UserDAO
            //                  so the comparison is case-insensitive (e.g. "Kucing" = "kucing")
            UserDAO userDAO = new UserDAO();
            String result = userDAO.verifyAndResetPassword(
                    username,
                    answer.trim().toLowerCase(), // normalize to lowercase before BCrypt check
                    newPassword
            );

            // STEP 2.6 — Handle the result string returned by UserDAO:

            // Case A: Security answer was wrong
            if ("wronganswer".equals(result)) {
                // Fetch the security question again so Step 2 page can still display it
                String q = userDAO.getSecurityQuestion(username);
                response.sendRedirect("forgot_password.jsp?step=2"
                        + "&username=" + java.net.URLEncoder.encode(username, "UTF-8")
                        + "&question=" + java.net.URLEncoder.encode(q != null ? q : "", "UTF-8")
                        + "&error=wronganswer");
                return;
            }

            // Case B: Username was not found in the database
            if ("notfound".equals(result)) {
                response.sendRedirect("forgot_password.jsp?error=notfound");
                return;
            }

            // Case C: A database error occurred inside UserDAO
            if ("database".equals(result)) {
                response.sendRedirect("forgot_password.jsp?error=database");
                return;
            }

            // Case D: result = "ok" = everything passed, password updated successfully.
            //         Redirect to forgot_password.jsp with ?msg=pwreset
            //         The JSP detects this parameter and shows a SweetAlert2 success modal.
            response.sendRedirect("forgot_password.jsp?msg=pwreset");
        }
    }
}