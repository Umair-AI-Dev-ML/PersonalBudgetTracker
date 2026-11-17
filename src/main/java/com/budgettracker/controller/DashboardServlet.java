
package com.budgettracker.controller;

import com.budgettracker.dao.TransactionDAO;
import com.budgettracker.dao.BudgetDAO;

import com.budgettracker.model.Transaction;
import com.budgettracker.model.Budget;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.DateTimeException;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        // Prevent browser caching of protected content
        response.setHeader("Cache-Control", "no-store");

        // Check whether the user is logged in
        HttpSession session = request.getSession(false);

        if (session == null ||
                !(session.getAttribute("userId") instanceof Integer)) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp"
            );
            return;
        }

        // Generate CSRF security token if missing
        if (session.getAttribute("csrfToken") == null) {

            String csrfToken =
                    java.util.UUID.randomUUID().toString();

            session.setAttribute("csrfToken", csrfToken);
        }

        // Logged-in user ID
        int userId = (Integer) session.getAttribute("userId");

        // Default to the current month
        YearMonth selectedMonth = YearMonth.now();

        String monthParameter = request.getParameter("month");

        if (monthParameter != null &&
                !monthParameter.isBlank()) {

            try {

                // Expected format: YYYY-MM
                if (!monthParameter.matches(
                        "\\d{4}-(0[1-9]|1[0-2])")) {

                    throw new DateTimeException(
                            "Invalid month format"
                    );
                }

                selectedMonth = YearMonth.parse(monthParameter);

            } catch (DateTimeException e) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid month. Use YYYY-MM."
                );
                return;
            }
        }

        // Create DAO objects
        TransactionDAO transactionDAO = new TransactionDAO();
        BudgetDAO budgetDAO = new BudgetDAO();

        try {

            // Retrieve logged-in user's transactions
            List<Transaction> transactions =
                    transactionDAO.getTransactionsByUserId(userId);

            request.setAttribute(
                    "transactions", transactions
            );

            // Retrieve budgets for selected month
            List<Budget> budgets =
                    budgetDAO.getBudgetsByUserAndMonth(
                            userId,
                            selectedMonth.getMonthValue(),
                            selectedMonth.getYear()
                    );

            request.setAttribute(
                    "budgets", budgets
            );

            // Overall financial totals
            BigDecimal totalIncome = BigDecimal.ZERO;
            BigDecimal totalExpenses = BigDecimal.ZERO;

            // Selected month financial totals
            BigDecimal monthlyIncome = BigDecimal.ZERO;
            BigDecimal monthlyExpenses = BigDecimal.ZERO;

            // Expenses grouped by category
            Map<String, BigDecimal> categoryExpenses =
                    new LinkedHashMap<>();

            // Six months of income and expenses
            Map<YearMonth, BigDecimal> sixMonthIncome =
                    new LinkedHashMap<>();

            Map<YearMonth, BigDecimal> sixMonthExpenses =
                    new LinkedHashMap<>();

            // Prepare six months ending with selected month
            for (int i = 5; i >= 0; i--) {

                YearMonth month =
                        selectedMonth.minusMonths(i);

                sixMonthIncome.put(
                        month, BigDecimal.ZERO
                );

                sixMonthExpenses.put(
                        month, BigDecimal.ZERO
                );
            }

            // Calculate financial totals and chart data
            for (Transaction transaction : transactions) {

                BigDecimal amount = transaction.getAmount();
                String type = transaction.getType();

                // Overall totals
                if ("Income".equals(type)) {

                    totalIncome = totalIncome.add(amount);

                } else if ("Expense".equals(type)) {

                    totalExpenses = totalExpenses.add(amount);
                }

                // Skip date-based calculations if date missing
                if (transaction.getTransactionDate() == null) {
                    continue;
                }

                YearMonth transactionMonth =
                        YearMonth.from(
                                transaction.getTransactionDate()
                        );

                // Selected month totals
                if (transactionMonth.equals(selectedMonth)) {

                    if ("Income".equals(type)) {

                        monthlyIncome =
                                monthlyIncome.add(amount);

                    } else if ("Expense".equals(type)) {

                        monthlyExpenses =
                                monthlyExpenses.add(amount);

                        // Group expenses by category
                        String category =
                                transaction.getCategory();

                        if (category == null ||
                                category.isBlank()) {

                            category = "Other";

                        } else {

                            category = category.trim();
                        }

                        categoryExpenses.merge(
                                category,
                                amount,
                                BigDecimal::add
                        );
                    }
                }

                // Six-month income data
                if ("Income".equals(type) &&
                        sixMonthIncome.containsKey(transactionMonth)) {

                    sixMonthIncome.merge(
                            transactionMonth,
                            amount,
                            BigDecimal::add
                    );

                } else if ("Expense".equals(type) &&
                        sixMonthExpenses.containsKey(transactionMonth)) {

                    // Six-month expense data
                    sixMonthExpenses.merge(
                            transactionMonth,
                            amount,
                            BigDecimal::add
                    );
                }
            }

            // Calculate overall balance
            BigDecimal remainingBalance =
                    totalIncome.subtract(totalExpenses);

            // Calculate monthly balance
            BigDecimal monthlyBalance =
                    monthlyIncome.subtract(monthlyExpenses);

            // Send overall summary
            request.setAttribute(
                    "totalIncome", totalIncome
            );

            request.setAttribute(
                    "totalExpenses", totalExpenses
            );

            request.setAttribute(
                    "remainingBalance", remainingBalance
            );

            // Send monthly summary
            request.setAttribute(
                    "selectedMonth", selectedMonth
            );

            request.setAttribute(
                    "monthlyIncome", monthlyIncome
            );

            request.setAttribute(
                    "monthlyExpenses", monthlyExpenses
            );

            request.setAttribute(
                    "monthlyBalance", monthlyBalance
            );

            // Preserve category expense data
            request.setAttribute(
                    "categoryExpenses", categoryExpenses
            );


            // ---------------------------------------
            // NEW: MONTHLY BUDGET TRACKING
            // ---------------------------------------

            // Normalize category names for matching
            // Example: "Food" and "food" match
            Map<String, BigDecimal> normalizedExpenses =
                    new LinkedHashMap<>();

            for (Map.Entry<String, BigDecimal> entry
                    : categoryExpenses.entrySet()) {

                String normalizedCategory =
                        entry.getKey()
                                .trim()
                                .toLowerCase(Locale.ROOT);

                normalizedExpenses.merge(
                        normalizedCategory,
                        entry.getValue(),
                        BigDecimal::add
                );
            }

            // Amount spent for each saved budget ID
            Map<Integer, BigDecimal> budgetSpentAmounts =
                    new LinkedHashMap<>();

            // Total of all saved budget limits
            BigDecimal totalBudgetLimit = BigDecimal.ZERO;

            // Spending within budgeted categories
            BigDecimal totalBudgetSpent = BigDecimal.ZERO;

            // Number of categories exceeding their budgets
            int overBudgetCount = 0;

            // Number of categories at or above 80%
            // but not exceeding their budgets
            int budgetWarningCount = 0;

            for (Budget budget : budgets) {

                String normalizedCategory =
                        budget.getCategory()
                                .trim()
                                .toLowerCase(Locale.ROOT);

                BigDecimal spent =
                        normalizedExpenses.getOrDefault(
                                normalizedCategory,
                                BigDecimal.ZERO
                        );

                BigDecimal limit = budget.getMonthlyLimit();

                // Store spending using unique budget ID
                budgetSpentAmounts.put(
                        budget.getBudgetId(),
                        spent
                );

                totalBudgetLimit =
                        totalBudgetLimit.add(limit);

                totalBudgetSpent =
                        totalBudgetSpent.add(spent);

                // Over budget if spending exceeds limit
                if (spent.compareTo(limit) > 0) {

                    overBudgetCount++;

                } else {

                    // Warning when spending is at least
                    // 80% of the category budget
                    BigDecimal warningThreshold =
                            limit.multiply(
                                    new BigDecimal("0.80")
                            );

                    if (spent.compareTo(warningThreshold) >= 0) {

                        budgetWarningCount++;
                    }
                }
            }

            // Remaining amount across saved budgets
            BigDecimal totalBudgetRemaining =
                    totalBudgetLimit.subtract(totalBudgetSpent);

            // Send budget tracking data to JSP
            request.setAttribute(
                    "budgetSpentAmounts",
                    budgetSpentAmounts
            );

            request.setAttribute(
                    "totalBudgetLimit",
                    totalBudgetLimit
            );

            request.setAttribute(
                    "totalBudgetSpent",
                    totalBudgetSpent
            );

            request.setAttribute(
                    "totalBudgetRemaining",
                    totalBudgetRemaining
            );

            request.setAttribute(
                    "overBudgetCount",
                    overBudgetCount
            );

            request.setAttribute(
                    "budgetWarningCount",
                    budgetWarningCount
            );


            // ---------------------------------------
            // EXISTING: EXPENSE CATEGORY CHART
            // ---------------------------------------

            List<String> categoryLabels =
                    new ArrayList<>();

            List<BigDecimal> categoryAmounts =
                    new ArrayList<>();

            for (Map.Entry<String, BigDecimal> entry
                    : categoryExpenses.entrySet()) {

                categoryLabels.add(entry.getKey());

                categoryAmounts.add(entry.getValue());
            }

            request.setAttribute(
                    "categoryChartLabels",
                    categoryLabels
            );

            request.setAttribute(
                    "categoryChartAmounts",
                    categoryAmounts
            );


            // ---------------------------------------
            // EXISTING: SIX-MONTH COMPARISON CHART
            // ---------------------------------------

            List<String> monthChartLabels =
                    new ArrayList<>();

            List<BigDecimal> monthChartIncome =
                    new ArrayList<>();

            List<BigDecimal> monthChartExpenses =
                    new ArrayList<>();

            DateTimeFormatter monthFormatter =
                    DateTimeFormatter.ofPattern("MMM yyyy");

            for (YearMonth month : sixMonthIncome.keySet()) {

                monthChartLabels.add(
                        month.format(monthFormatter)
                );

                monthChartIncome.add(
                        sixMonthIncome.get(month)
                );

                monthChartExpenses.add(
                        sixMonthExpenses.get(month)
                );
            }

            request.setAttribute(
                    "monthChartLabels",
                    monthChartLabels
            );

            request.setAttribute(
                    "monthChartIncome",
                    monthChartIncome
            );

            request.setAttribute(
                    "monthChartExpenses",
                    monthChartExpenses
            );

        } catch (SQLException e) {

            getServletContext().log(
                    "Error loading dashboard transactions and budgets",
                    e
            );

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to load dashboard information."
            );
            return;
        }

        // Display protected dashboard
        request.getRequestDispatcher(
                "/WEB-INF/views/dashboard.jsp"
        ).forward(request, response);
    }
}
