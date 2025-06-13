<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Error</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #fdf2f2;
            color: #b00020;
            padding: 50px;
            text-align: center;
        }
        .error-box {
            border: 2px solid #b00020;
            padding: 20px;
            display: inline-block;
            background-color: #fff0f0;
        }
        a {
            color: #b00020;
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="error-box">
        <h1>⚠ An Error Occurred</h1>
        <p>Something went wrong while processing your request.</p>
        <p><a href="homepage_user.jsp">Return to Home</a></p>
    </div>
</body>
</html>
<%@ page import="java.io.IOException" %>
