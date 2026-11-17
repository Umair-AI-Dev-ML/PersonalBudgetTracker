
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Register - Personal Budget Tracker</title>

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

<!-- Registration Form -->
<div class="container my-5">

    <div class="row justify-content-center">

        <div class="col-md-6 col-lg-5">

            <div class="card shadow-sm border-0">

                <div class="card-body p-4">

                    <h2 class="text-center fw-bold mb-3">
                        Create Account
                    </h2>

                    <p class="text-center text-muted mb-4">
                        Start managing your finances today.
                    </p>


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

<form id="registerForm"
      action="${pageContext.request.contextPath}/register"
      method="post">

                        <div class="mb-3">
                            <label for="name" class="form-label">
                                Full Name
                            </label>
                            <input type="text"
                                   class="form-control"
                                   id="name"
                                   name="name"
                                   required>
                        </div>

                        <div class="mb-3">
                            <label for="email" class="form-label">
                                Email Address
                            </label>
                            <input type="email"
                                   class="form-control"
                                   id="email"
                                   name="email"
                                   required>
                        </div>

                        <div class="mb-3">
                            <label for="password" class="form-label">
                                Password
                            </label>
                            <input type="password"
                                   class="form-control"
                                   id="password"
                                   name="password"
                                   minlength="8"
                                   required>
                        </div>

                        <div class="mb-3">
                            <label for="confirmPassword" class="form-label">
                                Confirm Password
                            </label>
                            <input type="password"
                                   class="form-control"
                                   id="confirmPassword"
                                   name="confirmPassword"
                                   minlength="8"
                                   required>
                        </div>

                        <div id="passwordError"
                             class="text-danger mb-3"
                             role="alert"></div>

                        <button type="submit"
                                class="btn btn-primary w-100">
                            Register
                        </button>

                    </form>


<p class="text-center mt-4 mb-0">
    Already have an account?

    <a href="${pageContext.request.contextPath}/login.jsp">
        Login here
    </a>
</p>


                </div>
            </div>

        </div>
    </div>
</div>


<script>
    document.getElementById("registerForm")
        .addEventListener("submit", function(event) {

            const password =
                document.getElementById("password").value;

            const confirmPassword =
                document.getElementById("confirmPassword").value;

            const error =
                document.getElementById("passwordError");

            if (password !== confirmPassword) {
                event.preventDefault();
                error.textContent = "Passwords do not match.";
                return;
            }

            error.textContent = "";
        });
</script>


</body>
</html>
