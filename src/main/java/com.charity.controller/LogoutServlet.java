package com.charity.controller;

import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * This servlet handles user logout.
 * It invalidates the session and redirects to login page.
 */
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {

        // Get current session (if exists)
        HttpSession session = request.getSession(false);

        // Invalidate session = user logged out
        if (session != null) {
            session.invalidate();
        }

        // Redirect to login page
        response.sendRedirect("login.jsp");
    }
}