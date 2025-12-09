package Controller;

import Model.BO.User;
import Model.DAO.UserDao;
import Model.DAO.Utility;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(urlPatterns = "/Register")
public class Register extends HttpServlet {
    UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Đã sửa đường dẫn
        req.getRequestDispatcher("/Views/Login/Register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        // 1. Kiểm tra mật khẩu xác nhận
        if (!password.equals(confirmPassword)) {
            req.setAttribute("error", "Mật khẩu xác nhận không khớp!");
            // Đã sửa đường dẫn
            req.getRequestDispatcher("/Views/Login/Register.jsp").forward(req, resp);
            return;
        }

        // 2. Kiểm tra tài khoản tồn tại
        if (userDao.checkUsernameExist(username)) {
            req.setAttribute("error", "Tên đăng nhập đã tồn tại!");
            // Đã sửa đường dẫn
            req.getRequestDispatcher("/Views/Login/Register.jsp").forward(req, resp);
            return;
        }

        // 3. Thực hiện đăng ký
        if (userDao.signUp(username, password)) {
            User newUser= userDao.getUserByUsername(username);
            Utility.initUserDefaultData( newUser.getUserId());
            // Đăng ký thành công -> Chuyển về trang Login
            resp.sendRedirect(req.getContextPath() + "/Login?msg=registered");
        } else {
            req.setAttribute("error", "Đăng ký thất bại, vui lòng thử lại!");
            // Đã sửa đường dẫn
            req.getRequestDispatcher("/Views/Login/Register.jsp").forward(req, resp);
        }
    }
}