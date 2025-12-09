package Model.DAO;

import Database.ConnectionDb;
import Model.BO.CurrentUser;
import Model.BO.Item;
import Model.BO.MonthRange;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class ItemDao {

    public boolean createItem(Item item) {
        String id = Utility.generateID("items");
        String sql = "insert into items (item_id, user_id, category_id, amount, description, created_at) values (?, ?, ?, ?, ?, ?)";
        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setString(1, id);
            ps.setString(2, CurrentUser.getInstance().getUserId());
            ps.setString(3, item.getCategoryId());
            ps.setDouble(4, item.getAmount());
            ps.setString(5, item.getDescribe());
            ps.setTimestamp(6, Timestamp.valueOf(item.getCreatedAt()));
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public boolean updateItem(Item item) {
        String sql = "update items set  description=?, amount=?,created_at=?,category_id=? where item_id=?";
        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, item.getDescribe());
            ps.setDouble(2, item.getAmount());
            ps.setTimestamp(3, Timestamp.valueOf(item.getCreatedAt()));
            ps.setString(4, item.getCategoryId());
            ps.setString(5, item.getItemId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public boolean deleteItem(String itemId) {
        String sql = "delete from items where item_id=?";
        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setString(1, itemId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    // Xóa tất cả items theo userId
    public static boolean deleteItemsByUserId(String userId) {
        String sql = "DELETE i FROM items i " +
                "JOIN categories c ON i.category_id = c.category_id " +
                "WHERE c.user_id = ?";
        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    // Lấy tổng theo loại và khoảng thời gian
    public double getTotalByTypeAndDateRange(String userId, String type, LocalDateTime startDate, LocalDateTime endDate) {
        String sql = "SELECT SUM(i.amount) AS total " +
                "FROM items i " +
                "JOIN categories c ON i.category_id = c.category_id " +
                "WHERE c.user_id = ? AND c.type = ? " +
                "AND i.created_at BETWEEN ? AND ?";

        double total = 0;

        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);
            ps.setString(2, type);
            ps.setTimestamp(3, Timestamp.valueOf(startDate));
            ps.setTimestamp(4, Timestamp.valueOf(endDate));

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                total = rs.getDouble("total");
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return total;
    }

    // Lấy items chi tiết
    public List<Item> getItemsByCategoryAndRange(String userId, String categoryId, LocalDateTime startDate, LocalDateTime endDate) {
        List<Item> items = new ArrayList<>();

        String sql = """
                    SELECT item_id, user_id, category_id, amount, description, created_at
                    FROM items
                    WHERE user_id = ?
                      AND category_id = ?
                      AND created_at BETWEEN ? AND ?
                    ORDER BY created_at DESC
                """;
        // Note: Sửa thành DESC để thấy mới nhất trước

        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);
            ps.setString(2, categoryId);
            ps.setTimestamp(3, Timestamp.valueOf(startDate));
            ps.setTimestamp(4, Timestamp.valueOf(endDate));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Item item = new Item();
                    item.setItemId(rs.getString("item_id"));
                    item.setUserId(rs.getString("user_id"));
                    item.setCategoryId(rs.getString("category_id"));
                    item.setAmount(rs.getDouble("amount"));
                    item.setDescribe(rs.getString("description"));
                    item.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
                    items.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }
    // Thêm vào ItemDao.java
    public double getSumByCategoryAndDate(String userId, String categoryId, LocalDateTime start, LocalDateTime end) {
        String sql = "SELECT SUM(amount) FROM items WHERE user_id = ? AND category_id = ? AND created_at BETWEEN ? AND ?";
        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, categoryId);
            ps.setTimestamp(3, Timestamp.valueOf(start));
            ps.setTimestamp(4, Timestamp.valueOf(end));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Hàm lấy 1 item cụ thể để fill dữ liệu khi bấm Edit
    public Item getItemById(String itemId) {
        String sql = "SELECT * FROM items WHERE item_id = ?";
        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, itemId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new Item(
                        rs.getString("item_id"),
                        rs.getString("user_id"),
                        rs.getString("category_id"),
                        rs.getDouble("amount"),
                        rs.getString("description"),
                        rs.getTimestamp("created_at").toLocalDateTime()
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    //  Hàm lấy danh sách Item theo khoảng thời gian, kèm theo tên category
    public List<Item> getItemsByDateRangeWithCategoryName(String userId, LocalDateTime startDate, LocalDateTime endDate) {
        List<Item> items = new ArrayList<>();
        // Join để lấy luôn tên category
        String sql = """
            SELECT i.*, c.name as category_name
            FROM items i
            JOIN categories c ON i.category_id = c.category_id
            WHERE i.user_id = ? 
            AND i.created_at BETWEEN ? AND ?
            ORDER BY i.created_at DESC
        """;

        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);
            ps.setTimestamp(2, Timestamp.valueOf(startDate));
            ps.setTimestamp(3, Timestamp.valueOf(endDate));

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Item item = new Item();
                item.setItemId(rs.getString("item_id"));
                item.setUserId(rs.getString("user_id"));
                item.setCategoryId(rs.getString("category_id"));
                item.setAmount(rs.getDouble("amount"));
                item.setDescribe(rs.getString("description"));
                item.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());

                // Set thêm tên category
                item.setCategoryName(rs.getString("category_name"));

                items.add(item);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }
}