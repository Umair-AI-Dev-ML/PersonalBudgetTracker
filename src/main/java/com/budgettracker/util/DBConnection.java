
package com.budgettracker.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL =
            "jdbc:mysql://localhost:3306/personal_budget_tracker";

    private static final String USER = "budget_app";

    private static final String PASSWORD =
            System.getenv("BUDGET_DB_PASSWORD");

    public static Connection getConnection()
            throws SQLException {

        if (PASSWORD == null || PASSWORD.isBlank()) {
            throw new SQLException(
                    "BUDGET_DB_PASSWORD environment variable is not set."
            );
        }

        // Explicitly load the MySQL JDBC driver
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException(
                    "MySQL JDBC driver class was not found.", e
            );
        }

        // Connect Java to MySQL
        return DriverManager.getConnection(
                URL, USER, PASSWORD
        );
    }
}
