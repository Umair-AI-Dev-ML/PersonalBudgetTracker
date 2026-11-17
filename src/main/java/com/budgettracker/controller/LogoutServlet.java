
package com.budgettracker.controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        // Find the existing session
        HttpSession session = request.getSession(false);

        // Destroy the session if it exists
        if (session != null) {
            session.invalidate();
        }

        // Redirect to Login page
        response.sendRedirect(
                request.getContextPath() + "/login.jsp"
        );
    }
}
