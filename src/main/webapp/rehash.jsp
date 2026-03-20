<%@ page import="org.mindrot.jbcrypt.BCrypt, com.charity.util.DBConnection, java.sql.*" %>
<%
    String username = "admin";
    String password = "Admin@123";  // change this to whatever you want

    String hash = BCrypt.hashpw(password, BCrypt.gensalt(12));

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(
             "INSERT INTO users (username, password, role) VALUES (?, ?, 'ADMIN')")) {
        ps.setString(1, username);
        ps.setString(2, hash);
        ps.executeUpdate();
        out.print("<h3 style='color:green'>Admin created!</h3>");
        out.print("<p>Username: " + username + "</p>");
        out.print("<p>Password: " + password + "</p>");
        out.print("<p>Hash: " + hash + "</p>");
        out.print("<p><b>Delete this file now!</b></p>");
    } catch (Exception e) {
        out.print("<h3 style='color:red'>Error: " + e.getMessage() + "</h3>");
    }
%>
```

**Step 2: Visit it once:**
```
http://localhost:8080/rehash.jsp