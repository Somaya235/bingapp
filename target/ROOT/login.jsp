<%@ page import="java.sql.*" %>
<%@ page import="mypackage.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="mypackage.utl.DataBase" %>

<%
    String message = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        User user = new User();
        try {
            if (user.login(email, password)) {
                session.setAttribute("userId", user.getId());
                session.setAttribute("username", user.getFirstName() + " " + user.getLastName());
                session.setAttribute("email", email);
                session.setAttribute("gender", user.getGender());
                session.setAttribute("role", user.getRole());
                 // Set the full User object in session here:
                session.setAttribute("loggedInUser", user);
            
                if ("admin".equalsIgnoreCase(user.getRole())) {
                    response.sendRedirect("homepage_admin.jsp");
                } else {
                    response.sendRedirect("homepage_user.jsp");
                }
                return;
            } else {
                message = "Invalid email or password. Please try again.";
            }
        } catch (SQLException e) {
            message = "Database error during login. Please try again later.";
            e.printStackTrace(); // Log the actual database error on the server
        }
    }

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login</title>
    <link rel="stylesheet" href="styles/login.css">
</head>
<body>

<div class="container">
    <img src="background_login.png" alt="">
    <form method="post" action="login.jsp" class="login-form">
        <input type="text" name="email" placeholder="Email" required class="username">
        <input type="password" name="password" placeholder="Password" required class="password">
        <button type="submit" class="button1">Login</button>
        <p style="color:red;"><%= message %></p> <!-- Show error message if any -->
    </form>
</div>
</body>
</html>
