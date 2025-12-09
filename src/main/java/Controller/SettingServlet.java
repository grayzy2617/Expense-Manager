package Controller;

import Model.BO.CurrentUser;
import Model.BO.MonthRange;
import Model.DAO.Utility;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet("/SettingServlet")
public class SettingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost( request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("customStartDay".equals(action)) {
            System.out.println("Custom Start Day requested");
            request.setAttribute("startDay", 1);
            // Đã sửa đường dẫn
            request.getRequestDispatcher("/Views/Setting/customStartDay.jsp").forward(request, response);
            return;
        }

        if(action.equals("viewSettings")){
            // Đã sửa đường dẫn
            response.sendRedirect(request.getContextPath()+"/Views/Setting/settings.jsp");
            return;
        }

        if ("deleteAll".equals(action)) {
            Utility.deleteAll();
            response.sendRedirect(request.getContextPath() + "/Views/Setting/settings.jsp?msg=deleted");
        }

        if ("previewRange".equals(action)) {
            int startDay = Integer.parseInt(request.getParameter("startDay"));
            int currentMonth = LocalDate.now().getMonthValue();
            List<MonthRange> list = MonthRange.generateCustomMonths(startDay, currentMonth, currentMonth);
            MonthRange preview = list.get(0);
            int monthBefore = preview.getMonth() +1;
            if (monthBefore == 13) monthBefore = 1;
            int monthAfter = preview.getMonth();

            request.setAttribute("startDay", startDay);
            request.setAttribute("preview", preview);
            request.setAttribute("monthBefore", monthBefore);
            request.setAttribute("monthAfter", monthAfter);

            // Đã sửa đường dẫn
            request.getRequestDispatcher("/Views/Setting/customStartDay.jsp").forward(request, response);
            return;
        }

        if ("saveStartDay".equals(action)) {
            int startDay = Integer.parseInt(request.getParameter("startDay"));
            int chosenMonth = Integer.parseInt(request.getParameter("chosenMonth"));
            int month= LocalDate.now().getMonthValue();
            System.out.println("Saving custom start day: " + startDay + " for month: " + chosenMonth);
            List<MonthRange> months = MonthRange.generateCustomMonths(startDay, month, chosenMonth);

            String userId = CurrentUser.getInstance().getUserId();
            Utility.updateCustomMonthsInDB(userId, months);

            // Đã sửa đường dẫn
            response.sendRedirect(request.getContextPath()+"/Views/Setting/settings.jsp?msg=saved");
            return;
        }
    }
}