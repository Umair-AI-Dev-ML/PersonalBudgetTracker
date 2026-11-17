
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.math.RoundingMode" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.time.format.TextStyle" %>
<%@ page import="com.budgettracker.model.Transaction" %>
<%@ page import="com.budgettracker.model.Budget" %>

<%!
    // Prevent HTML injection
    private String escapeHtml(String value) {
        if (value == null) return "";

        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    // Format monetary values
    private String formatMoney(BigDecimal amount) {
        if (amount == null) amount = BigDecimal.ZERO;

        return amount.setScale(
                2, RoundingMode.HALF_UP
        ).toPlainString();
    }

    // Safely output JavaScript strings
    private String jsString(String value) {
        if (value == null) value = "";

        return "\"" + value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n")
                .replace("\t", "\\t")
                .replace("<", "\\u003C")
                .replace(">", "\\u003E")
                .replace("&", "\\u0026")
                .replace("\u2028", "\\u2028")
                .replace("\u2029", "\\u2029")
                + "\"";
    }
%>

<%
    // Overall financial summary
    BigDecimal totalIncome =
            (BigDecimal) request.getAttribute("totalIncome");

    BigDecimal totalExpenses =
            (BigDecimal) request.getAttribute("totalExpenses");

    BigDecimal remainingBalance =
            (BigDecimal) request.getAttribute("remainingBalance");

    if (totalIncome == null) totalIncome = BigDecimal.ZERO;
    if (totalExpenses == null) totalExpenses = BigDecimal.ZERO;
    if (remainingBalance == null) remainingBalance = BigDecimal.ZERO;

    String balanceColor = remainingBalance.signum() < 0
            ? "text-danger" : "text-primary";


    // Monthly summary
    YearMonth selectedMonth =
            (YearMonth) request.getAttribute("selectedMonth");

    BigDecimal monthlyIncome =
            (BigDecimal) request.getAttribute("monthlyIncome");

    BigDecimal monthlyExpenses =
            (BigDecimal) request.getAttribute("monthlyExpenses");

    BigDecimal monthlyBalance =
            (BigDecimal) request.getAttribute("monthlyBalance");

    if (selectedMonth == null) selectedMonth = YearMonth.now();
    if (monthlyIncome == null) monthlyIncome = BigDecimal.ZERO;
    if (monthlyExpenses == null) monthlyExpenses = BigDecimal.ZERO;
    if (monthlyBalance == null) monthlyBalance = BigDecimal.ZERO;

    String monthlyBalanceColor = monthlyBalance.signum() < 0
            ? "text-danger" : "text-primary";

    String selectedMonthLabel =
            selectedMonth.getMonth().getDisplayName(
                    TextStyle.FULL, Locale.ENGLISH
            ) + " " + selectedMonth.getYear();


    // Saved monthly budgets
    List<Budget> budgets =
            (List<Budget>) request.getAttribute("budgets");

    if (budgets == null) {
        budgets = Collections.emptyList();
    }

    boolean budgetSaved =
            "1".equals(request.getParameter("budgetSaved"));


    // NEW: Budget tracking values
    Map<Integer, BigDecimal> budgetSpentAmounts =
            (Map<Integer, BigDecimal>) request.getAttribute(
                    "budgetSpentAmounts"
            );

    if (budgetSpentAmounts == null) {
        budgetSpentAmounts = Collections.emptyMap();
    }

    BigDecimal totalBudgetLimit =
            (BigDecimal) request.getAttribute("totalBudgetLimit");

    BigDecimal totalBudgetSpent =
            (BigDecimal) request.getAttribute("totalBudgetSpent");

    BigDecimal totalBudgetRemaining =
            (BigDecimal) request.getAttribute("totalBudgetRemaining");

    Integer overBudgetCount =
            (Integer) request.getAttribute("overBudgetCount");

    Integer budgetWarningCount =
            (Integer) request.getAttribute("budgetWarningCount");

    if (totalBudgetLimit == null)
        totalBudgetLimit = BigDecimal.ZERO;

    if (totalBudgetSpent == null)
        totalBudgetSpent = BigDecimal.ZERO;

    if (totalBudgetRemaining == null)
        totalBudgetRemaining = BigDecimal.ZERO;

    if (overBudgetCount == null)
        overBudgetCount = 0;

    if (budgetWarningCount == null)
        budgetWarningCount = 0;


    // Chart data
    List<String> categoryChartLabels =
            (List<String>) request.getAttribute("categoryChartLabels");

    List<BigDecimal> categoryChartAmounts =
            (List<BigDecimal>) request.getAttribute("categoryChartAmounts");

    List<String> monthChartLabels =
            (List<String>) request.getAttribute("monthChartLabels");

    List<BigDecimal> monthChartIncome =
            (List<BigDecimal>) request.getAttribute("monthChartIncome");

    List<BigDecimal> monthChartExpenses =
            (List<BigDecimal>) request.getAttribute("monthChartExpenses");

    if (categoryChartLabels == null)
        categoryChartLabels = Collections.emptyList();

    if (categoryChartAmounts == null)
        categoryChartAmounts = Collections.emptyList();

    if (monthChartLabels == null)
        monthChartLabels = Collections.emptyList();

    if (monthChartIncome == null)
        monthChartIncome = Collections.emptyList();

    if (monthChartExpenses == null)
        monthChartExpenses = Collections.emptyList();


    // Transaction history
    List<Transaction> transactions =
            (List<Transaction>) request.getAttribute("transactions");
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Dashboard - Personal Budget Tracker</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">

    <!-- Custom CSS -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/style.css">

    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.8/dist/chart.umd.min.js"></script>

    <style>
        .chart-container {
            position: relative;
            width: 100%;
            height: 320px;
        }

        .summary-amount {
            overflow-wrap: anywhere;
        }

        .budget-table th,
        .budget-table td {
            vertical-align: middle;
        }

        /* NEW: Budget tracking progress bars */
        .budget-progress {
            height: 14px;
            border-radius: 20px;
            background-color: #e9ecef;
            overflow: hidden;
        }

        .budget-progress .progress-bar {
            border-radius: 20px;
            transition: width 0.3s ease;
        }

        .budget-tracking-item {
            border: 1px solid #dee2e6;
            border-radius: 12px;
            padding: 18px;
            margin-bottom: 16px;
        }
    </style>

</head>

<body>

<!-- Navigation Bar -->
<nav class="navbar bg-white shadow-sm">

    <div class="container">

        <a class="navbar-brand fw-bold text-primary"
           href="${pageContext.request.contextPath}/dashboard">
            BudgetTracker
        </a>

        <form action="${pageContext.request.contextPath}/logout"
              method="post"
              class="ms-auto">

            <button type="submit"
                    class="btn btn-outline-danger">
                Logout
            </button>

        </form>

    </div>

</nav>


<!-- Main Dashboard -->
<div class="container my-5">

    <!-- Welcome Card -->
    <div class="card shadow-sm border-0">

        <div class="card-body p-4">

            <h2 class="fw-bold">
                Welcome,
                <%= escapeHtml(
                        (String) session.getAttribute("userName")
                ) %>!
            </h2>

            <p class="text-secondary">
                You have successfully accessed
                your protected dashboard.
            </p>

            <div class="alert alert-info">
                You can now start tracking
                your income and expenses.
            </div>

        </div>

    </div>


    <!-- Overall Budget Summary -->
    <div class="row g-4 mt-1">

        <!-- Total Income -->
        <div class="col-12 col-md-4">

            <div class="card shadow-sm border-0 h-100">
                <div class="card-body p-4">

                    <h5 class="text-secondary mb-3">
                        Total Income
                    </h5>

                    <h2 class="fw-bold text-success mb-0 summary-amount">
                        ¥<%= formatMoney(totalIncome) %>
                    </h2>

                </div>
            </div>

        </div>


        <!-- Total Expenses -->
        <div class="col-12 col-md-4">

            <div class="card shadow-sm border-0 h-100">
                <div class="card-body p-4">

                    <h5 class="text-secondary mb-3">
                        Total Expenses
                    </h5>

                    <h2 class="fw-bold text-danger mb-0 summary-amount">
                        ¥<%= formatMoney(totalExpenses) %>
                    </h2>

                </div>
            </div>

        </div>


        <!-- Remaining Balance -->
        <div class="col-12 col-md-4">

            <div class="card shadow-sm border-0 h-100">
                <div class="card-body p-4">

                    <h5 class="text-secondary mb-3">
                        Remaining Balance
                    </h5>

                    <h2 class="fw-bold <%= balanceColor %> mb-0 summary-amount">
                        ¥<%= formatMoney(remainingBalance) %>
                    </h2>

                </div>
            </div>

        </div>

    </div>


    <!-- Monthly Financial Summary -->
    <div class="card shadow-sm border-0 mt-4">

        <div class="card-body p-4">

            <h3 class="fw-bold mb-4">
                Monthly Financial Summary
            </h3>

            <!-- Month Selector -->
            <form action="${pageContext.request.contextPath}/dashboard"
                  method="get"
                  class="row g-3 align-items-end mb-4">

                <div class="col-12 col-md-8">

                    <label for="selectedMonth"
                           class="form-label">
                        Select Month
                    </label>

                    <input type="month"
                           id="selectedMonth"
                           name="month"
                           class="form-control"
                           value="<%= selectedMonth %>"
                           required>

                </div>

                <div class="col-12 col-md-4">

                    <button type="submit"
                            class="btn btn-primary w-100">
                        View Summary
                    </button>

                </div>

            </form>


            <h5 class="text-secondary mb-3">
                Summary for <%= selectedMonthLabel %>
            </h5>

            <div class="row g-3">

                <!-- Monthly Income -->
                <div class="col-12 col-md-4">

                    <div class="card bg-light border-0 h-100">
                        <div class="card-body p-3">

                            <h6 class="text-secondary mb-3">
                                Monthly Income
                            </h6>

                            <h3 class="fw-bold text-success mb-0 summary-amount">
                                ¥<%= formatMoney(monthlyIncome) %>
                            </h3>

                        </div>
                    </div>

                </div>


                <!-- Monthly Expenses -->
                <div class="col-12 col-md-4">

                    <div class="card bg-light border-0 h-100">
                        <div class="card-body p-3">

                            <h6 class="text-secondary mb-3">
                                Monthly Expenses
                            </h6>

                            <h3 class="fw-bold text-danger mb-0 summary-amount">
                                ¥<%= formatMoney(monthlyExpenses) %>
                            </h3>

                        </div>
                    </div>

                </div>


                <!-- Monthly Balance -->
                <div class="col-12 col-md-4">

                    <div class="card bg-light border-0 h-100">
                        <div class="card-body p-3">

                            <h6 class="text-secondary mb-3">
                                Monthly Balance
                            </h6>

                            <h3 class="fw-bold <%= monthlyBalanceColor %> mb-0 summary-amount">
                                ¥<%= formatMoney(monthlyBalance) %>
                            </h3>

                        </div>
                    </div>

                </div>

            </div>

        </div>

    </div>
    <!-- End Monthly Summary -->


    <!-- Monthly Budget Management -->
    <div class="card shadow-sm border-0 mt-4"
         id="monthlyBudgetSection">

        <div class="card-body p-4">

            <h3 class="fw-bold mb-3">
                Monthly Budget Management
            </h3>

            <p class="text-secondary">
                Set a spending limit for each category
                during <strong><%= selectedMonthLabel %></strong>.
            </p>


            <!-- Budget Saved Confirmation -->
            <% if (budgetSaved) { %>

                <div class="alert alert-success"
                     role="alert">

                    Monthly budget saved successfully!

                </div>

            <% } %>


            <!-- Save Budget Form -->
            <form action="${pageContext.request.contextPath}/save-budget"
                  method="post"
                  class="row g-3 align-items-end mb-4">

                <!-- CSRF Security Token -->
                <input type="hidden"
                       name="csrfToken"
                       value="${sessionScope.csrfToken}">

                <!-- Selected Month -->
                <input type="hidden"
                       name="month"
                       value="<%= selectedMonth %>">


                <!-- Budget Category -->
                <div class="col-12 col-md-5">

                    <label for="budgetCategory"
                           class="form-label">
                        Budget Category
                    </label>

                    <input type="text"
                           id="budgetCategory"
                           name="category"
                           class="form-control"
                           maxlength="100"
                           placeholder="Food, Transport, Shopping..."
                           required>

                </div>


                <!-- Monthly Limit -->
                <div class="col-12 col-md-4">

                    <label for="monthlyLimit"
                           class="form-label">
                        Monthly Limit (¥)
                    </label>

                    <input type="number"
                           id="monthlyLimit"
                           name="monthlyLimit"
                           class="form-control"
                           min="0.01"
                           max="9999999999.99"
                           step="0.01"
                           placeholder="20000.00"
                           required>

                </div>


                <!-- Save Budget Button -->
                <div class="col-12 col-md-3">

                    <button type="submit"
                            class="btn btn-primary w-100">
                        Save Budget
                    </button>

                </div>

            </form>


            <hr class="my-4">


            <!-- Saved Budgets -->
            <h5 class="fw-bold mb-3">
                Saved Budgets - <%= selectedMonthLabel %>
            </h5>

            <div class="table-responsive">

                <table class="table table-striped table-hover budget-table">

                    <thead class="table-light">
                    <tr>
                        <th>Category</th>
                        <th>Monthly Limit (¥)</th>
                    </tr>
                    </thead>

                    <tbody>

                    <%
                        if (!budgets.isEmpty()) {

                            for (Budget budget : budgets) {
                    %>

                    <tr>

                        <td>
                            <%= escapeHtml(
                                    budget.getCategory()
                            ) %>
                        </td>

                        <td class="fw-semibold">
                            ¥<%= formatMoney(
                                    budget.getMonthlyLimit()
                            ) %>
                        </td>

                    </tr>

                    <%
                            }

                        } else {
                    %>

                    <tr>
                        <td colspan="2"
                            class="text-center text-muted py-4">

                            No budgets saved for this month.

                        </td>
                    </tr>

                    <%
                        }
                    %>

                    </tbody>

                </table>

            </div>


            <p class="text-secondary small mb-0">
                To update an existing budget, enter the
                same category and month with a new limit,
                then click Save Budget.
            </p>

        </div>

    </div>
    <!-- End Monthly Budget Management -->


    <!-- NEW: Monthly Budget Tracking -->
    <div class="card shadow-sm border-0 mt-4"
         id="budgetTrackingSection">

        <div class="card-body p-4">

            <h3 class="fw-bold mb-3">
                Monthly Budget Tracking
            </h3>

            <p class="text-secondary">
                Check your spending against your saved
                category budgets for
                <strong><%= selectedMonthLabel %></strong>.
            </p>


            <% if (budgets.isEmpty()) { %>

                <!-- No Budgets -->
                <div class="alert alert-info">

                    No budgets are available for this month.
                    Save a budget above to start tracking spending.

                </div>

            <% } else { %>


                <!-- Budget Summary Cards -->
                <div class="row g-3 mb-4">

                    <!-- Total Budget Limit -->
                    <div class="col-12 col-md-4">

                        <div class="card bg-light border-0 h-100">

                            <div class="card-body p-3">

                                <h6 class="text-secondary">
                                    Total Budget Limit
                                </h6>

                                <h4 class="fw-bold text-primary summary-amount">
                                    ¥<%= formatMoney(totalBudgetLimit) %>
                                </h4>

                            </div>

                        </div>

                    </div>


                    <!-- Total Budget Spent -->
                    <div class="col-12 col-md-4">

                        <div class="card bg-light border-0 h-100">

                            <div class="card-body p-3">

                                <h6 class="text-secondary">
                                    Budgeted Categories Spent
                                </h6>

                                <h4 class="fw-bold text-danger summary-amount">
                                    ¥<%= formatMoney(totalBudgetSpent) %>
                                </h4>

                            </div>

                        </div>

                    </div>


                    <!-- Remaining Budget -->
                    <div class="col-12 col-md-4">

                        <div class="card bg-light border-0 h-100">

                            <div class="card-body p-3">

                                <h6 class="text-secondary">
                                    Remaining Budget
                                </h6>

                                <h4 class="fw-bold summary-amount
                                    <%= totalBudgetRemaining.signum() < 0
                                            ? "text-danger"
                                            : "text-success" %>">

                                    ¥<%= formatMoney(
                                            totalBudgetRemaining
                                    ) %>

                                </h4>

                            </div>

                        </div>

                    </div>

                </div>
                <!-- End Budget Summary Cards -->


                <!-- Overspending Alert -->
                <% if (overBudgetCount > 0) { %>

                    <div class="alert alert-danger"
                         role="alert">

                        <strong>Over Budget Alert!</strong>

                        <%= overBudgetCount %>
                        <%= overBudgetCount == 1
                                ? "category has"
                                : "categories have" %>
                        exceeded the monthly spending limit.

                    </div>

                <% } %>


                <!-- 80% Budget Warning -->
                <% if (budgetWarningCount > 0) { %>

                    <div class="alert alert-warning"
                         role="alert">

                        <strong>Budget Warning!</strong>

                        <%= budgetWarningCount %>
                        <%= budgetWarningCount == 1
                                ? "category has"
                                : "categories have" %>
                        reached at least 80% of its
                        monthly budget.

                    </div>

                <% } %>


                <!-- All Budgets Healthy -->
                <% if (overBudgetCount == 0 &&
                        budgetWarningCount == 0) { %>

                    <div class="alert alert-success"
                         role="status">

                        All your saved category budgets
                        are currently below 80% usage.

                    </div>

                <% } %>


                <h5 class="fw-bold mb-3">
                    Spending Progress by Category
                </h5>


                <!-- Category Progress Bars -->
                <% for (Budget budget : budgets) {

                    BigDecimal limit =
                            budget.getMonthlyLimit();

                    BigDecimal spent =
                            budgetSpentAmounts.getOrDefault(
                                    budget.getBudgetId(),
                                    BigDecimal.ZERO
                            );

                    if (spent == null) {
                        spent = BigDecimal.ZERO;
                    }

                    BigDecimal remaining =
                            limit.subtract(spent);

                    BigDecimal percentUsed =
                            BigDecimal.ZERO;

                    if (limit.compareTo(BigDecimal.ZERO) > 0) {

                        percentUsed = spent.multiply(
                                new BigDecimal("100")
                        ).divide(
                                limit,
                                1,
                                RoundingMode.HALF_UP
                        );
                    }

                    boolean overBudget =
                            spent.compareTo(limit) > 0;

                    boolean nearLimit =
                            !overBudget &&
                            percentUsed.compareTo(
                                    new BigDecimal("80")
                            ) >= 0;

                    String progressColor;

                    if (overBudget) {
                        progressColor = "bg-danger";
                    } else if (nearLimit) {
                        progressColor = "bg-warning";
                    } else {
                        progressColor = "bg-success";
                    }

                    // Progress bar cannot be wider than 100%
                    BigDecimal displayPercent =
                            percentUsed.min(
                                    new BigDecimal("100")
                            ).max(BigDecimal.ZERO);

                %>

                <div class="budget-tracking-item">

                    <div class="d-flex justify-content-between
                                align-items-center flex-wrap gap-2 mb-2">

                        <h6 class="fw-bold mb-0">

                            <%= escapeHtml(
                                    budget.getCategory()
                            ) %>

                        </h6>

                        <span class="text-secondary">

                            ¥<%= formatMoney(spent) %>
                            /
                            ¥<%= formatMoney(limit) %>

                        </span>

                    </div>


                    <!-- Progress Bar -->
                    <div class="progress budget-progress mb-2"
                         role="progressbar"
                         aria-label="Budget used for <%= escapeHtml(budget.getCategory()) %>"
                         aria-valuenow="<%= displayPercent.toPlainString() %>"
                         aria-valuemin="0"
                         aria-valuemax="100">

                        <div class="progress-bar <%= progressColor %>"
                             style="width: <%= displayPercent.toPlainString() %>%">
                        </div>

                    </div>


                    <div class="d-flex justify-content-between
                                flex-wrap gap-2">

                        <span class="text-secondary small">

                            <%= percentUsed.toPlainString() %>%
                            used

                        </span>


                        <% if (overBudget) { %>

                            <span class="text-danger fw-semibold small">

                                Over budget by
                                ¥<%= formatMoney(
                                        spent.subtract(limit)
                                ) %>

                            </span>

                        <% } else if (nearLimit) { %>

                            <span class="text-warning-emphasis fw-semibold small">

                                Warning: Near budget limit!
                                ¥<%= formatMoney(remaining) %>
                                remaining

                            </span>

                        <% } else { %>

                            <span class="text-success fw-semibold small">

                                ¥<%= formatMoney(remaining) %>
                                remaining

                            </span>

                        <% } %>

                    </div>

                </div>

                <% } %>
                <!-- End Category Progress Bars -->


                <p class="text-secondary small mb-0">

                    Green: below 80%.
                    Yellow: 80% to 100%.
                    Red: above 100%.

                    Spending is calculated only for the
                    selected month and matching budget categories.

                </p>

            <% } %>

        </div>

    </div>
    <!-- End Monthly Budget Tracking -->


    <!-- Financial Analytics Charts -->
    <div class="card shadow-sm border-0 mt-4">

        <div class="card-body p-4">

            <h3 class="fw-bold mb-4">
                Financial Analytics
            </h3>

            <p class="text-secondary mb-4">
                Explore expenses by category and compare
                your income and expenses over six months.
            </p>

            <div class="row g-4">

                <!-- Doughnut Chart -->
                <div class="col-12 col-lg-6">

                    <div class="card border h-100">

                        <div class="card-body p-3">

                            <h5 class="fw-semibold mb-2">
                                Expenses by Category
                            </h5>

                            <p class="text-secondary small">
                                <%= selectedMonthLabel %>
                            </p>

                            <div class="chart-container">

                                <canvas id="categoryExpenseChart"
                                        aria-label="Expenses by category chart"
                                        role="img">
                                </canvas>

                            </div>

                            <p id="categoryChartEmpty"
                               class="text-muted text-center mt-3"
                               style="display: none;">

                                No expenses recorded for this month.

                            </p>

                        </div>

                    </div>

                </div>


                <!-- Bar Chart -->
                <div class="col-12 col-lg-6">

                    <div class="card border h-100">

                        <div class="card-body p-3">

                            <h5 class="fw-semibold mb-2">
                                Monthly Income vs Expenses
                            </h5>

                            <p class="text-secondary small">
                                Selected month and previous five months
                            </p>

                            <div class="chart-container">

                                <canvas id="monthlyComparisonChart"
                                        aria-label="Monthly income and expense comparison chart"
                                        role="img">
                                </canvas>

                            </div>

                        </div>

                    </div>

                </div>

            </div>

        </div>

    </div>
    <!-- End Financial Analytics -->


    <!-- Add Transaction Form -->
    <div class="card shadow-sm border-0 mt-4">

        <div class="card-body p-4">

            <h3 class="fw-bold mb-4">
                Add New Transaction
            </h3>

            <form action="${pageContext.request.contextPath}/add-transaction"
                  method="post">

                <!-- CSRF Security Token -->
                <input type="hidden"
                       name="csrfToken"
                       value="${sessionScope.csrfToken}">


                <!-- Transaction Type -->
                <div class="mb-3">

                    <label for="type" class="form-label">
                        Transaction Type
                    </label>

                    <select id="type"
                            name="type"
                            class="form-select"
                            required>

                        <option value="">
                            Select Type
                        </option>

                        <option value="Income">
                            Income
                        </option>

                        <option value="Expense">
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
                           placeholder="Food, Salary, Transport..."
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
                           placeholder="2500.00"
                           required>

                </div>


                <!-- Transaction Date -->
                <div class="mb-3">

                    <label for="transactionDate"
                           class="form-label">
                        Transaction Date
                    </label>

                    <input type="date"
                           id="transactionDate"
                           name="transactionDate"
                           class="form-control"
                           required>

                </div>


                <!-- Description -->
                <div class="mb-3">

                    <label for="description"
                           class="form-label">
                        Description (Optional)
                    </label>

                    <textarea id="description"
                              name="description"
                              class="form-control"
                              maxlength="500"
                              rows="3"
                              placeholder="Enter description"></textarea>

                </div>


                <!-- Save Transaction -->
                <button type="submit"
                        class="btn btn-primary w-100">

                    Save Transaction

                </button>

            </form>

        </div>

    </div>
    <!-- End Add Transaction -->


    <!-- Transaction History -->
    <div class="card shadow-sm border-0 mt-4">

        <div class="card-body p-4">

            <div class="d-flex justify-content-between
                        align-items-center flex-wrap gap-3 mb-4">

                <h3 class="fw-bold mb-0">
                    Transaction History
                </h3>

                <!-- Export CSV -->
                <a href="${pageContext.request.contextPath}/export-transactions"
                   class="btn btn-success">

                    Export CSV

                </a>

            </div>


            <!-- Search and Filters -->
            <div class="row g-3 mb-4">

                <div class="col-12 col-md-7">

                    <label for="searchTransaction"
                           class="form-label">
                        Search by Category
                    </label>

                    <input type="search"
                           id="searchTransaction"
                           class="form-control"
                           placeholder="Search Food, Salary, Transport...">

                </div>


                <div class="col-12 col-md-5">

                    <label for="filterType"
                           class="form-label">
                        Filter by Type
                    </label>

                    <select id="filterType"
                            class="form-select">

                        <option value="All">
                            All Transactions
                        </option>

                        <option value="Income">
                            Income Only
                        </option>

                        <option value="Expense">
                            Expenses Only
                        </option>

                    </select>

                </div>


                <div class="col-12 col-md-6">

                    <label for="fromDate"
                           class="form-label">
                        From Date
                    </label>

                    <input type="date"
                           id="fromDate"
                           class="form-control">

                </div>


                <div class="col-12 col-md-6">

                    <label for="toDate"
                           class="form-label">
                        To Date
                    </label>

                    <input type="date"
                           id="toDate"
                           class="form-control">

                </div>


                <div class="col-12">

                    <button type="button"
                            id="clearFilters"
                            class="btn btn-outline-secondary">

                        Clear All Filters

                    </button>

                </div>

            </div>


            <!-- Transaction Table -->
            <div class="table-responsive">

                <table class="table table-striped table-hover align-middle"
                       id="transactionTable">

                    <thead class="table-light">

                    <tr>
                        <th>Date</th>
                        <th>Category</th>
                        <th>Type</th>
                        <th>Amount (¥)</th>
                        <th>Description</th>
                        <th>Actions</th>
                    </tr>

                    </thead>

                    <tbody>

                    <%
                        if (transactions != null &&
                                !transactions.isEmpty()) {

                            for (Transaction transaction : transactions) {
                    %>

                    <tr class="transaction-row"
                        data-type="<%= escapeHtml(
                                transaction.getType()
                        ) %>"
                        data-date="<%= transaction.getTransactionDate() %>">

                        <!-- Date -->
                        <td>
                            <%= transaction.getTransactionDate() %>
                        </td>

                        <!-- Category -->
                        <td class="transaction-category">
                            <%= escapeHtml(
                                    transaction.getCategory()
                            ) %>
                        </td>

                        <!-- Type -->
                        <td>

                            <% if ("Income".equals(
                                    transaction.getType())) { %>

                                <span class="badge bg-success">
                                    Income
                                </span>

                            <% } else { %>

                                <span class="badge bg-danger">
                                    Expense
                                </span>

                            <% } %>

                        </td>

                        <!-- Amount -->
                        <td>
                            <%= transaction.getAmount() %>
                        </td>

                        <!-- Description -->
                        <td>
                            <%= escapeHtml(
                                    transaction.getDescription()
                            ) %>
                        </td>

                        <!-- Edit and Delete -->
                        <td>

                            <div class="d-flex gap-2">

                                <!-- Edit -->
                                <a href="${pageContext.request.contextPath}/edit-transaction?transactionId=<%= transaction.getTransactionId() %>"
                                   class="btn btn-outline-primary btn-sm">

                                    Edit

                                </a>


                                <!-- Delete -->
                                <form action="${pageContext.request.contextPath}/delete-transaction"
                                      method="post"
                                      onsubmit="return confirm('Are you sure you want to delete this transaction? This action cannot be undone.');">

                                    <input type="hidden"
                                           name="csrfToken"
                                           value="${sessionScope.csrfToken}">

                                    <input type="hidden"
                                           name="transactionId"
                                           value="<%= transaction.getTransactionId() %>">

                                    <button type="submit"
                                            class="btn btn-outline-danger btn-sm">

                                        Delete

                                    </button>

                                </form>

                            </div>

                        </td>

                    </tr>

                    <%
                            }

                        } else {
                    %>

                    <tr>

                        <td colspan="6"
                            class="text-center text-muted py-4">

                            No transactions found.

                        </td>

                    </tr>

                    <%
                        }
                    %>


                    <!-- No Matching Filter Results -->
                    <tr id="noMatchingTransactions"
                        style="display: none;">

                        <td colspan="6"
                            class="text-center text-muted py-4">

                            No matching transactions found.

                        </td>

                    </tr>

                    </tbody>

                </table>

            </div>

        </div>

    </div>
    <!-- End Transaction History -->

</div>
<!-- End Main Dashboard -->


<!-- Chart Data From DashboardServlet -->
<script>

    const categoryLabels = [
        <% for (int i = 0; i < categoryChartLabels.size(); i++) { %>
            <%= i > 0 ? "," : "" %>
            <%= jsString(categoryChartLabels.get(i)) %>
        <% } %>
    ];

    const categoryAmounts = [
        <% for (int i = 0; i < categoryChartAmounts.size(); i++) { %>
            <%= i > 0 ? "," : "" %>
            <%= categoryChartAmounts.get(i).toPlainString() %>
        <% } %>
    ];

    const monthLabels = [
        <% for (int i = 0; i < monthChartLabels.size(); i++) { %>
            <%= i > 0 ? "," : "" %>
            <%= jsString(monthChartLabels.get(i)) %>
        <% } %>
    ];

    const monthIncomeAmounts = [
        <% for (int i = 0; i < monthChartIncome.size(); i++) { %>
            <%= i > 0 ? "," : "" %>
            <%= monthChartIncome.get(i).toPlainString() %>
        <% } %>
    ];

    const monthExpenseAmounts = [
        <% for (int i = 0; i < monthChartExpenses.size(); i++) { %>
            <%= i > 0 ? "," : "" %>
            <%= monthChartExpenses.get(i).toPlainString() %>
        <% } %>
    ];

</script>


<!-- Chart.js -->
<script>

    if (typeof Chart !== "undefined") {

        // Expenses by Category
        const categoryCanvas =
                document.getElementById("categoryExpenseChart");

        const categoryChartEmpty =
                document.getElementById("categoryChartEmpty");

        const totalCategoryExpenses =
                categoryAmounts.reduce(
                        (sum, amount) => sum + amount, 0
                );

        if (totalCategoryExpenses > 0) {

            const categoryColors = [
                "#2563EB",
                "#F97316",
                "#16A34A",
                "#9333EA",
                "#E11D48",
                "#0891B2",
                "#EAB308",
                "#64748B"
            ];

            new Chart(categoryCanvas, {

                type: "doughnut",

                data: {
                    labels: categoryLabels,

                    datasets: [{
                        label: "Expenses (¥)",

                        data: categoryAmounts,

                        backgroundColor: categoryLabels.map(
                                (_, index) =>
                                        categoryColors[
                                            index % categoryColors.length
                                        ]
                        ),

                        borderColor: "#FFFFFF",
                        borderWidth: 2,
                        hoverOffset: 6
                    }]
                },

                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    cutout: "60%",

                    plugins: {
                        legend: {
                            position: "bottom"
                        },

                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    return context.label + ": ¥" +
                                            Number(context.parsed)
                                                    .toLocaleString();
                                }
                            }
                        }
                    }
                }
            });

        } else {

            categoryCanvas.style.display = "none";
            categoryChartEmpty.style.display = "";
        }


        // Monthly Income vs Expenses
        const monthlyCanvas =
                document.getElementById("monthlyComparisonChart");

        new Chart(monthlyCanvas, {

            type: "bar",

            data: {
                labels: monthLabels,

                datasets: [
                    {
                        label: "Income",
                        data: monthIncomeAmounts,
                        backgroundColor: "#16A34A",
                        borderRadius: 5
                    },

                    {
                        label: "Expenses",
                        data: monthExpenseAmounts,
                        backgroundColor: "#DC3545",
                        borderRadius: 5
                    }
                ]
            },

            options: {
                responsive: true,
                maintainAspectRatio: false,

                plugins: {
                    legend: {
                        position: "bottom"
                    },

                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return context.dataset.label +
                                        ": ¥" +
                                        Number(context.parsed.y)
                                                .toLocaleString();
                            }
                        }
                    }
                },

                scales: {
                    y: {
                        beginAtZero: true,

                        ticks: {
                            callback: function(value) {
                                return "¥" +
                                        Number(value).toLocaleString();
                            }
                        }
                    }
                }
            }
        });

    } else {

        console.error(
                "Chart.js did not load. Check your internet connection."
        );
    }

</script>


<!-- Transaction Search and Filter -->
<script>

    const searchTransaction =
            document.getElementById("searchTransaction");

    const filterType =
            document.getElementById("filterType");

    const fromDate =
            document.getElementById("fromDate");

    const toDate =
            document.getElementById("toDate");

    const clearFilters =
            document.getElementById("clearFilters");

    const transactionRows =
            document.querySelectorAll(".transaction-row");

    const noMatchingTransactions =
            document.getElementById("noMatchingTransactions");


    function filterTransactions() {

        const searchText =
                searchTransaction.value.trim().toLowerCase();

        const selectedType =
                filterType.value;

        const startDate =
                fromDate.value;

        const endDate =
                toDate.value;

        let visibleCount = 0;

        transactionRows.forEach(function(row) {

            const category =
                    row.querySelector(".transaction-category")
                            .textContent.toLowerCase();

            const type = row.dataset.type;

            const transactionDate = row.dataset.date;

            const matchesSearch =
                    category.includes(searchText);

            const matchesType =
                    selectedType === "All" ||
                    type === selectedType;

            const matchesFromDate =
                    startDate === "" ||
                    transactionDate >= startDate;

            const matchesToDate =
                    endDate === "" ||
                    transactionDate <= endDate;

            if (matchesSearch &&
                    matchesType &&
                    matchesFromDate &&
                    matchesToDate) {

                row.style.display = "";
                visibleCount++;

            } else {

                row.style.display = "none";
            }
        });

        if (transactionRows.length > 0 &&
                visibleCount === 0) {

            noMatchingTransactions.style.display = "";

        } else {

            noMatchingTransactions.style.display = "none";
        }
    }


    searchTransaction.addEventListener(
            "input", filterTransactions
    );

    filterType.addEventListener(
            "change", filterTransactions
    );

    fromDate.addEventListener(
            "change", filterTransactions
    );

    toDate.addEventListener(
            "change", filterTransactions
    );


    clearFilters.addEventListener("click", function() {

        searchTransaction.value = "";
        filterType.value = "All";
        fromDate.value = "";
        toDate.value = "";

        filterTransactions();
    });

</script>

</body>
</html>
