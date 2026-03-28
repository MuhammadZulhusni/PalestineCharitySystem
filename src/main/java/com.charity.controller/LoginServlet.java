package com.charity.controller;

import com.charity.dao.UserDAO;
import com.charity.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * This servlet handles user login.
 * It checks credentials and redirects users based on role.
 */
public class LoginServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO(); // DAO handles DB operations for users

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get username and password from login form
        String userStr = request.getParameter("username");
        String passStr = request.getParameter("password");

        // Check credentials via UserDAO
        User user = userDAO.login(userStr, passStr);

        if (user != null) {
            // Login successful =  save user in session
            request.getSession().setAttribute("user", user);

            // Redirect based on role
            if ("ADMIN".equals(user.getRole())) {
                response.sendRedirect("admin_dashboard.jsp"); // admin page
            } else {
                response.sendRedirect("donor_dashboard.jsp"); // donor page
            }

        } else {
            // Login failed = redirect back to login page with error
            response.sendRedirect("login.jsp?error=1");
        }
    }
}