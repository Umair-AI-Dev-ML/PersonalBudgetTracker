
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
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/export-transactions")
public class ExportTransactionsServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        // Prevent caching of financial information
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

        // Retrieve logged-in user's ID
        int userId = (Integer) session.getAttribute("userId");

        TransactionDAO transactionDAO = new TransactionDAO();

        List<Transaction> transactions;

        try {

            // Retrieve only this user's transactions
            transactions =
                    transactionDAO.getTransactionsByUserId(userId);

        } catch (SQLException e) {

            getServletContext().log(
                    "Error exporting transactions", e
            );

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to export transactions."
            );
            return;
        }

        // Set CSV download headers
        response.setContentType("text/csv;charset=UTF-8");

        response.setHeader(
                "Content-Disposition",
                "attachment; filename=\"transactions.csv\""
        );

        // Write the CSV file
        PrintWriter writer = response.getWriter();

        // UTF-8 BOM helps Excel display Unicode characters
        writer.write('\uFEFF');

        // CSV column headings
        writer.println(
                "Date,Type,Category,Amount,Description"
        );

        // Export each transaction
        for (Transaction transaction : transactions) {

            String date =
                    transaction.getTransactionDate().toString();

            String type =
                    safeCsv(transaction.getType());

            String category =
                    safeCsv(transaction.getCategory());

            String amount =
                    transaction.getAmount().toPlainString();

            String description =
                    safeCsv(transaction.getDescription());

            writer.println(
                    csvField(date) + "," +
                            csvField(type) + "," +
                            csvField(category) + "," +
                            csvField(amount) + "," +
                            csvField(description)
            );
        }

        writer.flush();
    }

    // Protect spreadsheet applications from formula injection
    private String safeCsv(String value) {

        if (value == null) {
            return "";
        }

        // Keep every transaction on one CSV row
        String cleaned = value
                .replace('\r', ' ')
                .replace('\n', ' ')
                .replace('\t', ' ');

        // Find first non-whitespace character
        String trimmed = cleaned.stripLeading();

        if (!trimmed.isEmpty()) {

            char first = trimmed.charAt(0);

            if (first == '=' ||
                    first == '+' ||
                    first == '-' ||
                    first == '@') {

                return "'" + cleaned;
            }
        }

        return cleaned;
    }

    // Escape quotes and commas using CSV rules
    private String csvField(String value) {

        if (value == null) {
            value = "";
        }

        return "\"" + value.replace("\"", "\"\"") + "\"";
    }
}
