
package com.budgettracker.dao;

import com.budgettracker.model.Transaction;
import com.budgettracker.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TransactionDAO {

    // Save a new income or expense
    public boolean addTransaction(Transaction transaction)
            throws SQLException {

        String sql = "INSERT INTO transactions " +
                "(user_id, type, category, amount, " +
                "transaction_date, description) " +
                "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             sql, Statement.RETURN_GENERATED_KEYS)) {

            statement.setInt(1, transaction.getUserId());
            statement.setString(2, transaction.getType());
            statement.setString(3, transaction.getCategory());
            statement.setBigDecimal(4, transaction.getAmount());

            statement.setDate(5,
                    Date.valueOf(transaction.getTransactionDate()));

            statement.setString(6, transaction.getDescription());

            int rowsAffected = statement.executeUpdate();

            if (rowsAffected > 0) {
                try (ResultSet keys =
                             statement.getGeneratedKeys()) {

                    if (keys.next()) {
                        transaction.setTransactionId(
                                keys.getInt(1));
                    }
                }
                return true;
            }

            return false;
        }
    }

    // Retrieve transactions belonging to one user
    public List<Transaction> getTransactionsByUserId(int userId)
            throws SQLException {

        List<Transaction> transactions = new ArrayList<>();

        String sql = "SELECT transaction_id, user_id, type, " +
                "category, amount, transaction_date, " +
                "description, created_at " +
                "FROM transactions " +
                "WHERE user_id = ? " +
                "ORDER BY transaction_date DESC, transaction_id DESC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, userId);

            try (ResultSet result = statement.executeQuery()) {

                while (result.next()) {

                    Transaction transaction = new Transaction();

                    transaction.setTransactionId(
                            result.getInt("transaction_id"));

                    transaction.setUserId(
                            result.getInt("user_id"));

                    transaction.setType(
                            result.getString("type"));

                    transaction.setCategory(
                            result.getString("category"));

                    transaction.setAmount(
                            result.getBigDecimal("amount"));

                    transaction.setTransactionDate(
                            result.getDate("transaction_date")
                                    .toLocalDate());

                    transaction.setDescription(
                            result.getString("description"));

                    Timestamp createdAt =
                            result.getTimestamp("created_at");

                    if (createdAt != null) {
                        transaction.setCreatedAt(
                                createdAt.toLocalDateTime());
                    }

                    transactions.add(transaction);
                }
            }
        }

        return transactions;
    }

    // Delete a transaction owned by the logged-in user
    public boolean deleteTransaction(int transactionId, int userId)
            throws SQLException {

        String sql = "DELETE FROM transactions " +
                "WHERE transaction_id = ? AND user_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, transactionId);
            statement.setInt(2, userId);

            int rowsAffected = statement.executeUpdate();

            return rowsAffected > 0;
        }
    }

    // Retrieve one transaction owned by the logged-in user
    public Transaction getTransactionById(int transactionId, int userId)
            throws SQLException {

        String sql = "SELECT transaction_id, user_id, type, " +
                "category, amount, transaction_date, " +
                "description, created_at " +
                "FROM transactions " +
                "WHERE transaction_id = ? AND user_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, transactionId);
            statement.setInt(2, userId);

            try (ResultSet result = statement.executeQuery()) {

                if (result.next()) {

                    Transaction transaction = new Transaction();

                    transaction.setTransactionId(
                            result.getInt("transaction_id"));

                    transaction.setUserId(
                            result.getInt("user_id"));

                    transaction.setType(
                            result.getString("type"));

                    transaction.setCategory(
                            result.getString("category"));

                    transaction.setAmount(
                            result.getBigDecimal("amount"));

                    transaction.setTransactionDate(
                            result.getDate("transaction_date")
                                    .toLocalDate());

                    transaction.setDescription(
                            result.getString("description"));

                    Timestamp createdAt =
                            result.getTimestamp("created_at");

                    if (createdAt != null) {
                        transaction.setCreatedAt(
                                createdAt.toLocalDateTime());
                    }

                    return transaction;
                }
            }
        }

        return null;
    }

    // Update a transaction owned by the logged-in user
    public boolean updateTransaction(Transaction transaction)
            throws SQLException {

        String sql = "UPDATE transactions SET " +
                "type = ?, category = ?, amount = ?, " +
                "transaction_date = ?, description = ? " +
                "WHERE transaction_id = ? AND user_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, transaction.getType());
            statement.setString(2, transaction.getCategory());
            statement.setBigDecimal(3, transaction.getAmount());

            statement.setDate(4,
                    Date.valueOf(transaction.getTransactionDate()));

            statement.setString(5, transaction.getDescription());

            statement.setInt(6, transaction.getTransactionId());
            statement.setInt(7, transaction.getUserId());

            int rowsAffected = statement.executeUpdate();

            return rowsAffected > 0;
        }
    }
}
