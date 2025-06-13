package mypackage.models;

import java.sql.*;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import mypackage.utl.DataBase;

public class User {
    // User class fields
    protected int id;
    protected String firstName;
    protected String lastName;
    protected String gender;
    protected Date dob;
    private String role; // Add this line
    private String season ="Ramadan"; // Default season is Ramadan";


    public String getSeason() {
        return this.season;
    }

    public void setSeason(String season) {
        this.season = season;
    }

    // Getter and Setter for role
    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    // No-argument constructor (optional)
    public User() {
        // Default constructor, you can leave it empty or set default values if needed
    }

    // Constructor that takes parameters to initialize the User object
    public User(int id, String firstName, String lastName, String gender, Date dob) {
        this.id = id;
        this.firstName = firstName;
        this.lastName = lastName;
        this.gender = gender;
        this.dob = dob;
    }
public void toggleSeason() {
    if (this.season.equalsIgnoreCase("Regular")) {
        this.season = "Ramadan";
    } else {
        this.season = "Regular";
    }
}

    // Method to login user
    public boolean login(String email, String password) throws SQLException {
        String sql = "SELECT * FROM emp_master_data WHERE email = ? AND password = ?";
        try (Connection conn = DataBase.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            stmt.setString(2, password);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    // load fields for session
                    this.id        = rs.getInt("emp_id");
                    this.firstName = rs.getString("first_name");
                    this.lastName  = rs.getString("last_name");
                    this.gender    = rs.getString("gender");
                    this.dob       = rs.getDate("dob");
                    this.role      = rs.getString("role"); 
                    return true;
                }
            }
        }
        return false;
    }

    public List<String> getAllEmployeeFullNames() {
        List<String> fullNames = new ArrayList<>();
        String sql = "SELECT first_name || ' ' || last_name AS full_name FROM emp_master_data";
    
        try (Connection conn = DataBase.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
    
            while (rs.next()) {
                fullNames.add(rs.getString("full_name"));
            }
    
        } catch (SQLException e) {
            e.printStackTrace();
        }
    
        return fullNames;
    }
    public List<String> getAllFemaleFullNames() {
        List<String> femaleNames = new ArrayList<>();
        String sql = "SELECT first_name || ' ' || last_name AS full_name FROM emp_master_data WHERE gender = 'Female'";
        
        try (Connection conn = DataBase.getConnection();
            PreparedStatement stmt = conn.prepareStatement(sql);
            ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                femaleNames.add(rs.getString("full_name"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return femaleNames;
    }


    // Method to see available game slots for male
    public static List<String[]> seeAvailableSlots(java.util.Date gameDate) {
        List<String[]> slots = new ArrayList<>();
        try (Connection conn = DataBase.getConnection()) {
            String sql ="SELECT s.slot_id, TO_CHAR(s.start_time, 'HH24:MI') AS start_time, \n" + //
                                "  TO_CHAR(s.end_time, 'HH24:MI') AS end_time FROM slots s \n" + //
                                "     WHERE gender_group != 'female' and s.slot_id not in \n" + //
                                " (SELECT slot_id from booking_game where status ='booked' and game_date =? )";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setDate(1, new java.sql.Date(gameDate.getTime()));
                ResultSet rs = stmt.executeQuery();

                while (rs.next()) {
                    int slotId = rs.getInt("slot_id");
                    String startTime = rs.getString("start_time");
                    String endTime = rs.getString("end_time");
                    slots.add(new String[]{startTime, endTime, String.valueOf(slotId)});
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return slots;
    }

    // Method to see RAMADAN available game slots for male
    public static List<String[]> seeRamadanAvailableSlots(java.util.Date gameDate) {
        List<String[]> slots = new ArrayList<>();
        try (Connection conn = DataBase.getConnection()) {
            String sql = "SELECT s.slot_id, TO_CHAR(s.start_time, 'HH24:MI') AS start_time, \n" + //
                                "\tTO_CHAR(s.end_time, 'HH24:MI') AS end_time FROM slots s \n" + //
                                "\tWHERE  s.season_time ='ramadan' AND gender_group != 'female' \n" + //
                                "\tAND s.slot_id not in \n" + //
                                "\t(SELECT slot_id from booking_game \n" + //
                                "\twhere status ='booked' and game_date = ? );";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setDate(1, new java.sql.Date(gameDate.getTime()));
                ResultSet rs = stmt.executeQuery();

                while (rs.next()) {
                    int slotId = rs.getInt("slot_id");
                    String startTime = rs.getString("start_time");
                    String endTime = rs.getString("end_time");
                    slots.add(new String[]{startTime, endTime, String.valueOf(slotId)});
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return slots;
    }

     // Method to see available game slots for female
     public static List<String[]> femaleAvailableSlots(java.util.Date gameDate) {
        List<String[]> slots = new ArrayList<>();
        try (Connection conn = DataBase.getConnection()) {
            String sql ="SELECT s.slot_id, TO_CHAR(s.start_time, 'HH24:MI') AS start_time, \n" + //
                                "  TO_CHAR(s.end_time, 'HH24:MI') AS end_time FROM slots s " + //
                                "WHERE s.slot_id not in (SELECT slot_id from booking_game where status ='booked' and game_date = ?)";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setDate(1, new java.sql.Date(gameDate.getTime()));
                ResultSet rs = stmt.executeQuery();

                while (rs.next()) {
                    int slotId = rs.getInt("slot_id");
                    String startTime = rs.getString("start_time");
                    String endTime = rs.getString("end_time");
                    slots.add(new String[]{startTime, endTime, String.valueOf(slotId)});
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return slots;
    }

    // Method to see RAMADAN available game slots for female
    public static List<String[]> ramadanFemaleAvailableSlots(java.util.Date gameDate) {
        List<String[]> slots = new ArrayList<>();
        try (Connection conn = DataBase.getConnection()) {
            String sql ="SELECT s.slot_id, TO_CHAR(s.start_time, 'HH24:MI') AS start_time, \n" + //
                                "\tTO_CHAR(s.end_time, 'HH24:MI') AS end_time FROM slots s \n" + //
                                "\tWHERE  s.season_time ='ramadan' AND s.slot_id not in \n" + //
                                "\t(SELECT slot_id from booking_game \n" + //
                                "\twhere status ='booked' and game_date = ? )";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setDate(1, new java.sql.Date(gameDate.getTime()));
                ResultSet rs = stmt.executeQuery();

                while (rs.next()) {
                    int slotId = rs.getInt("slot_id");
                    String startTime = rs.getString("start_time");
                    String endTime = rs.getString("end_time");
                    slots.add(new String[]{startTime, endTime, String.valueOf(slotId)});
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return slots;
    }

    // Method to see today's available game slots
    public static List<String[]> todayAvailableSlots(java.util.Date gameDate) {
        List<String[]> slots = new ArrayList<>();
        try (Connection conn = DataBase.getConnection()) {
            String sql = "SELECT s.slot_id, TO_CHAR(s.start_time, 'HH24:MI') AS start_time, \n" + //
                                "  TO_CHAR(s.end_time, 'HH24:MI') AS end_time FROM slots s " +
                         "WHERE s.slot_id NOT IN (SELECT slot_id FROM booking_game WHERE game_date = ?)";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setDate(1, new java.sql.Date(gameDate.getTime()));
                ResultSet rs = stmt.executeQuery();
                
                while (rs.next()) {
                    String startTime = rs.getString("start_time");
                    String endTime = rs.getString("end_time");
                    slots.add(new String[]{startTime, endTime});
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return slots;
    }

    // Method to see RAMADAN today's available game slots
    public static List<String[]> ramadanTodayAvailableSlots(java.util.Date gameDate) {
        List<String[]> slots = new ArrayList<>();
        try (Connection conn = DataBase.getConnection()) {
            String sql = "SELECT s.slot_id, TO_CHAR(s.start_time, 'HH24:MI') AS start_time,\n" + //
                                "\tTO_CHAR(s.end_time, 'HH24:MI') AS end_time FROM slots s\n" + //
                                "\tWHERE s.season_time ='ramadan' AND s.slot_id NOT IN \n" + //
                                "\t(SELECT slot_id FROM booking_game WHERE game_date = ? )";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setDate(1, new java.sql.Date(gameDate.getTime()));
                ResultSet rs = stmt.executeQuery();
                
                while (rs.next()) {
                    String startTime = rs.getString("start_time");
                    String endTime = rs.getString("end_time");
                    slots.add(new String[]{startTime, endTime});
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return slots;
    }

    // Method to cancel a booked slot
    public void cancelBooking(int bookingId) {
        try (Connection conn = DataBase.getConnection()) {
            String updateSql = "UPDATE booking_game SET status = 'cancelled' WHERE booking_id = ?";
            try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                updateStmt.setInt(1, bookingId);
                updateStmt.executeUpdate();
                System.out.println("Booking cancelled for booking_id: " + bookingId);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Method to show booked game slots
    public List<Booking> showBookedSlots(int empId) {
        List<Booking> bookings = new ArrayList<>();
        try (Connection conn = DataBase.getConnection()) {
            String sql = "SELECT b.booking_id, b.game_date, TO_CHAR(s.start_time, 'HH24:MI') AS start_time, "+
                         "TO_CHAR(s.end_time, 'HH24:MI') AS end_time, b.game_type, b.status " +
                         "FROM booking_game b JOIN slots s ON b.slot_id = s.slot_id " +
                         "WHERE b.booking_id IN (SELECT book_id FROM Emp_booking WHERE emp_id = ?) "+
                         "ORDER BY b.game_date DESC";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, empId);
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    int bookingId = rs.getInt("booking_id");
                    Date gameDate = rs.getDate("game_date");
                    String startTime = rs.getString("start_time");
                    String endTime = rs.getString("end_time");
                    String gameType = rs.getString("game_type");
                    String status = rs.getString("status");

                    bookings.add(new Booking(bookingId, gameDate, startTime, endTime, gameType, status));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return bookings;
    }
    
    // Method to get employee ID by full name
    public static int getEmployeeIdByName(String fullName) {
        int empId = -1; // Default to -1 if not found
        String sql = "SELECT emp_id FROM emp_master_data WHERE first_name || ' ' || last_name = ?";

        try (Connection conn = DataBase.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, fullName);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    empId = rs.getInt("emp_id");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return empId;
    }

    // Method to get employee IDs by a list of full names
    public static Map<String, Integer> getEmployeeIdsByNames(List<String> fullNames) {
        Map<String, Integer> employeeIds = new HashMap<>();
        if (fullNames == null || fullNames.isEmpty()) {
            return employeeIds;
        }

        // Construct the SQL query with a WHERE IN clause
        StringBuilder sql = new StringBuilder("SELECT emp_id, first_name || ' ' || last_name AS full_name FROM emp_master_data WHERE first_name || ' ' || last_name IN (");
        for (int i = 0; i < fullNames.size(); i++) {
            sql.append("?");
            if (i < fullNames.size() - 1) {
                sql.append(", ");
            }
        }
        sql.append(")");

        try (Connection conn = DataBase.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            // Set the parameters for the IN clause
            for (int i = 0; i < fullNames.size(); i++) {
                stmt.setString(i + 1, fullNames.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    employeeIds.put(rs.getString("full_name"), rs.getInt("emp_id"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return employeeIds;
    }

   public static boolean canEmployeeBookSlots(String empName, Date gameDate, int numOfSlots) {
    int empId = getEmployeeIdByName(empName);
    if (empId == -1) {
        System.err.println("Employee not found: " + empName);
        return false;
    }

    String sql = "SELECT COUNT(b.booking_id) AS games_booked " +
                 "FROM booking_game b " +
                 "JOIN emp_booking eb ON b.booking_id = eb.book_id " +
                 "WHERE b.status='booked' AND b.game_date = ? AND eb.emp_id = ?";

    try (Connection conn = DataBase.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {

        stmt.setDate(1, new java.sql.Date(gameDate.getTime()));
        stmt.setInt(2, empId);

        try (ResultSet rs = stmt.executeQuery()) {
            int countGames = 0;
            if (rs.next()) {
                countGames = rs.getInt("games_booked");
            }

            // Check if total exceeds limit
            if (countGames + numOfSlots > 5) {
                System.err.println("Booking limit exceeded for " + empName + ". Already booked: " + countGames);
                return false;
            }
            return true;
        }

    } catch (SQLException e) {
        e.printStackTrace();
        return false; // On SQL error, deny booking
    }
}
 public static boolean addHoliday(Date date) {
        String sql = "INSERT INTO holidays (day_date) VALUES (?) ON CONFLICT DO NOTHING";
        try (Connection conn = DataBase.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setDate(1, (java.sql.Date) date);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ✅ Get all holiday dates as a list of strings (yyyy-MM-dd)
public static List<String> getDisabledDaysBeforeHolidays() {
    List<String> disabledDays = new ArrayList<>();
    String sql = "SELECT day_date FROM holidays";

    try (Connection conn = DataBase.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql);
         ResultSet rs = stmt.executeQuery()) {

        while (rs.next()) {
            Date holidayDate = rs.getDate("day_date");
            // Use toLocalDate() instead of toInstant()
            LocalDate localHoliday = ((java.sql.Date) holidayDate).toLocalDate();
            LocalDate dayBefore = localHoliday.minusDays(1);

            disabledDays.add(dayBefore.format(DateTimeFormatter.ISO_LOCAL_DATE));
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }

    return disabledDays;
}




    // Getter and setter methods for the User fields
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public Date getDob() {
        return dob;
    }

    public void setDob(Date dob) {
        this.dob = dob;
    }
}