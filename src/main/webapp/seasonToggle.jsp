<%@ page import="mypackage.models.User" %>
<%
    User user = (User) session.getAttribute("loggedInUser"); // Retrieve the User object from session
    if (user != null) {
        user.toggleSeason(); // Flip the season
        session.setAttribute("loggedInUser", user); // Update the session object
    }
    response.sendRedirect("homepage_admin.jsp"); // Redirect to wherever you want
%>
