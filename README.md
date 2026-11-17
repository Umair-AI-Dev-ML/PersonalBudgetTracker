
# Personal Budget Tracker

A full-stack Java web application for managing personal finances, tracking income and expenses, and monitoring monthly budgets.

## Features

- User registration, login, and logout
- Password hashing using PBKDF2 with SHA-256
- Secure user sessions
- Add, edit, and delete transactions
- Income and expense tracking
- Monthly financial summaries
- Category-based monthly budgets
- Budget progress bars and spending warnings
- Interactive financial charts
- Search and filter transactions
- Export transaction history to CSV
- Responsive dashboard design

## Technologies Used

| Technology | Purpose |
|------------|---------|
| Java 17 | Backend development |
| Jakarta Servlets | Request handling |
| JSP | Dynamic web pages |
| MySQL | Database |
| JDBC | Database connectivity |
| Maven | Dependency management |
| Apache Tomcat 10.1 | Application server |
| Bootstrap 5 | Responsive interface |
| Chart.js | Financial charts |
| HTML, CSS, JavaScript | Frontend development |

## Project Structure

```text
PersonalBudgetTracker/
├── src/
│   └── main/
│       ├── java/com/budgettracker/
│       │   ├── controller/
│       │   ├── dao/
│       │   ├── model/
│       │   └── util/
│       └── webapp/
│           ├── css/
│           ├── WEB-INF/
│           ├── index.jsp
│           ├── login.jsp
│           └── register.jsp
├── pom.xml
└── README.md
```

## Getting Started

### Requirements

- Java 17
- Apache Maven
- MySQL
- Apache Tomcat 10.1
- IntelliJ IDEA or another Java IDE

### Local Setup

1. Clone this repository.
2. Create a MySQL database named `personal_budget_tracker`.
3. Set up the required `users`, `transactions`, and `budgets` tables.
4. Configure the MySQL database user and permissions.
5. Set the `BUDGET_DB_PASSWORD` environment variable.
6. Build the Maven project.
7. Deploy the WAR application to Tomcat 10.1.
8. Open `http://localhost:8080/PersonalBudgetTracker/`.

Note: A database setup SQL script will be added to make installation easier.

## Security

- PBKDF2 password hashing with random salts
- Prepared SQL statements
- User-specific transaction and budget access
- Session-based authentication
- CSRF protection for financial transactions
- Database credentials loaded from an environment variable

This project currently runs locally and is not deployed as a public website.

## Project Status

Developed and tested locally using IntelliJ IDEA, Apache Tomcat, and MySQL.

## Author

[Umair-AI-Dev-ML](https://github.com/Umair-AI-Dev-ML)
