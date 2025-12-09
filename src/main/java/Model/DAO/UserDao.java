package Model.DAO;

import Database.ConnectionDb;
import Model.BO.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Date;
import java.time.LocalDate;

public class UserDao {

    // Kiểm tra đăng nhập


    // Kiểm tra username đã tồn tại chưa
    public boolean checkUsernameExist(String username) {
        String sql = "SELECT 1 FROM users WHERE username = ?";
        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();
            return rs.next(); // Trả về true nếu đã có
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Đăng ký tài khoản mới
    public boolean signUp(String username, String pw) {
        String hashedPassword = Utility.hashPassword(pw);
        // Sử dụng Utility.generateID đã sửa logic lấy max number
        String id = Utility.generateID("users");
        String sql = "insert into users(user_id, username, password, created_at) values(?,?,?,?)";
        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {


            pstmt.setString(1, id);
            pstmt.setString(2, username);
            pstmt.setString(3, pw);
            pstmt.setString(4, java.sql.Timestamp.valueOf(java.time.LocalDateTime.now()).toString());

            return pstmt.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public User validateUser(String username, String pw) {
        // Logic: Mã hóa cái người dùng vừa nhập, rồi so sánh với cái trong DB
        String hashedInput = Utility.hashPassword(pw);
        String sql = "select * from users where username=? and password=?";
        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            pstmt.setString(2, pw);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return new User(
                        rs.getString("user_id"),
                        rs.getString("username"),
                        rs.getString("password")
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // lấy User theo tên
    public User getUserByUsername(String username) {
        String sql = "select * from users where username=?";
        try (Connection conn = ConnectionDb.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                String id = rs.getString("user_id");
                String username1 = rs.getString("username");
                String password = rs.getString("password");
                return new User(id, username1, password);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}