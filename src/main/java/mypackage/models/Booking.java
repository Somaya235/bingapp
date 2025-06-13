package mypackage.models;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

import mypackage.utl.DataBase;

public class Booking {
    private int bookingId;
    private Date gameDate;
    private String startTime;
    private String endTime;
    private String gameType;
    private int slotId;
    private String status;

    
   

    public Booking(int bookingId, Date gameDate, String startTime, String endTime, String gameType,  String status) {
        this.bookingId = bookingId;
        this.gameDate = gameDate;
        this.startTime = startTime;
        this.endTime = endTime;
        this.gameType = gameType;
        this.status = status;
   
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public Date getGameDate() {
        return gameDate;
    }

    public void setGameDate(Date gameDate) {
        this.gameDate = gameDate;
    }

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getEndTime() {
        return endTime;
    }

    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }

    public String getGameType() {
        return gameType;
    }

    public void setGameType(String gameType) {
        this.gameType = gameType;
    }

    public int getSlotId() {
        return slotId;
    }

    public void setSlotId(int slotId) {
        this.slotId = slotId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public static List<Map<String, Object>> getAllBookings() throws SQLException {
        List<Map<String, Object>> bookings = new ArrayList<>();
        String sql = "SELECT " +
                     "bg.booking_id, " +
                     "bg.game_date AS appointment_date, " +
                     "s.start_time, " +
                     "s.end_time, " +
                     "string_agg(emd.first_name || ' ' || emd.last_name, ', ') AS players_full_name, " +
                     "bg.game_type AS service, " +
                     "bg.status " +
                     "FROM booking_game bg " +
                     "JOIN slots s ON bg.slot_id = s.slot_id " +
                     "LEFT JOIN emp_booking eb ON bg.booking_id = eb.book_id " +
                     "LEFT JOIN emp_master_data emd ON eb.emp_id = emd.emp_id " +
                     "GROUP BY bg.booking_id, bg.game_date, s.start_time, s.end_time, bg.game_type, bg.status " +
                     "ORDER BY bg.booking_id";

        try (Connection connection = DataBase.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql);
             ResultSet resultSet = preparedStatement.executeQuery()) {

            while (resultSet.next()) {
                Map<String, Object> booking = new HashMap<>();
                booking.put("id", resultSet.getInt("booking_id"));
                booking.put("appointmentDate", resultSet.getDate("appointment_date").toString());
                booking.put("startTime", resultSet.getTime("start_time").toString());
                booking.put("endTime", resultSet.getTime("end_time").toString());
                booking.put("players", resultSet.getString("players_full_name"));
                booking.put("service", resultSet.getString("service"));
                booking.put("status", resultSet.getString("status"));
                bookings.add(booking);
            }
        }
        return bookings;
    }

    public static boolean updateBookingStatusToCancelled(int bookingId) throws SQLException {
        String sql = "UPDATE booking_game SET status = 'cancelled' WHERE booking_id = ?";
        try (Connection connection = DataBase.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setInt(1, bookingId);
            int rowsAffected = preparedStatement.executeUpdate();
            return rowsAffected > 0;
        }
    }
}
