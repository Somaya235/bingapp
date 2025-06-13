package mypackage.servlets;

import mypackage.models.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;
import com.google.gson.Gson;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

@WebServlet("/GetAvailableSlotsServlet")
public class GetAvailableSlotsServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String dateStr = request.getParameter("date1");
        String gender = request.getParameter("gender");

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loggedInUser"); 
        String season = user.getSeason();

        List<Map<String, Object>> slotsJson = new ArrayList<>();

        if (dateStr != null && !dateStr.isEmpty()) {
            SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
            try {
                java.util.Date selectedDate = formatter.parse(dateStr);

                List<String[]> slotsData;

                if ("Male".equalsIgnoreCase(gender)) {
                    if ("Ramadan".equalsIgnoreCase(season)) {
                        slotsData = User.seeRamadanAvailableSlots(selectedDate);
                    } else {
                        slotsData = User.seeAvailableSlots(selectedDate);
                    }
                } else if ("Female".equalsIgnoreCase(gender)) {
                    if ("Ramadan".equalsIgnoreCase(season)) {
                        slotsData = User.ramadanFemaleAvailableSlots(selectedDate);
                    } else {
                        slotsData = User.femaleAvailableSlots(selectedDate);
                    }
                } else {
                    // If gender is invalid, send an empty list or an error message as JSON
                    out.print(new Gson().toJson(slotsJson)); // Empty list
                    return;
                }

                for (String[] slot : slotsData) {
                    Map<String, Object> slotMap = new HashMap<>();
                    slotMap.put("start_time", slot[0]);
                    slotMap.put("end_time", slot[1]);
                    slotMap.put("slot_id", Integer.parseInt(slot[2]));
                    slotMap.put("gender_group", slot[3]); // Assuming gender_group is at index 3
                    slotsJson.add(slotMap);
                }
                out.print(new Gson().toJson(slotsJson));

            } catch (ParseException e) {
                e.printStackTrace();
                // Send an empty list or error message as JSON on parse error
                out.print(new Gson().toJson(slotsJson)); 
            }
        } else {
            // Send an empty list as JSON if date is not valid
            out.print(new Gson().toJson(slotsJson));
        }
    }
}
