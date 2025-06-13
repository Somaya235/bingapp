package mypackage.servlets;

import mypackage.models.Admin;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;
import java.util.Date;

@WebServlet("/manage-api")
public class ManageApiServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String dateFilter = request.getParameter("date");
        JSONArray jsonArray = new JSONArray();

        try {
            // Use provided date or default to today's date
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date utilDate;

            if (dateFilter != null && !dateFilter.isEmpty()) {
                utilDate = sdf.parse(dateFilter);
            } else {
                utilDate = new Date(); // today
            }

            // Call viewReport with selected or default date
            List<Map<String, String>> report = Admin.viewReport(utilDate);

            for (Map<String, String> booking : report) {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("id", booking.get("booking_id"));
                jsonObject.put("players", booking.get("players"));
                jsonObject.put("startTime", booking.get("slot_time"));  // example: "17:00-17:10"
                jsonObject.put("status", booking.get("status"));
                jsonObject.put("appointmentDate", sdf.format(utilDate));  // for JS filtering

                jsonArray.put(jsonObject);
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
