
package com.budgettracker.dao;

import com.budgettracker.model.Budget;
import com.budgettracker.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class BudgetDAO {

    // Save a new budget or update an existing one
    public boolean saveBudget(Budget budget) throws SQLException {

        // Validate budget information
        if (budget == null ||
                budget.getUserId() <= 0 ||
                budget.getCategory() == null ||
                budget.getCategory().isBlank() ||
                budget.getCategory().length() > 100 ||
                budget.getMonthlyLimit() == null ||
                budget.getMonthlyLimit().compareTo(
                        BigDecimal.ZERO
                ) <= 0 ||
                budget.getMonthlyLimit().scale() > 2 ||
                budget.getMonthlyLimit().compareTo(
                        new BigDecimal("9999999999.99")
                ) > 0 ||
                budget.getMonth() < 1 ||
                budget.getMonth() > 12 ||
                budget.getYear() < 1 ||
                budget.getYear() > 9999) {

            throw new IllegalArgumentException(
                    "Invalid budget information."
            );
        }

        // Insert a budget or update its existing limit
        String sql =
                "INSERT INTO budgets " +
                        "(user_id, category, monthly_limit, month, year) " +
                        "VALUES (?, ?, ?, ?, ?) " +
                        "ON DUPLICATE KEY UPDATE " +
                        "monthly_limit = ?";

        try (Connection connection =
                     DBConnection.getConnection();

             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            // User ID
            statement.setInt(
                    1, budget.getUserId()
            );

            // Budget category
            statement.setString(
                    2, budget.getCategory()
            );

            // Monthly limit
            statement.setBigDecimal(
                    3, budget.getMonthlyLimit()
            );

            // Month
            statement.setInt(
                    4, budget.getMonth()
            );

            // Year
            statement.setInt(
                    5, budget.getYear()
            );

            // Update existing monthly limit
            statement.setBigDecimal(
                    6, budget.getMonthlyLimit()
            );

            // Execute INSERT or UPDATE
            statement.executeUpdate();

            return true;
        }
    }


    // Retrieve budgets for one user and selected month
    public List<Budget> getBudgetsByUserAndMonth(
            int userId,
            int month,
            int year) throws SQLException {

        List<Budget> budgets = new ArrayList<>();

        String sql =
                "SELECT budget_id, user_id, category, " +
                        "monthly_limit, month, year, created_at " +
                        "FROM budgets " +
                        "WHERE user_id = ? " +
                        "AND month = ? " +
                        "AND year = ? " +
                        "ORDER BY category ASC";

        try (Connection connection =
                     DBConnection.getConnection();

             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, userId);
            statement.setInt(2, month);
            statement.setInt(3, year);

            try (ResultSet result =
                         statement.executeQuery()) {

                while (result.next()) {

                    Budget budget = new Budget();

                    budget.setBudgetId(
                            result.getInt("budget_id")
                    );

                    budget.setUserId(
                            result.getInt("user_id")
                    );

                    budget.setCategory(
                            result.getString("category")
                    );

                    budget.setMonthlyLimit(
                            result.getBigDecimal("monthly_limit")
                    );

                    budget.setMonth(
                            result.getInt("month")
                    );

                    budget.setYear(
                            result.getInt("year")
                    );

                    Timestamp createdAt =
                            result.getTimestamp("created_at");

                    if (createdAt != null) {

                        budget.setCreatedAt(
                                createdAt.toLocalDateTime()
                        );
                    }

                    budgets.add(budget);
                }
            }
        }

        return budgets;
    }
}
