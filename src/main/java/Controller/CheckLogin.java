package Controller;

import Model.BO.CurrentUser;
import Model.BO.User;
import Model.DAO.UserDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet(urlPatterns ="/CheckLogin")
public class CheckLogin extends HttpServlet {
    UserDao userDao = new UserDao();
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        User user= userDao.validateUser(username,password);
        if( user!=null){
            HttpSession session = req.getSession();
            session.setAttribute("username", username);
            Cookie userCookie = new Cookie("username", username);
            userCookie.setMaxAge(60 * 60 * 24 * 7); // sống 7 ngày
            resp.addCookie(userCookie);
            CurrentUser.getInstance().setUserId(user.getUserId());
            CurrentUser.getInstance().setUsername(user.getUsername());
            CurrentUser.getInstance().setPassword(user.getPassword());

            resp.sendRedirect("Main?action=expenseMain");
        }
        else {
            req.setAttribute("error","Username or password incorrect");
            // Đã sửa đường dẫn
            req.getRequestDispatcher("/Views/Login/Login.jsp").forward(req,resp);
        }
    }
}