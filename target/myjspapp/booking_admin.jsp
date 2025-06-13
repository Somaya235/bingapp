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
    List<Map<String, String>> allEmployeeDetails = User.getAllEmployeeDetails();
    
    // Remove the logged-in user from the list if present
    String loggedInUserFullName = "";
    if (user != null) {
        String firstName = user.getFirstName() != null ? user.getFirstName().trim() : "";
        String lastName = user.getLastName() != null ? user.getLastName().trim() : "";
        loggedInUserFullName = firstName + " " + lastName;
    }

    Iterator<Map<String, String>> iterator = allEmployeeDetails.iterator();
    while (iterator.hasNext()) {
        Map<String, String> employee = iterator.next();
        if (employee.get("full_name").trim().equalsIgnoreCase(loggedInUserFullName.trim())) {
            iterator.remove();
            break;
        }
    }

    String employeeDetailsJson = new Gson().toJson(allEmployeeDetails);

    List<String> holidayList = User.getDisabledDaysBeforeHolidays();
    String holidayJson = new Gson().toJson(holidayList);


%>


<!-- Your CSS here -->
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
    <a href="homepage_admin.jsp">Home</a>
    <a href="booking_admin.jsp">Book</a>
    <a href="profile_admin.jsp">Profile</a>
    <a href="manage.jsp">Manage</a>
    
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

<div class="loading-overlay" id="loadingOverlay" style="display: none;">
  <div class="spinner"></div>
</div>

<!-- JavaScript -->
<script>
  // Global constants and variables
  const gender = "<%= userGender %>";
  const allEmployees = <%= employeeDetailsJson %>;
  const players = allEmployees.map(emp => ({ name: emp.full_name, gender: emp.gender }));
  let opponentType = "Squad"; 
  const loggedInUser = "<%= loggedInUserFullName %>"; // Moved to global scope

  // Global functions
  function formatDateLocal(date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0'); // Months 0-based
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
  }

  function updateOpponentSelect() {
  const type = document.getElementById("type").value;
  opponentType = type;
  const container = document.getElementById("opponentList");
  const selectElements = document.querySelectorAll('select');
  
  selectElements.forEach(select => select.classList.add('green-border'));

  container.innerHTML = "";

  if (type === "Double") {
    const select = document.createElement("select");
    select.name = "opponent";
    select.required = true;
    select.size = 5;
    select.classList.add("scrollable-select", 'green-border');

    players.forEach(player => {
      const option = document.createElement("option");
      option.value = player.name;
      option.textContent = player.name;
      option.classList.add("green-player");
      select.appendChild(option);
    });

    container.appendChild(select);
  } else {
    players.forEach(player => {
      const label = document.createElement("label");
      label.classList.add("opponent-checkbox");
      label.setAttribute("data-name", player.name.toLowerCase());

      const checkbox = document.createElement("input");
      checkbox.type = "checkbox";
      checkbox.name = "opponents";
      checkbox.value = player.name;

      checkbox.addEventListener("change", function () {
        const checked = container.querySelectorAll("input[name='opponents']:checked");
        if (checked.length > 3) {
          this.checked = false;
          alert("Select up to 3 partners only.");
        }
      });

      label.appendChild(checkbox);
      label.append(" " + player.name);
      container.appendChild(label);
    });
  }
  filterOpponents(); // Always filter opponents after updating select type
}

function filterOpponents() {
  const query = document.getElementById("searchOpponent").value.toLowerCase();
  const container = document.getElementById("opponentList");

  container.innerHTML = "";

  const selectedSlots = document.querySelectorAll("input[name='timeSlots']:checked");
  let femaleOnlySlotSelected = false;

  // Helper function to convert HH:MI to minutes from midnight
  const timeToMinutes = (timeStr) => {
    const [hours, minutes] = timeStr.split(':').map(Number);
    return hours * 60 + minutes;
  };

  const TEN_AM_MINUTES = timeToMinutes('10:00');
  const ELEVEN_AM_MINUTES = timeToMinutes('11:00');
  const TEN_FIFTY_AM_MINUTES = timeToMinutes('10:50');

  selectedSlots.forEach(slot => {
      const slotStartTime = timeToMinutes(slot.getAttribute('data-start-time'));
      const slotEndTime = timeToMinutes(slot.getAttribute('data-end-time'));
      const slotGenderGroup = slot.getAttribute('data-gender-group');

      // Check if the slot overlaps with 10:00-11:00 and is female-specific
      if (slotGenderGroup === 'female' && 
          ((slotStartTime >= TEN_AM_MINUTES && slotStartTime < ELEVEN_AM_MINUTES) ||
           (slotEndTime > TEN_AM_MINUTES && slotEndTime <= ELEVEN_AM_MINUTES) ||
           (slotStartTime < TEN_AM_MINUTES && slotEndTime > ELEVEN_AM_MINUTES) ||
           (slotStartTime >= TEN_FIFTY_AM_MINUTES && slotEndTime <= ELEVEN_AM_MINUTES))) {
          femaleOnlySlotSelected = true;
      }
  });

  let filteredPlayers = players.filter(player => {
      const matchesQuery = player.name.toLowerCase().includes(query);
      if (femaleOnlySlotSelected) {
          return matchesQuery && player.gender.toLowerCase() === 'female';
      } else {
          return matchesQuery;
      }
  });

  if (opponentType === "Double") {
    const select = document.createElement("select");
    select.name = "opponent";
    select.required = true;
    select.size = 5;
    select.classList.add("scrollable-select");

    filteredPlayers.forEach(player => {
      const option = document.createElement("option");
      option.value = player.name;
      option.textContent = player.name;
      select.appendChild(option);
    });

    container.appendChild(select);
  } else {
    filteredPlayers.forEach(player => {
      const label = document.createElement("label");
      label.classList.add("opponent-checkbox");
      label.setAttribute("data-name", player.name.toLowerCase());

      const checkbox = document.createElement("input");
      checkbox.type = "checkbox";
      checkbox.name = "opponents";
      checkbox.value = player.name;
      checkbox.setAttribute('data-gender', player.gender);

      checkbox.addEventListener("change", function () {
        const checked = container.querySelectorAll("input[name='opponents']:checked");
        if (checked.length > 3) {
          this.checked = false;
          alert("Select up to 3 partners only.");
        }
      });

      label.appendChild(checkbox);
      label.append(" " + player.name);
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

  let femaleOnlySlotSelected = false;

  // Helper function to convert HH:MI to minutes from midnight
  const timeToMinutes = (timeStr) => {
    const [hours, minutes] = timeStr.split(':').map(Number);
    return hours * 60 + minutes;
  };

  const TEN_AM_MINUTES = timeToMinutes('10:00');
  const ELEVEN_AM_MINUTES = timeToMinutes('11:00');
  const TEN_FIFTY_AM_MINUTES = timeToMinutes('10:50');

  selectedTimeSlots.forEach(slot => {
      const slotStartTime = timeToMinutes(slot.getAttribute('data-start-time'));
      const slotEndTime = timeToMinutes(slot.getAttribute('data-end-time'));
      const slotGenderGroup = slot.getAttribute('data-gender-group');

      // Check if the slot overlaps with 10:00-11:00 and is female-specific
      if (slotGenderGroup === 'female' && 
          ((slotStartTime >= TEN_AM_MINUTES && slotStartTime < ELEVEN_AM_MINUTES) ||
           (slotEndTime > TEN_AM_MINUTES && slotEndTime <= ELEVEN_AM_MINUTES) ||
           (slotStartTime < TEN_AM_MINUTES && slotEndTime > ELEVEN_AM_MINUTES) ||
           (slotStartTime >= TEN_FIFTY_AM_MINUTES && slotEndTime <= ELEVEN_AM_MINUTES))) {
          femaleOnlySlotSelected = true;
      }
  });

  if (type === "Squad") {
    const selectedOpponents = document.querySelectorAll("input[name='opponents']:checked");
    if (selectedOpponents.length !== 3) {
      alert("In Squad, you must select exactly 3 partners.");
      return false;
    }
    
    if (femaleOnlySlotSelected) {
        for (let i = 0; i < selectedOpponents.length; i++) {
            const opponentName = selectedOpponents[i].value;
            const opponent = players.find(p => p.name === opponentName);
            if (opponent && opponent.gender.toLowerCase() !== 'female') {
                alert("Male players cannot be selected for 10:00-11:00 slots.");
                return false;
            }
        }
    }

    const selectedOpponentList = Array.from(selectedOpponents).map(cb => cb.value);
  }

  if (type === "Double") {
    const opponentSelect = document.querySelector("select[name='opponent']");
    const selectedOpponentName = opponentSelect?.value || null;

    if (femaleOnlySlotSelected && selectedOpponentName) {
        const opponent = players.find(p => p.name === selectedOpponentName);
        if (opponent && opponent.gender.toLowerCase() !== 'female') {
            alert("Male players cannot be selected for 10:00-11:00 slots.");
            return false;
        }
    }
  }

  return true;
} 

function triggerCalendar() {
  const fp = document.getElementById("date")._flatpickr;
  if (fp) {
    fp.open();
  }
}

function fetchAvailableSlots() {
    const dateInput = document.getElementById('date');
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
    .then(response => {
        loadingOverlay.style.display = 'none';
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json(); 
    })
    .then(slots => {
        const slotContainer = document.getElementById('timeSlotsContainer');
        slotContainer.innerHTML = '<label>Select Time Slots (max 5)</label>';

        if (slots.length === 0) {
            slotContainer.innerHTML += '<p>No slots available for this date and gender.</p>';
            document.getElementById('searchOpponent').disabled = true;
            document.getElementById('opponentContainer').style.display = 'none';
            return;
        }

        slots.forEach(slot => {
            const div = document.createElement('div');
            const checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.name = 'timeSlots';
            checkbox.value = slot.slot_id;
            checkbox.id = 'slot-' + slot.slot_id;
            checkbox.setAttribute('data-start-time', slot.start_time);
            checkbox.setAttribute('data-end-time', slot.end_time);
            checkbox.setAttribute('data-gender-group', slot.gender_group);
            checkbox.onchange = checkTimeSlotLimit; 

            const label = document.createElement('label');
            label.htmlFor = 'slot-' + slot.slot_id;
            label.textContent = slot.start_time + ' - ' + slot.end_time;

            div.appendChild(checkbox);
            div.appendChild(label);
            slotContainer.appendChild(div);
        });

        const opponentSearch = document.getElementById('searchOpponent');
        const opponentContainer = document.getElementById('opponentContainer');
        opponentSearch.disabled = true;
        opponentContainer.style.display = 'none';

        const checkboxes = slotContainer.querySelectorAll("input[name='timeSlots']");
        checkboxes.forEach(cb => {
            cb.addEventListener('change', updateOpponentSelectionBasedOnTimeSlot);
        });
    })
    .catch(error => {
        console.error('Error fetching slots:', error);
        loadingOverlay.style.display = 'none';
        const slotContainer = document.getElementById('timeSlotsContainer');
        slotContainer.innerHTML = '<label>Select Time Slots (max 5)</label><p>Error loading slots. Please try again.</p>';
    });
}

function updateOpponentSelectionBasedOnTimeSlot() {
    const opponentSearch = document.getElementById('searchOpponent');
    const opponentContainer = document.getElementById('opponentContainer');
    const checkedSlots = document.querySelectorAll("input[name='timeSlots']:checked");

    if (checkedSlots.length > 0) {
        opponentSearch.disabled = false;
        opponentContainer.style.display = 'block';
        filterOpponents(); 
    } else {
        opponentSearch.disabled = true;
        opponentContainer.style.display = 'none';
    }
    checkTimeSlotLimit(); 
}

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

          const checkboxes = document.querySelectorAll("input[name='opponents']");
          checkboxes.forEach(box => {
            if (box.value === empName) {
              box.checked = false;
            }
          });

          const select = document.querySelector("select[name='opponent']");
          if (select && select.value === empName) {
            select.value = "";
          }

          if (empName === loggedInUser) {
            const timeSlots = document.querySelectorAll("input[name='timeSlots']:checked");
            timeSlots.forEach(slot => slot.checked = false);
          }
        }
      })
  .catch(error => console.error('Error fetching slots:', error))
    .finally(() => {
        loadingOverlay.style.display = 'none';
    });
    }


document.addEventListener('DOMContentLoaded', function() {
  const dateInput = document.getElementById('date');
  const genderSelect = document.getElementById('gender');
  const holidays = <%= holidayJson %>;

  flatpickr("#date", {
    minDate: new Date(),
    maxDate: new Date(new Date().setDate(new Date().getDate() + 7)),
    dateFormat: "Y-m-d",
    disable: [
      function(date) {
        const dateStr = date.toISOString().slice(0,10);
        if (date.getDay() === 5 || date.getDay() === 6) {
          return true;
        }
        if (holidays.includes(dateStr)) {
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
      } else if (day === 5 || day === 6) {
        alert("Booking not allowed on Fridays or Saturdays.");
        instance.clear();
      } else if (holidays.includes(selectedDate.toISOString().slice(0,10))) {
        alert("Booking not allowed on holidays.");
        instance.clear();
      }
      fetchAvailableSlots();
    }
  });

  dateInput.addEventListener('change', fetchAvailableSlots);

  document.getElementById("timeSlotsContainer").addEventListener("change", function (event) {
    const target = event.target;
    if (target && target.name === "timeSlots" && target.checked) {
      checkPlayerBookingLimit(loggedInUser);
    }
  });

  document.getElementById("opponentList").addEventListener("change", function (event) {
    const target = event.target;
    if (target && (target.name === "opponents" || target.name === "opponent")) {
      const empName = target.value;
      if (target.checked || target.tagName === "SELECT") {
        checkPlayerBookingLimit(empName);
      }
    }
  });

  updateOpponentSelect();
});
</script>

</body>
</html>
