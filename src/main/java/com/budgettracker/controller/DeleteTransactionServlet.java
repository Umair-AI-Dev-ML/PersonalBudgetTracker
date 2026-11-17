
package com.budgettracker.controller;

import com.budgettracker.dao.TransactionDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.SQLException;

@WebServlet("/delete-transaction")
public class DeleteTransactionServlet extends HttpServlet {

    private final TransactionDAO transactionDAO =
            new TransactionDAO();

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        // Check whether the user is logged in
        HttpSession session = request.getSession(false);

        if (session == null ||
                !(session.getAttribute("userId")
                        instanceof Integer)) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp"
            );
            return;
        }

        // Validate the CSRF security token
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

        // Read the transaction ID from the form
        String transactionIdText =
                request.getParameter("transactionId");

        int transactionId;

        try {
            transactionId = Integer.parseInt(transactionIdText);

            if (transactionId <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException e) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid transaction ID."
            );
            return;
        }

        // Use the logged-in user's ID
        int userId =
                (Integer) session.getAttribute("userId");

        try {

            boolean deleted =
                    transactionDAO.deleteTransaction(
                            transactionId, userId
                    );

            if (!deleted) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Transaction not found."
                );
                return;
            }

            // Return to dashboard after successful deletion
            response.sendRedirect(
                    request.getContextPath()
                            + "/dashboard?transactionDeleted=1"
            );

        } catch (SQLException e) {

            getServletContext().log(
                    "Error deleting transaction", e
            );

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to delete transaction."
            );
        }
    }
}
