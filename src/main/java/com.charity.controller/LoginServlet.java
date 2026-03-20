package com.charity.controller;

import com.charity.dao.UserDAO;
import com.charity.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

public class LoginServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userStr = request.getParameter("username");
        String passStr = request.getParameter("password");

        User user = userDAO.login(userStr, passStr);

        if (user != null) {
            request.getSession().setAttribute("user", user);
            if ("ADMIN".equals(user.getRole())) {
                response.sendRedirect("admin_dashboard.jsp");
            } else {
                response.sendRedirect("donor_dashboard.jsp");
            }
        } else {
            response.sendRedirect("login.jsp?error=1");
        }
    }
}