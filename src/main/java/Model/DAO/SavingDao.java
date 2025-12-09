package Model.DAO;

import Database.ConnectionDb;
import Model.BO.Saving;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SavingDao {
    private CategoryDao categoryDao = new CategoryDao();

    // Lấy danh sách Saving theo trạng thái (ONGOING / FINISHED)
    public List<Saving> getSavingsByStatus(String userId, boolean status) {
        List<Saving> list = new ArrayList<>();
        // Query lấy thông tin Category + Saving + Tổng tiền đã gửi (SUM items)
        String sql = """
            SELECT c.*, s.start_date, s.end_date, s.status, s.view_in_report,
                   COALESCE(SUM(i.amount), 0) as current_saved
            FROM categories c
            JOIN savings s ON c.category_id = s.category_id
            LEFT JOIN items i ON c.category_id = i.category_id
            WHERE c.user_id = ? AND s.status = ?
            GROUP BY c.category_id
            ORDER BY s.end_date ASC
        """;

        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);
            ps.setBoolean(2, status);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Saving s = mapResultSetToSaving(rs);
                list.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy chi tiết 1 Saving
    public Saving getSavingById(String savingId) {
        String sql = """
            SELECT c.*, s.start_date, s.end_date, s.status, s.view_in_report,
                   COALESCE(SUM(i.amount), 0) as current_saved
            FROM categories c
            JOIN savings s ON c.category_id = s.category_id
            LEFT JOIN items i ON c.category_id = i.category_id
            WHERE c.category_id = ?
            GROUP BY c.category_id
        """;
        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, savingId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToSaving(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Thêm mới Saving (Transaction: Add Category -> Add Saving)
    public boolean addSaving(Saving saving) {
        Connection conn = null;
        try {
            conn = ConnectionDb.getConnection();
            conn.setAutoCommit(false); // Bắt đầu transaction

            // 1. Insert vào bảng Categories trước (để lấy ID và Name, Limit)
            // Lưu ý: CategoryDao.addCategory cần ID trả về hoặc ta tự generate ID ở đây
            String catId = Utility.generateID("categories");
            saving.setCategoryId(catId);

            String sqlCat = "INSERT INTO categories (category_id, user_id, name, type, totalAmount) VALUES (?,?,?,?,?)";
            try(PreparedStatement psCat = conn.prepareStatement(sqlCat)){
                psCat.setString(1, catId);
                psCat.setString(2, saving.getUserId());
                psCat.setString(3, saving.getName());
                psCat.setString(4, "SAVING");
                psCat.setDouble(5, saving.getLimitAmount()); // Target
                psCat.executeUpdate();
            }

            // 2. Insert vào bảng Savings
            String sqlSav = "INSERT INTO savings (category_id, start_date, end_date, status, view_in_report) VALUES (?,?,?,?,?)";
            try(PreparedStatement psSav = conn.prepareStatement(sqlSav)){
                psSav.setString(1, catId);
                psSav.setTimestamp(2, Timestamp.valueOf(saving.getStartDate()));
                psSav.setTimestamp(3, Timestamp.valueOf(saving.getEndDate()));
                psSav.setBoolean(4, saving.isStatus());
                psSav.setBoolean(5, saving.isViewInReport());
                psSav.executeUpdate();
            }

            conn.commit(); // Xác nhận
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            try { if(conn!=null) conn.rollback(); } catch(SQLException ex){}
            return false;
        } finally {
            try { if(conn!=null) conn.setAutoCommit(true); conn.close(); } catch(SQLException ex){}
        }
    }

    // Cập nhật Saving
    public boolean updateSaving(Saving saving) {
        Connection conn = null;
        try {
            conn = ConnectionDb.getConnection();
            conn.setAutoCommit(false);

            // 1. Update Category (Tên, Target Amount)
            String sqlCat = "UPDATE categories SET name=?, totalAmount=? WHERE category_id=?";
            try(PreparedStatement psCat = conn.prepareStatement(sqlCat)){
                psCat.setString(1, saving.getName());
                psCat.setDouble(2, saving.getLimitAmount());
                psCat.setString(3, saving.getCategoryId());
                psCat.executeUpdate();
            }

            // 2. Update Saving (Date, ViewInReport, Status)
            String sqlSav = "UPDATE savings SET start_date=?, end_date=?, status=?, view_in_report=? WHERE category_id=?";
            try(PreparedStatement psSav = conn.prepareStatement(sqlSav)){
                psSav.setTimestamp(1, Timestamp.valueOf(saving.getStartDate()));
                psSav.setTimestamp(2, Timestamp.valueOf(saving.getEndDate()));
                psSav.setBoolean(3, saving.isStatus());
                psSav.setBoolean(4, saving.isViewInReport());
                psSav.setString(5, saving.getCategoryId());
                psSav.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            try { if(conn!=null) conn.rollback(); } catch(SQLException ex){}
            return false;
        } finally {
            try { if(conn!=null) conn.setAutoCommit(true); conn.close(); } catch(SQLException ex){}
        }
    }

    // Xóa Saving (Chỉ cần xóa Category, Cascade sẽ xóa Saving và Items)
    public boolean deleteSaving(String savingId) {
        return categoryDao.deleteCategory(null, savingId); // Reuse hàm xóa cũ (lưu ý hàm cũ cần userId để check, nếu bạn đã sửa hàm cũ thì truyền đúng tham số)
        // Ở đây giả sử gọi hàm xóa của CategoryDao là đủ.
    }

    // Helper mapping
    private Saving mapResultSetToSaving(ResultSet rs) throws SQLException {
        Saving s = new Saving();
        s.setCategoryId(rs.getString("category_id"));
        s.setUserId(rs.getString("user_id"));
        s.setName(rs.getString("name"));
        s.setType("SAVING");

        double limit = rs.getDouble("totalAmount"); // Cột này là Target
        if(!rs.wasNull()) s.setLimitAmount(limit);

        s.setStartDate(rs.getTimestamp("start_date").toLocalDateTime());
        s.setEndDate(rs.getTimestamp("end_date").toLocalDateTime());
        s.setStatus(rs.getBoolean("status"));
        s.setViewInReport(rs.getBoolean("view_in_report"));
        s.setSavedAmount(rs.getDouble("current_saved"));
        return s;
    }


}