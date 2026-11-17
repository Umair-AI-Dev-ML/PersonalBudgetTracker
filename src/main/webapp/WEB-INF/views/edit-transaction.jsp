
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.budgettracker.model.Transaction" %>

<%!
    // Escape text before inserting it into HTML
    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    Transaction transaction =
            (Transaction) request.getAttribute("transaction");

    if (transaction == null) {
        response.sendError(404, "Transaction not found.");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Edit Transaction - Personal Budget Tracker</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">

    <!-- Custom CSS -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/style.css">
</head>

<body>

<!-- Navigation Bar -->
<nav class="navbar bg-white shadow-sm">

    <div class="container">

        <a class="navbar-brand fw-bold text-primary"
           href="${pageContext.request.contextPath}/dashboard">
            BudgetTracker
        </a>

        <a href="${pageContext.request.contextPath}/dashboard"
           class="btn btn-outline-secondary ms-auto">
            Back to Dashboard
        </a>

    </div>

</nav>


<!-- Edit Transaction Content -->
<div class="container my-5">

    <div class="card shadow-sm border-0 mx-auto"
         style="max-width: 700px;">

        <div class="card-body p-4">

            <h2 class="fw-bold mb-4">
                Edit Transaction
            </h2>

            <form action="${pageContext.request.contextPath}/edit-transaction"
                  method="post">

                <!-- CSRF Token -->
                <input type="hidden"
                       name="csrfToken"
                       value="${sessionScope.csrfToken}">

                <!-- Transaction ID -->
                <input type="hidden"
                       name="transactionId"
                       value="<%= transaction.getTransactionId() %>">


                <!-- Transaction Type -->
                <div class="mb-3">

                    <label for="type" class="form-label">
                        Transaction Type
                    </label>

                    <select id="type"
                            name="type"
                            class="form-select"
                            required>

                        <option value="Income"
                            <%= "Income".equals(transaction.getType())
                                    ? "selected" : "" %>>
                            Income
                        </option>

                        <option value="Expense"
                            <%= "Expense".equals(transaction.getType())
                                    ? "selected" : "" %>>
                            Expense
                        </option>

                    </select>

                </div>


                <!-- Category -->
                <div class="mb-3">

                    <label for="category" class="form-label">
                        Category
                    </label>

                    <input type="text"
                           id="category"
                           name="category"
                           class="form-control"
                           maxlength="100"
                           value="<%= escapeHtml(transaction.getCategory()) %>"
                           required>

                </div>


                <!-- Amount -->
                <div class="mb-3">

                    <label for="amount" class="form-label">
                        Amount (¥)
                    </label>

                    <input type="number"
                           id="amount"
                           name="amount"
                           class="form-control"
                           step="0.01"
                           min="0.01"
                           max="9999999999.99"
                           value="<%= transaction.getAmount() %>"
                           required>

                </div>


                <!-- Transaction Date -->
                <div class="mb-3">

                    <label for="transactionDate" class="form-label">
                        Transaction Date
                    </label>

                    <input type="date"
                           id="transactionDate"
                           name="transactionDate"
                           class="form-control"
                           value="<%= transaction.getTransactionDate() %>"
                           required>

                </div>


                <!-- Description -->
                <div class="mb-3">

                    <label for="description" class="form-label">
                        Description (Optional)
                    </label>

                    <textarea id="description"
                              name="description"
                              class="form-control"
                              rows="3"
                              maxlength="500"><%= escapeHtml(transaction.getDescription()) %></textarea>

                </div>


                <!-- Buttons -->
                <div class="d-flex gap-2">

                    <button type="submit"
                            class="btn btn-primary">
                        Save Changes
                    </button>

                    <a href="${pageContext.request.contextPath}/dashboard"
                       class="btn btn-outline-secondary">
                        Cancel
                    </a>

                </div>

            </form>

        </div>

    </div>

</div>

</body>
</html>
