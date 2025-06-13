package mypackage.servlets;

import mypackage.models.Booking;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;
import java.sql.Date;

@WebServlet("/manage-api")
public class ManageApiServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String dateFilter = request.getParameter("date");

        try {
            List<Map<String, Object>> bookings = Booking.getAllBookings(); // This method might need to be adjusted to accept date filter
            JSONArray jsonArray = new JSONArray();

            // Apply date filtering if provided, otherwise send all bookings
            for (Map<String, Object> booking : bookings) {
                if (dateFilter == null || dateFilter.isEmpty() || dateFilter.equals(booking.get("appointmentDate"))) {
                    JSONObject jsonObject = new JSONObject();
                    jsonObject.put("id", booking.get("id"));
                    jsonObject.put("players", booking.get("players")); // Using the new 'players' key
                    jsonObject.put("appointmentDate", booking.get("appointmentDate"));
                    jsonObject.put("startTime", booking.get("startTime"));
                    jsonObject.put("endTime", booking.get("endTime"));
                    jsonObject.put("service", booking.get("service"));
                    jsonObject.put("status", booking.get("status"));
                    jsonArray.put(jsonObject);
                }
            }

            out.print(jsonArray.toString());
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JSONObject errorObject = new JSONObject();
            errorObject.put("error", "Error fetching booking data: " + e.getMessage());
            out.print(errorObject.toString());
        }
    }
} 