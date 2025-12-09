package Model.DAO;

import Database.ConnectionDb;
import Model.BO.Category;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class CategoryDao {

    // Lấy danh sách category (cho trang Manager/Main)
    public List<Category> getCategory(String userId, String type) {
        // Lấy thêm cột totalAmount (trong DB là hạn mức)
        String sql = "SELECT * FROM categories WHERE user_id = ? AND type = ?";
        List<Category> categories = new ArrayList<>();

        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);
            ps.setString(2, type);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Category c = new Category();
                    c.setCategoryId(rs.getString("category_id"));
                    c.setUserId(rs.getString("user_id"));
                    c.setName(rs.getString("name"));
                    c.setType(rs.getString("type"));


                    // Map cột totalAmount DB -> limitAmount Java
                    double dbLimit = rs.getDouble("totalAmount");
                    if (!rs.wasNull()) {
                        c.setLimitAmount(dbLimit);
                    }

                    categories.add(c);
                }
            }

        } catch (Exception e) {
            throw new RuntimeException(e);
        }

        return categories;
    }

    // Lấy danh sách cho báo cáo (QUAN TRỌNG: Cần lấy Limit ra để so sánh)
    public List<Category> getByMonth(String userId, LocalDateTime startDate, LocalDateTime endDate, String typee) {
        List<Category> list = new ArrayList<>();
        // Group by thêm c.totalAmount (đây là cột limit trong DB)
        String sql = """
                    SELECT c.category_id, c.name, c.totalAmount AS limitVal, SUM(i.amount) AS spentSum
                    FROM items i
                    JOIN categories c ON i.category_id = c.category_id
                    WHERE i.user_id = ? AND i.created_at BETWEEN ? AND ?
                      AND c.type = ?
                    GROUP BY c.category_id, c.name, c.totalAmount
                    ORDER BY spentSum DESC
                """;

        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);
            ps.setTimestamp(2, Timestamp.valueOf(startDate));
            ps.setTimestamp(3, Timestamp.valueOf(endDate));
            ps.setString(4, typee);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Category cat = new Category();
                cat.setCategoryId(rs.getString("category_id"));
                cat.setName(rs.getString("name"));

                // Set tổng chi tiêu
                cat.setTotalAmount(rs.getDouble("spentSum"));

                // Set hạn mức (Limit)
                double limit = rs.getDouble("limitVal");
                if (!rs.wasNull()) {
                    cat.setLimitAmount(limit);
                }

                list.add(cat);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Hàm thêm mới (Cập nhật insert limit)
    public boolean addCategory(Category category) {
        String id = Utility.generateID("categories");
        // Thêm cột totalAmount vào câu insert
        String sql = "insert into categories(category_id, user_id, name, type, totalAmount) values (?,?,?,?,?)";
        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);) {
            ps.setString(1, id);
            ps.setString(2, category.getUserId());
            ps.setString(3, category.getName());
            ps.setString(4, category.getType());

            // Xử lý limit null
            if (category.getLimitAmount() != null) {
                ps.setDouble(5, category.getLimitAmount());
            } else {
                ps.setDouble(5, 0.0);
            }

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    // Hàm update (Cập nhật limit)
    public boolean updateCategory(Category category) {
        String sql = "update categories set name=?, totalAmount=? where category_id=?";
        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);) {
            ps.setString(1, category.getName());

            if (category.getLimitAmount() != null) {
                ps.setDouble(2, category.getLimitAmount());
            } else {
                ps.setNull(2, java.sql.Types.DOUBLE);
            }

            ps.setString(3, category.getCategoryId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public boolean deleteCategory(String userid, String id) {
        String sql = "delete from categories where category_id=? and user_id=? ";
        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);) {
            ps.setString(1, id);
            ps.setString(2, userid);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    // Lấy chi tiết category để edit (cần lấy limit)
    public Category getCategoryById(String categoryId) {
        String sql = "SELECT * FROM categories WHERE category_id = ?";
        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Category category = new Category();
                    category.setCategoryId(rs.getString("category_id"));
                    category.setUserId(rs.getString("user_id"));
                    category.setName(rs.getString("name"));
                    category.setType(rs.getString("type"));
                    double dbLimit = rs.getDouble("totalAmount");
                    if (!rs.wasNull()) category.setLimitAmount(dbLimit);

                    return category;
                }
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return null;
    }

    public static boolean deleteCategoriesByUserId(String userId) {
        String sql = "DELETE FROM categories WHERE user_id = ?";
        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
        }
        return false;
    }

    public List<Category> getByYear(String userId, int year, String typee, int startday) {
        LocalDateTime startDate = LocalDateTime.of(year - 1, 12, startday, 0, 0);
        LocalDateTime endDate = LocalDateTime.of(year, 12, startday - 1, 23, 59, 59);
        return getByMonth(userId, startDate, endDate, typee);
    }

    public boolean checkSavingViewInReport(String categoryId) {
        String sql = "SELECT view_in_report FROM savings WHERE category_id = ?";
        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBoolean("view_in_report");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false; // Mặc định false hoặc true tùy bạn chọn nếu không tìm thấy
    }
}