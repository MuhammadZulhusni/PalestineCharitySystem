package com.charity.model;

/**
 * User Model class representing a user account in the system.
 *
 * This class maps directly to the users table in the MySQL database.
 * It is a simple JavaBean (POJO — Plain Old Java Object) with private
 * fields and public getters and setters.
 *
 * In the MVC architecture, this class acts as the Model layer for user data.
 * It is used to carry user information between the three layers:
 *   - DAO layer    : UserDAO fills a User object from a database ResultSet
 *   - Controller   : LoginServlet stores the User object in HttpSession
 *   - View layer   : JSP pages read user data from session e.g. user.getUsername()
 *
 * Security note:
 *   - password      is stored as a BCrypt hash
 *   - securityAnswer is also stored as a BCrypt hash
 *   Both fields are hashed BEFORE the User object is saved to the database,
 *   meaning this class only ever holds the hash, not the original value.
 */
public class User {

    // Unique identifier for each user, maps to id (PK) in users table
    private int id;

    // Username used for login, maps to username (UNIQUE) in users table
    private String username;

    // BCrypt hashed password, never stored or compared as plain text
    // Verified using BCrypt.checkpw() in UserDAO.login()
    private String password;

    // Determines access level, either "ADMIN" or "DONOR"
    // Checked on every protected page to enforce role-based access control
    private String role;

    // The security question selected during registration or account creation
    // Displayed on the forgot password page (Step 1) to verify the user's identity
    // Stored as plain text, only the answer is hashed
    private String securityQuestion;

    // BCrypt hashed answer to the security question
    // Verified using BCrypt.checkpw() in ForgotPasswordServlet during password reset
    private String securityAnswer;

    /**
     * Default no-argument constructor required for JavaBean conventions.
     */
    public User() {}

    //
    // GETTERS AND SETTERS
    // All fields are private (encapsulation) so they can only be accessed through these public getter and setter methods.
    //   get = read the value of a field
    //   set = update the value of a field

    /**
     * Returns the user's unique database id.
     * Used in SQL queries e.g. WHERE user_id = ?
     */
    public int getId() { return id; }

    /**
     * Sets the user's database id.
     * Called by UserDAO when mapping a ResultSet row to a User object.
     */
    public void setId(int id) { this.id = id; }

    /**
     * Returns the username.
     * Displayed in the dashboard navigation bar e.g. user.getUsername()
     */
    public String getUsername() { return username; }

    /**
     * Sets the username.
     */
    public void setUsername(String username) { this.username = username; }

    /**
     * Returns the BCrypt hashed password.
     * Not displayed anywhere, only used internally by UserDAO.login()
     * to pass into BCrypt.checkpw() for verification.
     */
    public String getPassword() { return password; }

    /**
     * Sets the password field.
     * The value passed here should already be BCrypt hashed
     * before being set, never set a plain text password here.
     */
    public void setPassword(String password) { this.password = password; }

    /**
     * Returns the user's role either "ADMIN" or "DONOR".
     * Used on every protected JSP page:
     *   if (!"ADMIN".equals(user.getRole())) response.sendRedirect("login.jsp");
     */
    public String getRole() { return role; }

    /**
     * Sets the user's role.
     */
    public void setRole(String role) { this.role = role; }

    /**
     * Returns the security question text.
     * Displayed on forgot_password.jsp Step 1 after the user enters their username.
     */
    public String getSecurityQuestion() { return securityQuestion; }

    /**
     * Sets the security question.
     */
    public void setSecurityQuestion(String securityQuestion) {
        this.securityQuestion = securityQuestion;
    }

    /**
     * Returns the BCrypt hashed security answer.
     * Used internally by ForgotPasswordServlet to verify identity
     * via BCrypt.checkpw() before allowing a password reset.
     */
    public String getSecurityAnswer() { return securityAnswer; }

    /**
     * Sets the security answer field.
     * The value passed here should already be BCrypt hashed
     * and lowercased before being set.
     */
    public void setSecurityAnswer(String securityAnswer) {
        this.securityAnswer = securityAnswer;
    }
}