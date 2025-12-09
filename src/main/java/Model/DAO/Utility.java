package Model.DAO;

import Database.ConnectionDb;
import Model.BO.Category;
import Model.BO.CurrentUser;
import Model.BO.MonthRange;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.List;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
public class Utility {
    ItemDao itemDao = new ItemDao();
    CategoryDao categoryDao = new CategoryDao();


    // Hàm xác định tên cột ID dựa vào tên bảng
    private static String getIdColumnName(String tableName) {
        switch (tableName) {
            case "users": return "user_id";
            case "categories": return "category_id";
            case "items": return "item_id";
            case "savings": return "category_id"; // Saving dùng chung ID với Category hoặc link qua category_id
            default: return "id";
        }
    }

    public static String generateID(String name) {
        String prefix = "";
        switch (name) {
            case "users":
                prefix = "U";
                break;
            case "categories":
                prefix = "C";
                break;
            case "items":
                prefix = "I";
                break;
            case "savings":
                prefix = "S";
                break;
        }

        int nextNumber = getNewestNumber(name);
        return prefix + nextNumber;
    }

    public static int getNewestNumber(String tableName) {
        String idColumn = getIdColumnName(tableName);

        // Logic: Lấy ra ID có độ dài lớn nhất, sau đó đến giá trị lớn nhất (để tránh trường hợp I1, I10, I2 sắp xếp sai)
        // Ví dụ: Nếu chỉ order by id desc thì I9 sẽ lớn hơn I10 (theo chuỗi).
        // Nên phải order by length(id) trước.
        String sql = "SELECT " + idColumn + " FROM " + tableName +
                " ORDER BY LENGTH(" + idColumn + ") DESC, " + idColumn + " DESC LIMIT 1";

        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            if (rs.next()) {
                String lastId = rs.getString(1); // Ví dụ: "I28"
                // Cắt bỏ ký tự đầu tiên (prefix) và lấy phần số
                String numberPart = lastId.substring(1);
                try {
                    int lastNumber = Integer.parseInt(numberPart);
                    return lastNumber + 1; // Trả về 29
                } catch (NumberFormatException e) {
                    System.out.println("Lỗi parse ID: " + lastId);
                    return 1; // Fallback nếu lỗi
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Nếu bảng chưa có dữ liệu nào, trả về 1 (Bắt đầu là I1, C1...)
        return 1;
    }
     // lưu các tháng tùy chỉnh vào DB
    public static void saveCustomMonthsToDB(String userId, List<MonthRange> months) // add các tháng đã tính toán dựa vào ngày đầu tiên nhập
    {
        String sql = "INSERT INTO custom_months (month_number, start_date, end_date, user_id) VALUES (?, ?, ?, ?)";

        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            for (MonthRange m : months) {
                ps.setInt(1, m.getMonth());
                ps.setTimestamp(2, Timestamp.valueOf(m.getStart()));
                ps.setTimestamp(3, Timestamp.valueOf(m.getEnd()));
                ps.setString(4, userId);
                ps.addBatch();
            }

            ps.executeBatch(); // chạy insert hàng loạt
            System.out.println("✅ Đã thêm " + months.size() + " tháng tùy chỉnh vào DB");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // lấy ngày bắt đầu của hàng tháng trong custom_months dựa vào UserID
    public static LocalDateTime getCustomMonthStartDate(String userId, int monthNumber) {
        String sql = """
                    SELECT start_date
                    FROM custom_months
                    WHERE user_id = ?
                      AND month_number = ?
                    LIMIT 1
                """;

        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);
            ps.setInt(2, monthNumber);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getTimestamp("start_date").toLocalDateTime();
                }
            }

        } catch (SQLException e) {
            System.err.println("Lỗi khi lấy custom month start date: " + e.getMessage());
        }

        return null; // không tìm thấy
    }

    //cập nhật ngày đầu của tháng và thứ tự của tất cả các tháng trong custom_months
    public static void updateCustomMonthsInDB(String userId, List<MonthRange> months) {
        String sql = "UPDATE custom_months SET month_number = ?, start_date = ?, end_date = ? WHERE user_id = ? AND month_number = ?";

        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            for (MonthRange m : months) {
                ps.setInt(1, m.getMonth());
                ps.setTimestamp(2, Timestamp.valueOf(m.getStart()));
                ps.setTimestamp(3, Timestamp.valueOf(m.getEnd()));
                ps.setString(4, userId);
                ps.setInt(5, m.getMonth()); // điều kiện WHERE dựa trên month_number cũ
                ps.addBatch();
            }

            ps.executeBatch(); // chạy update hàng loạt
            System.out.println("✅ Đã cập nhật " + months.size() + " tháng tùy chỉnh trong DB");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    //lấy thông tin tháng tùy chỉnh dựa trên ngày hiện tại
    public static MonthRange getCustomMonthInfo(String userId, LocalDateTime now) {
        String sql = """
                    SELECT month_number, start_date, end_date
                    FROM custom_months
                    WHERE user_id = ?
                      AND ? BETWEEN start_date AND end_date
                    LIMIT 1
                """;

        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);
            ps.setTimestamp(2, Timestamp.valueOf(now));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int month = rs.getInt("month_number");
                    LocalDateTime start = rs.getTimestamp("start_date").toLocalDateTime();
                    LocalDateTime end = rs.getTimestamp("end_date").toLocalDateTime();
                    return new MonthRange(month, start, end);
                }
            }

        } catch (SQLException e) {
            System.err.println("Lỗi khi lấy custom month info: " + e.getMessage());
        }

        return null; // không có tháng nào chứa ngày hiện tại
    }

    //lấy thông tin tháng tùy chỉnh dựa trên số tháng
    public static MonthRange getCustomMonthInfoByMonth(String userId, String month) {
        String sql = """
                    SELECT month_number, start_date, end_date
                    FROM custom_months
                    WHERE user_id = ?
                      AND month_number=?
                    LIMIT 1
                """;

        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);
            ps.setInt(2, Integer.parseInt(month));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int monthh = rs.getInt("month_number");
                    LocalDateTime start = rs.getTimestamp("start_date").toLocalDateTime();
                    LocalDateTime end = rs.getTimestamp("end_date").toLocalDateTime();
                    return new MonthRange(monthh, start, end);
                }
            }

        } catch (SQLException e) {
            System.err.println("Lỗi khi lấy custom month info: " + e.getMessage());
        }

        return null; // không có tháng nào chứa ngày hiện tại
    }

    //delate All Data of User ID  in Custom Months
    public static void deleteCustomMonthsByUserId(String userId) {
        String sql = "DELETE FROM custom_months WHERE user_id = ?";

        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.executeUpdate();
            System.out.println("✅ Đã xóa tất cả tháng tùy chỉnh của userId: " + userId);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void deleteAll() {
        deleteCustomMonthsByUserId(CurrentUser.getInstance().getUserId());
        CategoryDao.deleteCategoriesByUserId(CurrentUser.getInstance().getUserId());
        ItemDao.deleteItemsByUserId(CurrentUser.getInstance().getUserId());
    }
    // Thêm vào class Utility
    public static int getStartDayOfUser(String userId) {
        // Lấy ngày bắt đầu của tháng 1 (hoặc tháng bất kỳ) để biết quy luật ngày
        // Mặc định là ngày 1 nếu chưa cài đặt
        String sql = "SELECT start_date FROM custom_months WHERE user_id = ? LIMIT 1";
        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Timestamp ts = rs.getTimestamp("start_date");
                if (ts != null) {
                    return ts.toLocalDateTime().getDayOfMonth();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 1; // Mặc định là ngày 1 tây
    }

    // --- CÁC HÀM KHỞI TẠO DỮ LIỆU NGƯỜI DÙNG MỚI ---

    // 1. Tạo chu kỳ tháng mặc định (Ngày bắt đầu = 1)
    public static void createCustomMonthInDB(String userId) {
        int currentMonth = java.time.LocalDate.now().getMonthValue();
        // Tạo 12 tháng, bắt đầu từ ngày 1 của tháng hiện tại
        List<MonthRange> months = MonthRange.generateCustomMonths(1, currentMonth, currentMonth);
        saveCustomMonthsToDB(userId, months);
    }

    // 2. Hàm tổng hợp: Tạo Category mặc định + Tháng mặc định
    public static void initUserDefaultData(String userId) {
        // A. Tạo tháng tùy chỉnh
        createCustomMonthInDB(userId);

        // B. Tạo 3 Category mặc định (Ăn uống, Mua sắm, Quần áo)
        CategoryDao cd = new CategoryDao();

        // Lưu ý: Constructor Category(userId, name, type, limitAmount)
        // Limit để null nghĩa là không giới hạn
        String id1 = generateID("categories");
        String id2 = generateID("categories");
        String id3 = generateID("categories");
        cd.addCategory(new Category( id1,userId, "Ăn uống", "EXPENSE", 0));
        cd.addCategory(new Category( id2,userId, "Mua sắm", "EXPENSE", 0));
        cd.addCategory(new Category( id3,userId, "Quần áo", "EXPENSE", 0));
    }
    public static String hashPassword(String password) {
        try {
            // Gọi thuật toán SHA-256
            MessageDigest md = MessageDigest.getInstance("SHA-256");

            // Chuyển password sang mảng byte và băm
            byte[] hashedBytes = md.digest(password.getBytes());

            // Chuyển mảng byte thành chuỗi Hex (ký tự đọc được)
            StringBuilder sb = new StringBuilder();
            for (byte b : hashedBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            return null;
        }
    }
}
/*
LocalDate userInput = LocalDate.of(2025, 10, 14); // ngày user chọn
List<MonthRange> months = generateCustomMonths(userInput);
saveCustomMonthsToDB("U1", months);

* */