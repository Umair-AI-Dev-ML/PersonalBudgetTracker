
package com.budgettracker.controller;

import com.budgettracker.dao.BudgetDAO;
import com.budgettracker.model.Budget;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.SQLException;
import java.time.DateTimeException;
import java.time.YearMonth;

@WebServlet("/save-budget")
public class SaveBudgetServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        // Prevent browser caching of protected content
        response.setHeader("Cache-Control", "no-store");

        // Check login session
        HttpSession session = request.getSession(false);

        if (session == null ||
                !(session.getAttribute("userId") instanceof Integer)) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp"
            );
            return;
        }

        // Validate CSRF security token
        String expectedToken =
                (String) session.getAttribute("csrfToken");

        String submittedToken =
                request.getParameter("csrfToken");

        if (expectedToken == null ||
                submittedToken == null ||
                !MessageDigest.isEqual(
                        expectedToken.getBytes(StandardCharsets.UTF_8),
                        submittedToken.getBytes(StandardCharsets.UTF_8))) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Invalid security token."
            );
            return;
        }

        // Logged-in user
        int userId = (Integer) session.getAttribute("userId");

        // Read submitted form values
        String category = request.getParameter("category");
        String limitText = request.getParameter("monthlyLimit");
        String monthText = request.getParameter("month");

        // Validate category
        if (category == null ||
                category.trim().isEmpty() ||
                category.trim().length() > 100) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Please enter a valid budget category."
            );
            return;
        }

        category = category.trim();

        // Validate monthly limit
        BigDecimal monthlyLimit;

        try {

            monthlyLimit = new BigDecimal(limitText);

            if (monthlyLimit.compareTo(BigDecimal.ZERO) <= 0 ||
                    monthlyLimit.scale() > 2 ||
                    monthlyLimit.compareTo(
                            new BigDecimal("9999999999.99")
                    ) > 0) {

                throw new NumberFormatException(
                        "Invalid budget amount."
                );
            }

        } catch (NumberFormatException | NullPointerException e) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Please enter a valid monthly limit."
            );
            return;
        }

        // Validate selected month
        YearMonth selectedMonth;

        try {

            if (monthText == null ||
                    !monthText.matches(
                            "\\d{4}-(0[1-9]|1[0-2])")) {

                throw new DateTimeException(
                        "Invalid month format."
                );
            }

            selectedMonth = YearMonth.parse(monthText);

        } catch (DateTimeException e) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Please select a valid month."
            );
            return;
        }

        // Prepare the budget object
        Budget budget = new Budget();

        budget.setUserId(userId);
        budget.setCategory(category);
        budget.setMonthlyLimit(monthlyLimit);
        budget.setMonth(selectedMonth.getMonthValue());
        budget.setYear(selectedMonth.getYear());

        // Save to MySQL
        BudgetDAO budgetDAO = new BudgetDAO();

        try {

            budgetDAO.saveBudget(budget);

        } catch (SQLException e) {

            getServletContext().log(
                    "Error saving monthly budget", e
            );

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to save budget."
            );
            return;
        }

        // Return to the selected month's dashboard
        response.sendRedirect(
                request.getContextPath()
                        + "/dashboard?month="
                        + selectedMonth
                        + "&budgetSaved=1"
        );
    }
}
