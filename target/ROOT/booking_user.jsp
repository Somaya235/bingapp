<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, mypackage.models.User" %>
<%@ page import="mypackage.utl.DataBase" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.sql.Date" %>
<%@ page import="com.google.gson.Gson" %>



<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Booking</title>

  <link rel="stylesheet" href="styles/booking_user.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
  <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<%
User user = (User) session.getAttribute("loggedInUser");

String userGender = "Unknown";
if (user != null && user.getGender() != null) {
    userGender = user.getGender();
}
    List<String> employeeNames = user.getAllEmployeeFullNames();

    String username = (String) session.getAttribute("username");
   
  

    // Remove the logged-in user from the list, trimming and ignoring case
    List<String> toRemove = new ArrayList<>();
    for (String emp : employeeNames) {
        if (emp.trim().equalsIgnoreCase(username.trim())) {
            toRemove.add(emp);
        }
    }
    employeeNames.removeAll(toRemove);
     List<String> holidayList = User.getDisabledDaysBeforeHolidays();
    String holidayJson = new Gson().toJson(holidayList);


%>

<!-- Your CSS here (same as you provided) -->
<style>
.navbar {
    background: linear-gradient(to right,rgb(133, 216, 137), #1b5e20);
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px 40px;
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
}
.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(255,255,255,0.7);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
}

.spinner {
  width: 60px;
  height: 60px;
  border: 6px solid #ccc;
  border-top-color: #1b5e20;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}


</style>

</head>
<body>

<!-- Navbar -->
<div class="navbar">
  <img style="width:100px" src="logo.png" alt="Logo" class="logo">
  <div class="nav-links">
    <a href="homepage_user.jsp">Home</a>
    <a href="booking_user.jsp">Book</a>
    <a href="profile_user.jsp">Profile</a>
    
  
  </div>
</div>
<% if (request.getAttribute("errorMessage") != null) { %>
    <div style="color: red; font-weight: bold; padding: 10px;">
        <%= request.getAttribute("errorMessage") %>
    </div>
<% } %>


<!-- Main Section -->
<div class="main-section">
  <div class="form-area">
    <h2>Booking</h2>
    <form id="bookingForm" action="ConfirmBookingServlet" method="post" onsubmit="return validateForm()">
      
      <div class="booking-fields-container">
        
<div class="horizontal-group">
 

  <div class="form-group date-group">
    <label for="date">Date</label>
    <div class="input-with-icon">
      <input type="text" id="date" name="date1" required readonly>
      <span class="calendar-icon" onclick="triggerCalendar()">📅</span>
    </div>
  </div>

  <div class="form-group">
    <label for="type">Game Type</label>
    <select id="type" name="type" onchange="updateOpponentSelect()" required>
      <option value="Double">Double</option>
      <option value="Squad">Squad</option>
    </select>
  </div>
</div>

        <div class="opponent-container">
          
          <div class="time-slot-scroll" id="timeSlotsContainer">
            <label>Select Time Slots (max 5)</label>
            <p>Please pick a date to see available time slots</p>
          </div>

         <div class="opponent-scroll" id="opponentContainer" style="display: none;">

            <label for="searchOpponent" class="search-opponent-label">Search Opponent</label>
           <input type="text" id="searchOpponent" placeholder="Search opponent..." onkeyup="filterOpponents()" disabled>
            <div id="opponentList"></div>
          </div>

        </div> <!-- close opponent-container -->

      </div> <!-- close booking-fields-container -->

      <button type="submit" class="btn-book">Confirm Booking</button>

    </form>
  </div> <!-- close form-area -->
</div> <!-- close main-section -->

<!-- JavaScript -->
<script>
  const gender = "<%= userGender %>";
  const players = [
    <% for (String name : employeeNames) { %>
      "<%= name %>",
    <% } %>
  ];
  function formatDateLocal(date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0'); // Months 0-based
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
  }

  let opponentType = "Squad";
  document.addEventListener("DOMContentLoaded", function () {
 const holidays = <%= holidayJson %>;
flatpickr("#date", {
  minDate: new Date(),
  maxDate: new Date(new Date().setDate(new Date().getDate() + 7)),
  dateFormat: "Y-m-d",
  disable: [
    function(date) {
      const dateStr = date.toISOString().slice(0,10); // format date as YYYY-MM-DD
      if (date.getDay() === 5 || date.getDay() === 6) { // Friday or Saturday
        return true;
      }
      if (holidays.includes(dateStr)) { // check if in holiday list
        return true;
      }
      return false;
    }
  ],
  onChange: function(selectedDates, dateStr, instance) {
    if (!selectedDates.length) return;
    const selectedDate = selectedDates[0];
    const day = selectedDate.getDay();
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    if (selectedDate < today) {
      alert("Cannot select a past date.");
      instance.clear();
    }
    // These days should already be disabled so this might be redundant:
    else if (day === 5 || day === 6) {
      alert("Booking not allowed on Fridays or Saturdays.");
      instance.clear();
    } else if (holidays.includes(selectedDate.toISOString().slice(0,10))) {
      alert("Booking not allowed on holidays.");
      instance.clear();
    }
  }
});

});

  function updateOpponentSelect() {
  const type = document.getElementById("type").value;
  opponentType = type;
  const container = document.getElementById("opponentList");
  const selectElements = document.querySelectorAll('select');
  
  // Add green border to all select elements
  selectElements.forEach(select => select.classList.add('green-border'));

  container.innerHTML = "";

  if (type === "Double") {
    const select = document.createElement("select");
    select.name = "opponent";
    select.required = true;
    select.size = 5;
    select.classList.add("scrollable-select", 'green-border');  // Add the green-border class

    players.forEach(player => {
      const option = document.createElement("option");
      option.value = player;
      option.textContent = player;
      option.classList.add("green-player");  // Add the green-player class
      select.appendChild(option);
    });

    container.appendChild(select);
  } else {
    players.forEach(player => {
      const label = document.createElement("label");
      label.classList.add("opponent-checkbox");
      label.setAttribute("data-name", player.toLowerCase());

      const checkbox = document.createElement("input");
      checkbox.type = "checkbox";
      checkbox.name = "opponents";
      checkbox.value = player;

      checkbox.addEventListener("change", function () {
        const checked = container.querySelectorAll("input[name='opponents']:checked");
        if (checked.length > 3) {
          this.checked = false;
          alert("Select up to 3 partners only.");
        }
      });

      label.appendChild(checkbox);
      label.append(" " + player);
      container.appendChild(label);
    });
  }
}




  function filterOpponents() {
  const query = document.getElementById("searchOpponent").value.toLowerCase();
  const container = document.getElementById("opponentList");
  container.innerHTML = "";

  const filtered = players.filter(player => player.toLowerCase().includes(query));

  if (opponentType === "Double") { // ✅ Fix here
    const select = document.createElement("select");
    select.name = "opponent";
    select.required = true;
    select.size = 5;
    select.classList.add("scrollable-select");

    filtered.forEach(player => {
      const option = document.createElement("option");
      option.value = player;
      option.textContent = player;
      select.appendChild(option);
    });

    container.appendChild(select);
  } else {
    filtered.forEach(player => {
      const label = document.createElement("label");
      label.classList.add("opponent-checkbox");
      label.setAttribute("data-name", player.toLowerCase());

      const checkbox = document.createElement("input");
      checkbox.type = "checkbox";
      checkbox.name = "opponents";
      checkbox.value = player;

      checkbox.addEventListener("change", function () {
        const checked = container.querySelectorAll("input[name='opponents']:checked");
        if (checked.length > 3) {
          this.checked = false;
          alert("Select up to 3 partners only.");
        }
      });

      label.appendChild(checkbox);
      label.append(" " + player);
      container.appendChild(label);
    });
  }
}

  function checkTimeSlotLimit() {
    const checked = document.querySelectorAll("input[name='timeSlots']:checked");
    if (checked.length > 5) {
      alert("You can select up to 5 time slots only.");
      event.target.checked = false;
    }
  }


function validateForm() {
  const type = document.getElementById("type").value;
  const date = document.getElementById("date").value;
  const selectedTimeSlots = document.querySelectorAll("input[name='timeSlots']:checked");

  if (!date) {
    alert("Please select a date.");
    return false;
  }

  if (selectedTimeSlots.length === 0) {
    alert("Please select at least one time slot.");
    return false;
  }

  if (type === "Squad") {
    const selectedOpponents = document.querySelectorAll("input[name='opponents']:checked");
    if (selectedOpponents.length !== 3) {
      alert("In Squad, you must select exactly 3 partners.");
      return false;
    }
    const selectedOpponentList = Array.from(selectedOpponents).map(cb => cb.value);
    console.log("Selected Opponents:", selectedOpponentList); // ✅ This should now show
  }

  if (type === "Double") {
    const opponentSelect = document.querySelector("select[name='opponent']");
    const selectedOpponent = opponentSelect?.value || null;
    console.log("Selected Opponent:", selectedOpponent); // ✅ This should also show
  }

  return true;
} 

function triggerCalendar() {
  const fp = document.getElementById("date")._flatpickr;
  if (fp) {
    fp.open();
  }
}


document.addEventListener('DOMContentLoaded', function() {
    const dateInput = document.getElementById('date');
    const genderSelect = document.getElementById('gender');

function fetchAvailableSlots() {
    const selectedDate = dateInput.value;
    const selectedGender = gender;
 const loadingOverlay = document.getElementById('loadingOverlay');

    if (!selectedDate) return;
     loadingOverlay.style.display = 'flex';

    fetch('GetAvailableSlotsServlet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'date1=' + encodeURIComponent(selectedDate) + '&gender=' + encodeURIComponent(selectedGender)
    })
    .then(response => response.text())
    .then(data => {
        const slotContainer = document.getElementById('timeSlotsContainer');
        slotContainer.innerHTML = data;

        // Initially disable and hide opponent section
        const opponentSearch = document.getElementById('searchOpponent');
        const opponentContainer = document.getElementById('opponentContainer');
        opponentSearch.disabled = true;
        opponentContainer.style.display = 'none';

        // Attach event listeners to time slot checkboxes
        const checkboxes = slotContainer.querySelectorAll("input[name='timeSlots']");
        checkboxes.forEach(cb => {
            cb.addEventListener('change', () => {
                const selected = slotContainer.querySelectorAll("input[name='timeSlots']:checked");
                if (selected.length > 0) {
                    opponentSearch.disabled = false;
                    opponentContainer.style.display = 'block';
                    updateOpponentSelect();
                } else {
                    opponentSearch.disabled = true;
                    opponentContainer.style.display = 'none';
                }
            });
        });
    })
    .catch(error => console.error('Error fetching slots:', error))
    .finally(() => {
        // Hide loader
        loadingOverlay.style.display = 'none';
    });
}



    dateInput.addEventListener('change', fetchAvailableSlots);
  // fetch when gender changes too!
});
<%
String loggedInUserFullName = "";
if (user != null) {
    String firstName = user.getFirstName() != null ? user.getFirstName().trim() : "";
    String lastName = user.getLastName() != null ? user.getLastName().trim() : "";
    loggedInUserFullName = firstName + " " + lastName;
}
%>

const loggedInUser = "<%= loggedInUserFullName %>";
console.log("Logged in user full name:", loggedInUser);

  document.addEventListener('DOMContentLoaded', function () {

    function checkPlayerBookingLimit(empName) {
      const selectedDate = document.getElementById("date").value;
      const selectedSlots = document.querySelectorAll("input[name='timeSlots']:checked").length;
      const loadingOverlay = document.getElementById('loadingOverlay');

      if (!selectedDate || selectedSlots === 0) {
        return;
      }
     loadingOverlay.style.display = 'flex';
      fetch('CheckBookingLimitServlet', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'empName=' + encodeURIComponent(empName) +
              '&date1=' + encodeURIComponent(selectedDate) +
              '&numSlots=' + encodeURIComponent(selectedSlots)
      })
      .then(response => response.text())
      .then(result => {
        if (result.trim() === "false") {
          alert(empName + " has exceeded the booking limit for this day.");

          // Uncheck Squad checkboxes
          const checkboxes = document.querySelectorAll("input[name='opponents']");
          checkboxes.forEach(box => {
            if (box.value === empName) {
              box.checked = false;
            }
          });

          // Deselect in Double select box
          const select = document.querySelector("select[name='opponent']");
          if (select && select.value === empName) {
            select.value = "";
          }

          // Uncheck the user's own time slot if this is self-check
          if (empName === loggedInUser) {
            const timeSlots = document.querySelectorAll("input[name='timeSlots']:checked");
            timeSlots.forEach(slot => slot.checked = false);
          }
        }
      })
  .catch(error => console.error('Error fetching slots:', error))
    .finally(() => {
        // Hide loader
        loadingOverlay.style.display = 'none';
    });
    }

    // 🟩 Validate the logged-in user when selecting time slots
    document.getElementById("timeSlotsContainer").addEventListener("change", function (event) {
      const target = event.target;

      if (target && target.name === "timeSlots" && target.checked) {
        checkPlayerBookingLimit(loggedInUser);
      }
    });

    // 🟩 Validate opponent selection (Squad & Double)
    document.getElementById("opponentList").addEventListener("change", function (event) {
      const target = event.target;

      if (target && (target.name === "opponents" || target.name === "opponent")) {
        const empName = target.value;

        if (target.checked || target.tagName === "SELECT") {
          checkPlayerBookingLimit(empName);
        }
      }
});

  });

  // Initialize opponent list on load
  window.onload = updateOpponentSelect;
</script>
<div class="loading-overlay" id="loadingOverlay" style="display: none;">
  <div class="spinner"></div>
</div>


</body>
</html>
