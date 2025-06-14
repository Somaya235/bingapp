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
<style>
* {
    padding: 0;
    margin: 0;
    box-sizing: border-box;
}

html, body {
    width: 100%;
    height: 100%;
    overflow: auto; /* Allow scrolling if the content is too big */
}

.container {
    display: flex;
    height: 100vh;
    width: 100%;
    min-width: 600px; /* Minimum width to prevent the layout from collapsing */
    font-family: 'Poppins', Arial, sans-serif;
    background-repeat: no-repeat;
}

.img {
    flex: 2; /* Image takes 2 parts */
    object-fit: cover;
}

.login-form {
    flex: 1; /* Form takes 1 part */
    padding: 60px 40px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 25px;
    background-color: rgba(255, 255, 255, 0.85);
}

.username,
.password {
    width: 80%;
    height: 60px;
    padding: 15px;
    border: none;
    border-radius: 45px;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
    font-size: 16px;
    background-color: rgb(233, 233, 233);
}

.button1 {
    width: 75%;
    height: 60px;
    background-color: #2b9d5c;
    color: white;
    border: none;
    border-radius: 45px;
    font-size: 20px;
    cursor: pointer;
}

.button1:hover {
    background-color: #45a049;
}

/* Make sure layout stays side by side even on small screens */
@media (max-width: 768px) {
    .container {
        min-width: 600px; /* This ensures the layout does not break */
    }
}

/* Optional: On very small screens, allow more compact spacing */
@media (max-width: 500px) {
    .username,
    .password,
    .button1 {
        width: 95%;
    }

    .login-form {
        padding: 30px 15px;
    }
}


</style>
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
