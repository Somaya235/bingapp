<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.util.*, java.text.*, mypackage.models.Admin , mypackage.models.User, mypackage.models.Booking" %> 
<%@ page import="java.sql.Date" %>

<%
    request.setCharacterEncoding("UTF-8");
User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect("login.jsp"); // Or your login page
        return;
    }
    // Only process deletion on POST
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String deleteBookingIdStr = request.getParameter("deleteBookingId");
        if (deleteBookingIdStr != null) {
            try {
                int bookingId = Integer.parseInt(deleteBookingIdStr);
                Integer currentUserId = (Integer) session.getAttribute("userId");
                if (currentUserId != null) {
                    User userForDeletion = new User();
                    try {
                        userForDeletion.cancelBooking(bookingId);
                        // Redirect after successful cancellation
                        String dateParam = request.getParameter("date");
                        String nameParam = request.getParameter("name");
                        String statusParam = request.getParameter("status");

                        if (dateParam != null && !dateParam.isEmpty()) {
                            response.sendRedirect("manage.jsp?date=" + dateParam);
                        } else {
                            response.sendRedirect("manage.jsp");
                        }
                        return; // Important: stop further processing after redirect
                    } catch (Exception cancelException) {
                        cancelException.printStackTrace();
                        out.println("Error cancelling booking: " + cancelException.getMessage());
                    }
                } else {
                    out.println("User not logged in.");
                }
            } catch (NumberFormatException e) {
                e.printStackTrace();
                out.println("Invalid booking ID.");
            }
        }
    }
   
String successMsg = null;
    if (request.getMethod().equals("POST")) {
        String holidayStr = request.getParameter("day_date");
        if (holidayStr != null && !holidayStr.isEmpty()) {
            Date holidayDate = Date.valueOf(holidayStr);
            boolean success = User.addHoliday(holidayDate);
            successMsg = success ? "Holiday added successfully!" : "Holiday already exists.";
        }
    }

%>

<html>
<head>
    <title>Manage</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="styles/report.css">
      <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
      <link href="https://fonts.googleapis.com/css2?family=Poppins&display=swap" rel="stylesheet">

</head>
<style>
body {
    font-family: 'Poppins', sans-serif;
    margin: 0;
    background: linear-gradient(to bottom right, #e8f5e9, #ffffff);
}


.navbar {
    background: linear-gradient(to right,rgb(133, 216, 137), #1b5e20);
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px 40px;
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
  }

.logo {
    font-size: 28px;
    color: #ffffff;
    font-weight: 700;
    letter-spacing: 2px;
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
  
  



.line {
    height: 0.7px;
    background-color: rgb(177, 176, 176);
    width: 95%;
    margin-left: 26px;
}

h2 {
    text-align: center;
    color: #2e7d32;
    margin-top: 30px;
    font-size: 30px;
}

form {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 10px;
    margin-top: 20px;
}

input[type="date"] {
    padding: 8px 10px;
    border: 1px solid #ccc;
    border-radius: 5px;
    font-size: 14px;
}
input[type="date"]:focus {
    border-color: #2e7d32;
    outline: none;
}

button[type="submit"] {
    background-color: #2e7d32;
    color: white;
    border: none;
    padding: 8px 14px;
    border-radius: 5px;
    cursor: pointer;
    font-size: 14px;
    transition: background-color 0.3s ease;
}

button[type="submit"]:hover {
    background-color: #27642b;
}

.slots-card {
background-color: rgba(255, 255, 255, 0.95);
border-radius: 13px;
padding: 20px;
margin: 30px auto;
box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
display: flex;
flex-direction: column;
justify-content: space-between;
width: 100%;
max-width: 1000px;
border: 1px solid #ccc; /* Add border for visibility */
}

.scroll-table {
max-height: 280px; /* Increase the max height to allow scrolling */
overflow-y: auto;
border-radius: 10px;
box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}


.scroll-table table {
    width: 100%;
    border-collapse: collapse;
}

.scroll-table th,
.scroll-table td {
    padding: 15px 20px;
    border-bottom: 1px solid #eee;
    font-size: 16px;
}

.scroll-table th {
    background-color: #2e7d32;
    color: white;
}

@keyframes slideFadeIn {
to {
opacity: 1;
transform: translateY(0);
}
}

/* Custom scrollbar for WebKit browsers */
.scroll-table::-webkit-scrollbar {
width: 10px;
}

.scroll-table::-webkit-scrollbar-track {
background: #c8e6c9; /* Light green track */
border-radius: 10px;
}

.scroll-table::-webkit-scrollbar-thumb {
background-color: #2e7d32; /* Dark green thumb */
border-radius: 10px;
border: 2px solid #c8e6c9;
}

/* Scrollbar for Firefox */
.scroll-table {
scrollbar-width: thin;
scrollbar-color: #2e7d32 #c8e6c9;
}
.scroll-table tbody tr:hover {
background-color: #e8f5e9;
box-shadow: 0 0 10px rgba(46, 125, 50, 0.3);
transition: all 0.3s ease;
}
.scroll-table tbody tr {
opacity: 0;
transform: translateY(20px);
animation: slideFadeIn 0.5s ease forwards;
}

.scroll-table tbody tr:nth-child(1) { animation-delay: 0.1s; }
.scroll-table tbody tr:nth-child(2) { animation-delay: 0.2s; }
.scroll-table tbody tr:nth-child(3) { animation-delay: 0.3s; }
/* Keep increasing the delay for more rows */
.scroll-table th {
position: relative;
overflow: hidden;
}


.slots-card {
animation: cardPop 0.6s ease-out;
}

@keyframes cardPop {
0% {
opacity: 0;
transform: scale(0.95);
}
100% {
opacity: 1;
transform: scale(1);
}
}
.delete-button {
    background-color: #c62828;
    color: white;
    border: none;
    padding: 4px 8px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
}

.delete-button:hover {
    background-color: #b71c1c;
}
/* Container for the filters */

form {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 20px;
    margin-top: 20px;
    flex-wrap: wrap; /* wrap on small screens */
}

/* Style the labels */
/* Container to align labels and inputs nicely */
.filter-group {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap; /* Wrap on small screens */
  margin: 20px 0;
  justify-content: center;
}

/* Style for all labels */
.filter-group label {
  font-weight: 600;
  font-size: 15px;
  color: #2e7d32; /* dark green */
  min-width: 90px;
  user-select: none;
  cursor: pointer; /* optional: makes it look clickable */
  transition: color 0.3s ease; /* smooth transition */
}


.filter-group label:hover {
  color: #388e3c;
}

.filter-group input:checked + label {
  color: #1b5e20;
}
.filter-group input:checked ~ label {
  color: #1b5e20;
}




/* Style for the text input */
.filter-group input[type="text"] {
     padding: 8px 12px;
  font-size: 15px;

  border-radius: 6px;
  background-color: white;
  color: #2e7d32;

  width: 140px;


}


/* Style for the select dropdown */
.filter-group select {
  padding: 8px 12px;
  font-size: 15px;

  border-radius: 6px;
  background-color: white;
  color: #2e7d32;
  
  width: 140px;

}
.switch {
  position: relative;
  display: inline-block;
  width: 50px;
  height: 24px;
}

.switch input {
  opacity: 0;
  width: 0;
  height: 0;
}

.slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #ccc;
  transition: .4s;
  border-radius: 24px;
}

.slider:before {
  position: absolute;
  content: "";
  height: 18px;
  width: 18px;
  left: 3px;
  bottom: 3px;
  background-color: white;
  transition: .4s;
  border-radius: 50%;
}

input:checked + .slider {
  background-color: #2e7d32;
}

input:checked + .slider:before {
  transform: translateX(26px);
}

/* Optional: Rounded slider */
.slider.round {
  border-radius: 24px;
}

.slider.round:before {
  border-radius: 50%;
}

#holidayDateInput{
    border-radius:6px;
    height:30px;

}


</style>
<body>
    <div class="navbar">
       <img style="width:100px" src="logo.png" alt="Logo" class="logo">
        <div class="nav-links">
            <a href="homepage_admin.jsp">Home</a>
            <a href="booking_admin.jsp">Book</a>
            <a href="profile_admin.jsp">Profile</a>
            <a href="manage.jsp">Manage</a>
        <form action="seasonToggle.jsp" method="post" style="display: flex; align-items: center; gap: 10px;">
    <label class="switch">
        <input type="checkbox" name="seasonSwitch" id="seasonSwitch" onchange="this.form.submit()"
               <%= user.getSeason().equals("Ramadan") ? "checked" : "" %> >
        <span class="slider round"></span>
    </label>
    <span style="color:white"><%= user.getSeason() %></span>
</form>


        </div>
    </div>

    <div class="line"></div>

    <h2>Manage</h2>

    <div class="filter-group">
         <label for="dateFilter">Date:</label>
        <input type="text" id="dateFilter" name="dateFilter" placeholder="Select Date" />
        <label for="name">Player Name:</label>
       <input type="text" id="name" name="name" placeholder="Search player..." onkeyup="filterTable()" />

        <label for="status">Status:</label>
        <select id="status" name="status" onchange="filterTable()">
            <option value="">All</option>
            <option value="booked">Booked</option>
            <option value="cancelled">Cancelled</option>
        </select>
    </div>

    <div class="slots-card">
        <div class="scroll-table">
            <table id="appointmentsTable">
                <thead>
                    <tr>
                        <th>Players</th>
                        <th>Time</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- Appointments will be loaded here by manage.js -->
                    <tr><td colspan="7">Loading appointments...</td></tr>
                </tbody>
            </table>
        </div>
    </div>
<h3 style="text-align: center; color:green ;">Select a Holiday</h3>
<center>
<form method="post">
    <input type="date" name="day_date" id="holidayDateInput" placeholder="Select Holiday">
    <button type="submit">Add Holiday</button>
</form>
</center>
<% if (successMsg != null) { %>
    <p style="color: green;"><%= successMsg %></p>
<% } %>

<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script src="scripts/manage.js"></script>



    
<script>
  flatpickr("#holidayDateInput", {
    dateFormat: "Y-m-d"
  });
  // Optionally add client-side filtering of table rows while typing
function filterTable() {
    let input = document.getElementById('name').value.toLowerCase();
    let statusFilter = document.getElementById('status').value.toLowerCase();
    let table = document.getElementById('appointmentsTable');
    let rows = table.getElementsByTagName('tr');

    for (let i = 1; i < rows.length; i++) { // Start from 1 to skip header
        let playerCell = rows[i].getElementsByTagName('td')[0];
        let statusCell = rows[i].getElementsByTagName('td')[2];

        if (playerCell && statusCell) {
            let playerName = playerCell.textContent || playerCell.innerText;
            let status = statusCell.textContent || statusCell.innerText;

            let nameMatch = playerName.toLowerCase().includes(input);
            let statusMatch = statusFilter === "" || status.toLowerCase() === statusFilter;

            if (nameMatch && statusMatch) {
                rows[i].style.display = "";
            } else {
                rows[i].style.display = "none";
            }
        }
    }
}

// Function to handle delete form submission
function confirmAndDelete(bookingId) {
  if (confirm('Are you sure you want to delete this booking?')) {
    // Find the single hidden delete form
    const deleteForm = document.getElementById('deleteForm');
    if (deleteForm) {
      // Set the booking ID in the hidden input
      document.getElementById('deleteBookingIdHidden').value = bookingId;
      // Set the date filter value if it exists on the page
      const dateFilterInput = document.getElementById('date');
      if (dateFilterInput) {
         document.getElementById('dateFilterHidden').value = dateFilterInput.value;
      }
       // Set the name filter value if it exists on the page
      const nameFilterInput = document.getElementById('name');
      if (nameFilterInput) {
         document.getElementById('nameFilterHidden').value = nameFilterInput.value;
      }
       // Set the status filter value if it exists on the page
      const statusFilterSelect = document.getElementById('status');
      if (statusFilterSelect) {
         document.getElementById('statusFilterHidden').value = statusFilterSelect.value;
      }

      // Submit the form
      deleteForm.submit();
    }
  }
  return false; // Prevent default button click behavior
}

// Auto-filter on page load if name input is present
window.onload = function() {
  if(document.getElementById('name').value || document.getElementById('status').value) {
    filterTable();
  }
}

// Optional: add event listeners if you haven't already
document.getElementById('name').addEventListener('input', filterTable);
document.getElementById('status').addEventListener('change', filterTable);

</script>

<!-- Single hidden form for handling deletions -->
<form id="deleteForm" method="post" action="manage.jsp" style="display:none;">
    <input type="hidden" name="deleteBookingId" id="deleteBookingIdHidden" value="" />
     <input type="hidden" name="date" id="dateFilterHidden" value="" />
      <input type="hidden" name="name" id="nameFilterHidden" value="" />
       <input type="hidden" name="status" id="statusFilterHidden" value="" />
</form>

</body>
</html>
