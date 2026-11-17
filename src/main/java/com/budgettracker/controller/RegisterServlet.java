
package com.budgettracker.controller;

import com.budgettracker.dao.UserDAO;
import com.budgettracker.model.User;
import com.budgettracker.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Locale;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword =
                request.getParameter("confirmPassword");

        // Check required fields
        if (name == null || email == null ||
                password == null || confirmPassword == null) {

            showError(request, response,
                    "Please complete all fields.");
            return;
        }

        name = name.trim();
        email = email.trim().toLowerCase(Locale.ROOT);

        // Validate name
        if (name.isEmpty() || name.length() > 100) {
            showError(request, response,
                    "Name must be between 1 and 100 characters.");
            return;
        }

        // Basic email validation
        if (email.length() > 255 ||
                !email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {

            showError(request, response,
                    "Please enter a valid email address.");
            return;
        }

        // Validate password
        if (password.length() < 8 || password.length() > 128) {
            showError(request, response,
                    "Password must contain 8 to 128 characters.");
            return;
        }

        // Verify matching passwords
        if (!password.equals(confirmPassword)) {
            showError(request, response,
                    "Passwords do not match.");
            return;
        }

        try {
            // Check whether email already exists
            if (userDAO.findByEmail(email) != null) {
                showError(request, response,
                        "This email is already registered.");
                return;
            }

            // Hash the password before saving
            String passwordHash =
                    PasswordUtil.hashPassword(password);

            // Create a User object
            User user = new User(name, email, passwordHash);

            // Save user to MySQL
            boolean registered = userDAO.registerUser(user);

            if (registered) {
                response.sendRedirect(
                        request.getContextPath()
                                + "/login.jsp?registered=1"
                );
            } else {
                showError(request, response,
                        "Registration failed. Please try again.");
            }

        } catch (SQLException e) {

            getServletContext().log(
                    "Registration database error", e
            );

            showError(request, response,
                    "Registration could not be completed. Please try again.");

        }
    }

    private void showError(
            HttpServletRequest request,
            HttpServletResponse response,
            String message)
            throws ServletException, IOException {

        request.setAttribute("errorMessage", message);

        request.getRequestDispatcher("/register.jsp")
                .forward(request, response);
    }
}
