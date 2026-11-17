
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Login - Personal Budget Tracker</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">

    <!-- Custom CSS -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/style.css">
</head>

<body>

<!-- Navigation Bar -->
<nav class="navbar navbar-expand-lg bg-white shadow-sm">
    <div class="container">

        <a class="navbar-brand fw-bold text-primary"
           href="${pageContext.request.contextPath}/">
            BudgetTracker
        </a>

    </div>
</nav>

<!-- Login Section -->
<div class="container my-5">

    <div class="row justify-content-center">

        <div class="col-md-6 col-lg-5">

            <div class="card shadow-sm border-0">

                <div class="card-body p-4">

                    <h2 class="text-center fw-bold mb-3">
                        Welcome Back
                    </h2>

                    <p class="text-center text-muted mb-4">
                        Login to manage your personal finances.
                    </p>

                    <!-- Login Form -->


<!-- Display Login Error Message -->
<%
    String errorMessage =
            (String) request.getAttribute("errorMessage");

    if (errorMessage != null) {
%>
    <div class="alert alert-danger" role="alert">
        <%= errorMessage
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;") %>
    </div>
<%
    }
%>

<!-- Login Form -->
<form id="loginForm"
      action="${pageContext.request.contextPath}/login"
      method="post">



                        <!-- Email -->
                        <div class="mb-3">

                            <label for="email" class="form-label">
                                Email Address
                            </label>

                            <input type="email"
                                   class="form-control"
                                   id="email"
                                   name="email"
                                   placeholder="Enter your email"
                                   autocomplete="email"
                                   required>

                        </div>

                        <!-- Password -->
                        <div class="mb-3">

                            <label for="password" class="form-label">
                                Password
                            </label>

                            <input type="password"
                                   class="form-control"
                                   id="password"
                                   name="password"
                                   placeholder="Enter your password"
                                   autocomplete="current-password"
                                   required>

                        </div>

                        <!-- Login Button -->
                        <button type="submit"
                                class="btn btn-primary w-100">
                            Login
                        </button>

                    </form>

                    <p class="text-center mt-4 mb-0">
                        Don't have an account?

                        <a href="${pageContext.request.contextPath}/register.jsp">
                            Register here
                        </a>
                    </p>

                </div>

            </div>

        </div>

    </div>

</div>

<!-- Temporary frontend testing -->

</body>
</html>
