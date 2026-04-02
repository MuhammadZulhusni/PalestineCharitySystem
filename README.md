# Palestine Charity Donation Management System

> A secure, full-stack web application for managing charity campaigns and donations built with Java EE, JSP, Servlets, and MySQL.

---

## Overview

The Palestine Charity Donation Management System is a web-based enterprise application that allows administrators to manage charity campaigns and donors to contribute to active causes. The system provides real-time donation tracking, campaign progress monitoring, and secure user authentication with role-based access control.

---

## Features

### Authentication
- Secure login and registration
- BCrypt password hashing (one-way, cannot be reversed)
- Security question and answer for password recovery
- Role-based access control (Admin / Donor)
- Session management with automatic redirect

### Campaign Management (Admin)
- Create, edit, and delete campaigns
- Activate / deactivate campaigns
- Real-time progress bar showing funds raised vs target
- View all donor contributions per campaign
- Search campaigns

### Donation Management
- Donors can contribute to any active campaign
- Minimum donation of RM 1.00 enforced
- Prevents donation to inactive or fully funded campaigns
- Personal donation history with search
- Admin global donation log across all campaigns

### User Management (Admin)
- Add new Donor or Admin accounts
- Set security question and answer on behalf of users
- Delete users (with cascade delete on donations)
- Cannot delete own account (self-delete protection)

### Dashboard & Calculations
- Total raised across all campaigns
- Per-campaign progress percentage
- Donor personal stats (total donated, donation count, top campaign)
- Overall funding goal completion percentage

### UI / UX
- Dark and light theme toggle (saved to localStorage)
- SweetAlert2 modals for all confirmations and notifications

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | JSP, HTML5, CSS3, JavaScript |
| Backend | Java EE Servlets (Jakarta EE 9+) |
| Database | MySQL 8 |
| Server | Jetty 11.0.15 (embedded) |
| Build Tool | Apache Maven |
| Security | BCrypt (jbcrypt 0.4) |
| UI Library | SweetAlert2 |
| Fonts | Google Fonts (Lora, DM Sans) |
| Architecture | MVC (Model-View-Controller) |

---

## System Architecture

```
┌─────────────────────────────────────────────────┐
│                   View Layer                     │
│         JSP Pages & HTML/CSS/JavaScript          │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│               Controller Layer                   │
│              Java Servlets (11)                  │
│  LoginServlet, RegisterServlet, DonateServlet    │
│  AddCampaignServlet, EditCampaignServlet, etc.   │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│                 Model / DAO Layer                │
│         User.java        Campaign.java           │
│         UserDAO.java      CampaignDAO.java       │
│              DBConnection.java                   │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│                MySQL Database                    │
│         users | campaigns | donations            │
└─────────────────────────────────────────────────┘
```

---

## Database Schema

```sql
CREATE TABLE users (
    id                INT PRIMARY KEY AUTO_INCREMENT,
    username          VARCHAR(100) UNIQUE NOT NULL,
    password          VARCHAR(255) NOT NULL,         -- BCrypt hashed
    role              VARCHAR(20)  NOT NULL DEFAULT 'DONOR',
    security_question VARCHAR(255),
    security_answer   VARCHAR(255)                   -- BCrypt hashed
);

CREATE TABLE campaigns (
    id             INT PRIMARY KEY AUTO_INCREMENT,
    title          VARCHAR(255) NOT NULL,
    description    TEXT,
    target_amount  DOUBLE NOT NULL DEFAULT 0,
    current_amount DOUBLE NOT NULL DEFAULT 0,
    status         VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
);

CREATE TABLE donations (
    id            INT PRIMARY KEY AUTO_INCREMENT,
    user_id       INT NOT NULL,
    campaign_id   INT NOT NULL,
    amount        DOUBLE NOT NULL,
    donation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)     REFERENCES users(id),
    FOREIGN KEY (campaign_id) REFERENCES campaigns(id)
);
```

**Relationships:**
- `users` -> `donations`<- `campaigns`
- One user can make many donations
- One campaign can receive many donations
- `donations` is a junction table linking both

---

## Getting Started

### Prerequisites

- Java JDK 11 or higher
- Apache Maven 3.6+
- MySQL 8.0+
- Git

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/MuhammadZulhusni/PalestineCharitySystem.git
cd PalestineCharitySystem
```

**2. Create the database**
```sql
CREATE DATABASE charity_db;
USE charity_db;
```


**3. Configure database connection**

Edit `src/main/java/com/charity/util/DBConnection.java`:
```java
private static final String URL  = "jdbc:mysql://localhost:3306/charity_db";
private static final String USER = "your_mysql_username";
private static final String PASS = "your_mysql_password";
```

**4. Create the admin account**

Visit `http://localhost:8080/rehash.jsp` once after starting the server to insert the default admin account. Delete this file immediately after.

**5. Build and run**
```bash
mvn clean jetty:run
```

**6. Open in browser**
```
http://localhost:8080/
```

---

## User Roles

### Admin
| Feature | Access |
|---|---|
| View all campaigns | ✅ |
| Create campaign | ✅ |
| Edit campaign | ✅ |
| Delete campaign | ✅ |
| Activate / Deactivate campaign | ✅ |
| View all donations | ✅ |
| Add users | ✅ |
| Delete users | ✅ |

### Donor
| Feature | Access |
|---|---|
| View active campaigns | ✅ |
| Donate to campaigns | ✅ |
| View personal donation history | ✅ |
| View personal stats | ✅ |
| Manage campaigns | ❌ |
| View other donors | ❌ |

---

## Security

| Measure | Implementation |
|---|---|
| Password hashing | BCrypt with cost factor 12 |
| Security answer hashing | BCrypt (lowercased before hashing) |
| Session management | Jakarta EE HttpSession |
| Access control | Servlet-level session validation on every protected page |
| SQL injection prevention | JDBC PreparedStatement throughout |
| Self-delete protection | Server-side username comparison before deletion |
| Cascade delete | Donations removed when user is deleted (FK integrity) |

---

## Servlet URL Mappings

| URL Pattern | Servlet | Method |
|---|---|---|
| `/login` | LoginServlet | POST |
| `/logout` | LogoutServlet | GET |
| `/register` | RegisterServlet | POST |
| `/forgotPassword` | ForgotPasswordServlet | POST |
| `/donate` | DonateServlet | POST |
| `/addCampaign` | AddCampaignServlet | POST |
| `/editCampaign` | EditCampaignServlet | GET |
| `/deleteCampaign` | DeleteCampaignServlet | GET |
| `/getCampaign` | GetCampaignServlet | GET |
| `/toggleCampaign` | ToggleCampaignServlet | GET |
| `/addUser` | AddUserServlet | GET |
| `/deleteUser` | DeleteUserServlet | GET |

---

