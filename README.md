# Personal Budget Tracker

### Full-Stack Java Web Application

A personal finance management web application developed using
Java 17, Jakarta Servlets, JSP, MySQL, Maven, and Apache Tomcat.

Personal Budget Tracker helps users manage income and expenses,
monitor monthly spending, create category-based budgets, and
visualize financial activity through interactive charts.

The project demonstrates full-stack Java web development,
database integration, user authentication, CRUD operations,
and responsive frontend design.

---

## Application Screenshots

### 1. Dashboard Overview

The dashboard displays total income, total expenses, remaining
balance, and selected-month financial summaries.

![Dashboard Overview](Screenshot%202026-11-17%20at%2022.18.13.png)

### 2. Monthly Budget Management

Users can create and update monthly spending limits for
different expense categories and monitor budget utilization.

![Monthly Budget Management](Screenshot%202026-11-17%20at%2022.15.55.png)

### 3. Financial Analytics

Interactive charts visualize spending by category and compare
monthly income and expenses over a six-month period.

![Financial Analytics](Screenshot%202026-11-17%20at%2022.16.16.png)

### 4. Transaction Management

Users can add transactions, search and filter transaction
history, edit or delete records, and export data to CSV.

![Transaction Management](Screenshot%202026-11-17%20at%2022.17.20.png)

---

## Key Features

### User Authentication
- User registration and login
- Password hashing using PBKDF2 with SHA-256
- Session-based authentication
- Logout functionality
- Protected dashboard access
- Session inactivity timeout

### Income and Expense Management
- Add income and expense transactions
- Edit existing transactions
- Delete transactions
- Organize transactions by category
- Record transaction dates and descriptions
- Calculate income, expenses, and remaining balance

### Monthly Budget Management
- Create category-based monthly budgets
- Update existing budget limits
- Monitor spending against saved budgets
- Display remaining budget amounts
- Track budget utilization with progress bars
- Show warnings as spending approaches budget limits
- Identify categories that exceed their budgets

### Financial Analytics
- Interactive expense distribution doughnut chart
- Six-month income versus expense bar chart
- Monthly financial summaries
- Category-based expense analysis

### Transaction History
- View transaction records
- Search transactions by category
- Filter income and expense transactions
- Filter transactions by date range
- Edit and delete transaction records
- Export transaction history to CSV

### User Interface
- Responsive layout
- Bootstrap-based components
- Dashboard summary cards
- Consistent visual design
- Interactive forms and charts

---

## Technology Stack

| Technology | Purpose |
|------------|---------|
| Java 17 | Backend application logic |
| Jakarta Servlets | HTTP request handling |
| JSP | Dynamic web pages |
| MySQL | Relational database |
| JDBC | Database connectivity |
| Maven | Dependency management and build |
| Apache Tomcat 10.1 | Web application server |
| Bootstrap 5 | Responsive interface |
| Chart.js | Interactive financial charts |
| HTML5 | Page structure |
| CSS3 | Styling and layout |
| JavaScript | Client-side interactivity |
| IntelliJ IDEA | Development environment |
| GitHub | Source code hosting |

---

## Application Architecture

The application follows a layered Java web architecture.

- **Controller Layer:** Jakarta Servlets process HTTP requests,
  perform validation, and coordinate application operations.
- **DAO Layer:** Data Access Objects execute SQL queries
  through JDBC.
- **Model Layer:** Java classes represent users, transactions,
  and budgets.
- **View Layer:** JSP pages, Bootstrap, CSS, and JavaScript
  provide the user interface.
- **Database Layer:** MySQL stores application data.

### Project Structure

```text
PersonalBudgetTracker/
|
|-- src/
|   |-- main/
|   |   |-- java/com/budgettracker/
|   |   |   |-- controller/
|   |   |   |-- dao/
|   |   |   |-- model/
|   |   |   |-- util/
|   |   |
|   |   |-- webapp/
|   |       |-- css/
|   |       |-- images/
|   |       |-- js/
|   |       |-- WEB-INF/
|   |       |   |-- views/
|   |       |   |-- web.xml
|   |       |-- index.jsp
|   |       |-- login.jsp
|   |       |-- register.jsp
|
|-- pom.xml
|-- .gitignore
|-- README.md
```

---

## Database Design

The application uses MySQL with three main tables.

| Table | Description |
|-------|-------------|
| users | Registered account information and password hashes |
| transactions | User income and expense records |
| budgets | Category-based monthly spending limits |

Transactions and budgets are associated with individual
user accounts through user IDs.

The budgets table includes a uniqueness constraint to prevent
duplicate category budgets for the same user, month, and year.

---

## Security Features

The application includes:

- PBKDF2WithHmacSHA256 password hashing
- Random password salts
- Prepared SQL statements
- Session-based authentication
- Session renewal following successful login
- Session inactivity timeout
- CSRF tokens for financial operations
- User-specific database operations
- Environment-variable-based database credentials
- Restricted application database permissions
- Logout and session invalidation

**Security note:** This project has been developed and tested
locally. Additional security review, HTTPS configuration,
and deployment hardening are required before public hosting.

---

## Getting Started

### Prerequisites

Install the following:

- Java Development Kit 17
- Apache Maven
- MySQL Server
- Apache Tomcat 10.1
- IntelliJ IDEA or another compatible Java IDE

### 1. Clone the Repository

```bash
git clone https://github.com/Umair-AI-Dev-ML/PersonalBudgetTracker.git
```

### 2. Configure MySQL

Create a database named:

```sql
CREATE DATABASE personal_budget_tracker;
```

The application requires the following tables:

- users
- transactions
- budgets

The database schema must be configured before running the
application. A database setup script is planned for a
future repository update.

### 3. Configure Database Access

The application uses the following local connection:

```text
jdbc:mysql://localhost:3306/personal_budget_tracker
```

The default application database username is:

```text
budget_app
```

Configure the MySQL user with appropriate database permissions.

Set the following environment variable in the application
server environment:

```text
BUDGET_DB_PASSWORD
```

Set its value to your own database password.

Never commit database passwords or other secrets to GitHub.

### 4. Build the Application

From the project directory, run:

```bash
mvn clean package
```

### 5. Deploy to Apache Tomcat

Deploy the generated WAR application to Apache Tomcat 10.1.

Use the application context path:

```text
/PersonalBudgetTracker
```

### 6. Open the Application

After starting Tomcat, open:

http://localhost:8080/PersonalBudgetTracker/

Register a user account, log in, and access the dashboard.

---

## Development and Testing

The application was developed and tested locally using:

- IntelliJ IDEA
- Java 17
- Apache Tomcat 10.1
- MySQL Server
- MySQL Workbench
- Brave Browser

Core workflows tested include:

- Registration and authentication
- Transaction creation and updates
- Transaction deletion
- Monthly financial summaries
- Budget creation and updates
- Budget tracking
- Financial analytics
- Transaction filtering and CSV export

---

## Current Project Status

**Status: Local development completed**

The application works locally with MySQL and Apache Tomcat.

The source code and application screenshots are available in
this GitHub repository.

A publicly hosted live demonstration is not currently available.

### Planned Improvements

- Database initialization SQL script
- Additional automated testing
- Further deployment security checks
- Public deployment with HTTPS
- Additional user interface improvements

---

## Author

**GitHub:** [Umair-AI-Dev-ML](https://github.com/Umair-AI-Dev-ML)

Developed as a hands-on full-stack Java web development project.

---

## License

No open-source license has been added to this repository.
