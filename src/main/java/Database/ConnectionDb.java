package Database;

import java.sql.*;

public class  ConnectionDb {
    public static Connection getConnection() {
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/expense_manager", "root", ""
            );
        } catch (Exception e) {
            e.printStackTrace();
        }
        return conn;
    }
}
