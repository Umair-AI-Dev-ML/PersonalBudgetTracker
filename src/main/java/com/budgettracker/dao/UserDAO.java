
package com.budgettracker.dao;

import com.budgettracker.model.User;
import com.budgettracker.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;

public class UserDAO {

    // Save a new user to MySQL
    public boolean registerUser(User user) throws SQLException {

        String sql =
                "INSERT INTO users (name, email, password) " +
                        "VALUES (?, ?, ?)";

        try (Connection connection =
                     DBConnection.getConnection();

             PreparedStatement statement =
                     connection.prepareStatement(
                             sql,
                             Statement.RETURN_GENERATED_KEYS
                     )) {

            // Use prepared statement parameters
            statement.setString(
                    1, user.getName()
            );

            statement.setString(
                    2, user.getEmail()
            );

            // Store password hash, not plaintext password
            statement.setString(
                    3, user.getPasswordHash()
            );

            int rowsAffected = statement.executeUpdate();

            if (rowsAffected > 0) {

                // Retrieve newly generated user ID
                try (ResultSet keys =
                             statement.getGeneratedKeys()) {

                    if (keys.next()) {

                        user.setUserId(
                                keys.getInt(1)
                        );
                    }
                }

                return true;
            }

            return false;
        }
    }


    // Find a registered user by email
    public User findByEmail(String email)
            throws SQLException {

        String sql =
                "SELECT user_id, name, email, " +
                        "password, created_at " +
                        "FROM users " +
                        "WHERE email = ?";

        try (Connection connection =
                     DBConnection.getConnection();

             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            // Protect against SQL injection
            statement.setString(
                    1, email
            );

            try (ResultSet result =
                         statement.executeQuery()) {

                if (result.next()) {

                    User user = new User();

                    // User ID
                    user.setUserId(
                            result.getInt("user_id")
                    );

                    // User name
                    user.setName(
                            result.getString("name")
                    );

                    // Email address
                    user.setEmail(
                            result.getString("email")
                    );

                    // Stored password hash
                    user.setPasswordHash(
                            result.getString("password")
                    );

                    // Safely handle creation timestamp
                    Timestamp createdAt =
                            result.getTimestamp("created_at");

                    if (createdAt != null) {

                        user.setCreatedAt(
                                createdAt.toLocalDateTime()
                        );
                    }

                    return user;
                }
            }
        }

        // No matching account found
        return null;
    }
}
