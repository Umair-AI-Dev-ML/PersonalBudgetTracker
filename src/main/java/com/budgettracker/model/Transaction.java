
package com.budgettracker.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class Transaction {

    private int transactionId;
    private int userId;
    private String type;
    private String category;
    private BigDecimal amount;
    private LocalDate transactionDate;
    private String description;
    private LocalDateTime createdAt;

    // Empty constructor
    public Transaction() {
    }

    // Constructor for a new transaction
    public Transaction(
            int userId,
            String type,
            String category,
            BigDecimal amount,
            LocalDate transactionDate,
            String description) {

        this.userId = userId;
        this.type = type;
        this.category = category;
        this.amount = amount;
        this.transactionDate = transactionDate;
        this.description = description;
    }

    // Getters and Setters

    public int getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public LocalDate getTransactionDate() {
        return transactionDate;
    }

    public void setTransactionDate(LocalDate transactionDate) {
        this.transactionDate = transactionDate;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
