
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Personal Budget Tracker</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">

    <!-- Our custom CSS -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/style.css">
</head>

<body>

<!-- Navigation Bar -->
<nav class="navbar navbar-expand-lg navbar-light bg-white shadow-sm">
    <div class="container">

        <a class="navbar-brand fw-bold text-primary"
           href="${pageContext.request.contextPath}/">
            BudgetTracker
        </a>

        <div class="ms-auto">

<a href="${pageContext.request.contextPath}/login.jsp"
   class="btn btn-outline-primary me-2">
    Login
</a>



<a href="${pageContext.request.contextPath}/register.jsp"
   class="btn btn-primary">
    Register
</a>

        </div>

    </div>
</nav>

<!-- Welcome Section -->
<section class="hero-section text-center">
    <div class="container">

        <h1 class="display-5 fw-bold">
            Take Control of Your Finances
        </h1>

        <p class="lead text-secondary mt-3">
            Manage your income, track expenses,
            and build better financial habits.
        </p>


<a href="${pageContext.request.contextPath}/register.jsp"
   class="btn btn-primary btn-lg mt-3">
    Get Started
</a>


    </div>
</section>

<!-- Financial Summary Cards -->
<section class="container mb-5">

    <div class="row g-4">

        <div class="col-md-4">
            <div class="card shadow-sm border-0">
                <div class="card-body">
                    <h5>Total Income</h5>
                    <h3 class="text-success">¥120,000</h3>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card shadow-sm border-0">
                <div class="card-body">
                    <h5>Total Expenses</h5>
                    <h3 class="text-danger">¥75,000</h3>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card shadow-sm border-0">
                <div class="card-body">
                    <h5>Remaining Balance</h5>
                    <h3 class="text-primary">¥45,000</h3>
                </div>
            </div>
        </div>

    </div>
</section>

</body>
</html>
