<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.File" %>
<%@ page import="java.nio.file.Paths" %>
<%@ page import="mypackage.models.User" %>
<%@ page import="mypackage.models.Booking" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>
<%@ page import="mypackage.utl.DataBase" %> 
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>

<%
    request.setCharacterEncoding("UTF-8");

    String deleteBookingIdStr = request.getParameter("deleteBookingId");
    if (deleteBookingIdStr != null) {
        try {
            int bookingId = Integer.parseInt(deleteBookingIdStr);
            Integer currentUserId = (Integer) session.getAttribute("userId");
            if (currentUserId != null) {
                User userForDeletion = new User();
                userForDeletion.cancelBooking(bookingId);
                response.sendRedirect("profile_user.jsp");
                return;
            } else {
                out.println("User not logged in.");
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
            out.println("Invalid booking ID.");
        }
    }
%>

<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Profile & Bookings</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <style>
    body {
      font-family: 'Poppins', sans-serif;
      margin: 0;
      padding: 0;
      background-color: #f5f5f5;
    }
    
    .main-content {
      background-image: url('homepage_photo.png');
      background-repeat: no-repeat;
      background-size: cover;
      min-height: calc(100vh - 70px);
    }
    
   .navbar {
      background: linear-gradient(to right,rgb(133, 216, 137), #1b5e20);
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px 40px;
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
  }

@keyframes slideDown {
    from {
        transform: translateY(-100%);
        opacity: 0;
    }
    to {
        transform: translateY(0);
        opacity: 1;
    }
}
    
    .logo {
      width: 100px;
    }
 .nav-links {
    display: flex;
    align-items: center;
    gap: 25px;
  }
  
  .nav-links a {
    text-decoration: none;
    color: #e0f2f1;
    font-weight: 500;
    padding: 10px 20px;
    font-size: 17px;
    border-radius: 8px;
    transition: background 0.3s ease, color 0.3s ease, transform 0.3s ease;
  }
  
  .nav-links a:hover {
    transform: scale(1.1); /* Slightly enlarge on hover */
    background: rgba(255, 255, 255, 0.2);
    color: #ffffff;
  }
  
  
    .container {
      opacity: 0.9;
      max-width: 1000px;
      margin: 0 auto;
      padding: 20px;
      
    }
    
  .profile-container {
    background: white;
    border-radius: 10px;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
    padding: 25px;
    margin-top: 20px;
    animation: fadeIn 0.8s ease-in;
}

@keyframes fadeIn {
    from {
        opacity: 0;
        transform: translateY(20px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}
    
    .profile-section {
      display: flex;
      align-items: center;
      margin-bottom: 15px; /* Reduced from 30px */
      padding-bottom: 15px; /* Reduced from 20px */
      border-bottom: 1px solid #eee;
    }
    
    .avatar {
      width: 80px;
      height: 80px;
      border-radius: 50%;
      overflow: hidden;
      margin-right: 25px;
      border: 3px solid #e0e0e0;
    }
    
    .avatar img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
    
    .user-info h2 {
      margin: 0;
      color: #333;
      font-size: 24px;
      font-weight: 600;
    }
    
    .user-info p {
      margin: 5px 0 0;
      color: #777;
      font-size: 16px;
    }
    
    .section-title {
      font-size: 20px;
      color: #1b5e20;
      margin: 10px 0 15px; /* Adjusted margins */
      font-weight: 600;
      padding: 0;
    }
    
    .bookings-content {
      margin-top: 15px; /* Added to create space between title and table */
    }
    
    .scroll-table {
      max-height: 300px;
      overflow-y: auto;
      border-radius: 10px;
      border: 1px solid #ddd;
      margin-top: 15px; /* Added space above table */
    }
    
    table {
      width: 100%;
      border-collapse: collapse;
    }
    
    th, td {
      padding: 12px 15px;
      text-align: left;
      border-bottom: 1px solid #eee;
    }
    
    th {
      background-color: #2e7d32;
      color: white;
      font-weight: 500;
      position: sticky;
      top: 0;
    }
    
    tr:hover {
      background-color: #f9f9f9;
    }
    
  .action-btn {
    background: none;
    border: none;
    color: #2e7d32;
    cursor: pointer;
    font-size: 18px;
    padding: 5px;
    transition: all 0.3s ease;
    position: relative;
}

.action-btn:hover {
    color: #e53935;
    transform: scale(1.2);
}

.action-btn:hover i {
    animation: shake 0.5s ease infinite;
}

@keyframes shake {
    0% { transform: rotate(0deg); }
    25% { transform: rotate(10deg); }
    50% { transform: rotate(0deg); }
    75% { transform: rotate(-10deg); }
    100% { transform: rotate(0deg); }
}
    
    .no-bookings {
      text-align: center;
      color: #777;
      padding: 20px;
      font-style: italic;
    }
    
    @media (max-width: 768px) {
      .profile-section {
        flex-direction: column;
        text-align: center;
      }
      
      .avatar {
        margin-right: 0;
        margin-bottom: 15px;
      }
      
      th, td {
        padding: 8px 10px;
        font-size: 14px;
      }
      
      .container {
        padding: 0 15px;
      }
      
      .profile-container {
        padding: 15px;
      }
    }
    tbody tr {
    transition: all 0.3s ease;
}

tbody tr:hover {
    background-color: #f0f7f0 !important;
    transform: scale(1.01);
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

tbody tr {
    animation: fadeInRow 0.5s ease-out forwards;
    opacity: 0;
}

@keyframes fadeInRow {
    to {
        opacity: 1;
    }
}

/* Add delay to each row */
tbody tr:nth-child(1) { animation-delay: 0.1s; }
tbody tr:nth-child(2) { animation-delay: 0.2s; }
tbody tr:nth-child(3) { animation-delay: 0.3s; }
tbody tr:nth-child(4) { animation-delay: 0.4s; }
tbody tr:nth-child(5) { animation-delay: 0.5s; }
.scroll-table::-webkit-scrollbar {
    width: 8px;
}

.scroll-table::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 10px;
}

.scroll-table::-webkit-scrollbar-thumb {
    background: #81c784;
    border-radius: 10px;
    transition: background 0.3s;
}

.scroll-table::-webkit-scrollbar-thumb:hover {
    background: #4caf50;
}
  </style>
</head>
<body>
  <div class="navbar">
    <img class="logo" src="logo.png" alt="Logo">
    <div class="nav-links">
      <a href="homepage_user.jsp">Home</a>
      <a href="booking_user.jsp">Book</a>
      <a href="profile_user.jsp">Profile</a>
      <a href="login.jsp">Logout</a>
    </div>
  </div>

  <div class="main-content">
    <div class="container">
      <div class="profile-container">
        <!-- Profile Section -->
        <div class="profile-section">
          <div class="avatar">
            <img src="avatar.png" alt="Profile">
          </div>
          <div class="user-info">
            <h2><%= session.getAttribute("username") != null ? session.getAttribute("username") : "NO User Name" %></h2>
            <p><%= session.getAttribute("email") != null ? session.getAttribute("email") : "No Email" %></p>
          </div>
        </div>
        
        <!-- Bookings Section -->
        <h2 class="section-title">History</h2>
        
        <div class="bookings-content">
          <div class="scroll-table">
            <%
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null) {
                out.println("<p>User not logged in.</p>");
            } else {
                String firstName = "firstName";
                String lastName = "lastName";    
                String gender = "gender";     
                Date dob = new Date();      
                
                User user = new User(userId, firstName, lastName, gender, dob);
                List<Booking> bookedSlots = user.showBookedSlots(userId);
                
                if (bookedSlots.isEmpty()) {
                    out.println("<p class='no-bookings'>No upcoming bookings found.</p>");
                } else {
            %>
            <table>
              <thead>
                <tr>
                  <th>Date</th>
                  <th>Start time</th>
                  <th>End time</th>
                  <th>Game type</th>
                  <th>Status</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                <% for (Booking booking : bookedSlots) { 
                    java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("MMMM dd, yyyy");
                    String formattedDate = dateFormat.format(booking.getGameDate());
                %>
                <tr>
                  <td><%= formattedDate %></td>
                  <td><%= booking.getStartTime() %></td>
                  <td><%= booking.getEndTime() %></td>
                  <td><%= booking.getGameType() %></td>
                  <td><%= booking.getStatus() %></td>
                 <td>
    <% if ("booked".equalsIgnoreCase(booking.getStatus())) { %>
        <form method="post" action="profile_user.jsp" style="display:inline;">
            <input type="hidden" name="deleteBookingId" value="<%= booking.getBookingId() %>">
            <button type="submit" class="action-btn" onclick="return confirm('Are you sure you want to cancel this booking?')">
                <i class="fas fa-trash-alt" style="color: #2e7d32;"></i>
            </button>
        </form>
    <% } %>
</td>
                </tr>
                <% } %>
              </tbody>
            </table>
            <% 
                }
            } 
            %>
          </div>
        </div>
      </div>
    </div>
  </div>

  <script>
    // Confirm before canceling booking
    document.querySelectorAll('.action-btn').forEach(button => {
      button.addEventListener('click', function(e) {
        if (!confirm('Are you sure you want to cancel this booking?')) {
          e.preventDefault();
        }
      });
    });
  </script>
</body>
</html>

<%
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String email = request.getParameter("email");

        Part avatarPart = request.getPart("avatar");
        String avatarFileName = null;

        if (avatarPart != null && avatarPart.getSize() > 0) {
            String uploadPath = application.getRealPath("/") + "uploads/";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            avatarFileName = Paths.get(avatarPart.getSubmittedFileName()).getFileName().toString();
            File file = new File(uploadPath + avatarFileName);
            avatarPart.write(file.getAbsolutePath());
        }

        session.setAttribute("username", username);
        session.setAttribute("email", email);
        if (avatarFileName != null) {
            session.setAttribute("avatar", avatarFileName);
        }

        response.sendRedirect("profile_user.jsp");
    }
%>