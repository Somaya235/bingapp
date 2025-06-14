document.addEventListener('DOMContentLoaded', function() {
    const dateFilterInput = document.getElementById('dateFilter');
    const tableBody = document.querySelector('#appointmentsTable tbody');

    const flatpickrConfig = {
        dateFormat: "Y-m-d",
        onChange: function(selectedDates, dateStr, instance) {
            // When a date is selected, trigger a re-fetch and re-render
            fetchAndRenderTable(dateStr);
        }
    };

    if (dateFilterInput) {
        flatpickr(dateFilterInput, flatpickrConfig);
    }

    // Initial fetch and render for the table (without a date filter)
    fetchAndRenderTable();

    async function fetchAndRenderTable(filterDate = null) {
        let url = '/manage-api';
        if (filterDate) {
            url += `?date=${filterDate}`;
        }

        try {
            const response = await fetch(url);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            const data = await response.json();
            renderTable(data);
        } catch (error) {
            console.error('Error fetching data:', error);
            // Optionally render an error message to the user on the page
            if (tableBody) {
                tableBody.innerHTML = '<tr><td colspan="8">Error loading appointments. Please try again later.</td></tr>';
            }
        }
    }

    function renderTable(data) {
        if (!tableBody) {
            console.error('Table body not found');
            return;
        }
        tableBody.innerHTML = ''; // Clear existing rows

        if (data.length === 0) {
            tableBody.innerHTML = '<tr><td colspan="8">No appointments found.</td></tr>';
            return;
        }

        data.forEach(item => {
            const row = document.createElement('tr');
            // Assuming item.appointmentDate is in YYYY-MM-DD format from the API
            row.dataset.date = item.appointmentDate;

            row.innerHTML = `
                <td>${item.players}</td>
                <td>${item.startTime}</td>  <!-- startTime is actually slot_time -->
                <td>${item.status}</td>
                <td>
                    ${item.status === 'booked' ? `<a href="#" class="action-link delete-action" data-id="${item.id}"><i class="fas fa-trash"></i></a>` : '&mdash;'}
                </td>
            `;
            tableBody.appendChild(row);
        });

        // Add event listeners for delete actions after rendering
        document.querySelectorAll('.delete-action').forEach(button => {
            button.addEventListener('click', handleDeleteBooking);
        });
    }

    async function handleDeleteBooking(event) {
        event.preventDefault(); // Prevent default link behavior
        const bookingId = event.currentTarget.dataset.id;

        if (confirm('Are you sure you want to delete this booking?')) {
            try {
                const response = await fetch('/bingapp/delete-booking', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: `id=${bookingId}`
                });

                if (!response.ok) {
                    const errorData = await response.json();
                    throw new Error(`HTTP error! Status: ${response.status}, Message: ${errorData.message || 'Unknown error'}`);
                }

                const result = await response.json();
                if (result.status === 'success') {
                    alert(result.message);
                    fetchAndRenderTable(dateFilterInput.value); // Re-fetch current filtered data
                } else {
                    alert(`Error: ${result.message}`);
                }
            } catch (error) {
                console.error('Error deleting booking:', error);
                alert('Failed to delete booking. Please try again.');
            }
        }
    }

    // This filterTable is for player name and status, not for date
    // It will filter already displayed rows, not re-fetch from server
    document.getElementById('name').addEventListener('input', applyClientSideFilters);
    document.getElementById('status').addEventListener('change', applyClientSideFilters);

    function applyClientSideFilters() {
        const nameInput = document.getElementById('name').value.toLowerCase();
        const statusSelect = document.getElementById('status').value.toLowerCase();
        const rows = document.querySelectorAll('#appointmentsTable tbody tr');

        rows.forEach(row => {
            // The first column now contains the players' names
            const playersCell = row.children[0].textContent.toLowerCase();
            // The fifth column contains the status
            const status = row.children[4].textContent.toLowerCase();

            const nameMatches = playersCell.includes(nameInput);
            const statusMatches = statusSelect === '' || status === statusSelect;

            if (nameMatches && statusMatches) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    }
}); 