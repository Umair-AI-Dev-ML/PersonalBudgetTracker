
package com.budgettracker.controller;

import com.budgettracker.dao.TransactionDAO;
import com.budgettracker.model.Transaction;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Locale;

@WebServlet("/add-transaction")
public class AddTransactionServlet extends HttpServlet {

    private final TransactionDAO transactionDAO =
            new TransactionDAO();

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // Check whether the user is logged in
        HttpSession session = request.getSession(false);

        if (session == null ||
                !(session.getAttribute("userId") instanceof Integer)) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp"
            );
            return;
        }

        String expectedToken =
                (String) session.getAttribute("csrfToken");

        String submittedToken =
                request.getParameter("csrfToken");

        if (expectedToken == null ||
                submittedToken == null ||
                !java.security.MessageDigest.isEqual(
                        expectedToken.getBytes(java.nio.charset.StandardCharsets.UTF_8),
                        submittedToken.getBytes(java.nio.charset.StandardCharsets.UTF_8))) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Invalid form security token."
            );
            return;
        }

        // Get the user ID from the session
        int userId = (Integer) session.getAttribute("userId");

        // Read form information
        String type = request.getParameter("type");
        String category = request.getParameter("category");
        String amountText = request.getParameter("amount");
        String dateText = request.getParameter("transactionDate");
        String description = request.getParameter("description");

        // Check required fields
        if (type == null || category == null ||
                amountText == null || dateText == null) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Please complete all required fields."
            );
            return;
        }

        type = type.trim();

        if (type.equalsIgnoreCase("income")) {
            type = "Income";
        } else if (type.equalsIgnoreCase("expense")) {
            type = "Expense";
        }
        category = category.trim();

        if (description == null) {
            description = "";
        } else {
            description = description.trim();
        }

        // Validate transaction type
        if (!type.equals("Income") && !type.equals("Expense")) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid transaction type."
            );
            return;
        }

        // Validate category and description
        if (category.isEmpty() || category.length() > 100 ||
                description.length() > 500) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid category or description."
            );
            return;
        }

        try {
            // Convert amount and date
            BigDecimal amount = new BigDecimal(amountText.trim());
            LocalDate transactionDate = LocalDate.parse(dateText);

            // Amount must be positive, with at most 2 decimals
            if (amount.compareTo(BigDecimal.ZERO) <= 0 ||
                    amount.scale() > 2 ||
                    amount.precision() - amount.scale() > 10) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Please enter a valid positive amount."
                );
                return;
            }

            // Create the transaction object
            Transaction transaction = new Transaction(
                    userId,
                    type,
                    category,
                    amount,
                    transactionDate,
                    description
            );

            // Save transaction into MySQL
            boolean saved =
                    transactionDAO.addTransaction(transaction);

            if (saved) {
                response.sendRedirect(
                        request.getContextPath()
                                + "/dashboard?transactionAdded=1"
                );
            } else {
                response.sendError(
                        HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        "Unable to save transaction."
                );
            }

        } catch (NumberFormatException |
                 DateTimeParseException e) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid amount or date."
            );

        } catch (SQLException e) {

            getServletContext().log(
                    "Error saving transaction", e
            );

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Database error while saving transaction."
            );
        }
    }
}
