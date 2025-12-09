package Controller;

import Model.BO.Category;
import Model.BO.CurrentUser;
import Model.BO.Item;
import Model.BO.MonthRange;
import Model.DAO.CategoryDao;
import Model.DAO.ItemDao;
import Model.DAO.Utility;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

@WebServlet(urlPatterns = "/Report")
public class Report extends HttpServlet {
    ItemDao itemDao = new ItemDao();
    CategoryDao categoryDao = new CategoryDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        processRequest(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        processRequest(req, resp);
    }

    private void processRequest(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        String userId = CurrentUser.getInstance().getUserId();
        String action = req.getParameter("action");

        if ("deleteItem".equals(action)) {
            String itemId = req.getParameter("itemId");
            if (itemId != null) {
                itemDao.deleteItem(itemId);
            }
            String currentMode = (String) session.getAttribute("report_mode");
            String idCategoryParam = req.getParameter("idCategory");
            if ("DAY".equals(currentMode) && (idCategoryParam == null || idCategoryParam.isEmpty())) {
                resp.sendRedirect("Report");
            } else {
                handleDetailCategory(req, resp, session, userId);
            }
            return;
        }

        if ("editItem".equals(action)) {
            String itemId = req.getParameter("itemId");
            Item item = itemDao.getItemById(itemId);
            if (item != null) {
                Category cat = categoryDao.getCategoryById(item.getCategoryId());
                session.setAttribute("tempItemId", item.getItemId());
                session.setAttribute("tempDescription", item.getDescribe());
                session.setAttribute("tempAmount", String.valueOf((long)item.getAmount()));
                session.setAttribute("tempCategoryId", item.getCategoryId());
                session.setAttribute("tempDay", item.getCreatedAt().toString());
                session.setAttribute("tempType", cat.getType());
                String redirectAction = "EXPENSE".equals(cat.getType()) ? "expenseMain" : "incomeMain";
                resp.sendRedirect("Main?action=" + redirectAction);
            }
            return;
        }

        if ("detailCategory".equals(action)) {
            handleDetailCategory(req, resp, session, userId);
            return;
        }

        // --- VIEW REPORT CHÍNH ---
        String type = req.getParameter("type");
        if (type == null) type = (String) session.getAttribute("report_type");
        if (type == null) type = "EXPENSE";

        String mode = req.getParameter("mode");
        if (mode == null) mode = (String) session.getAttribute("report_mode");
        if (mode == null) mode = "MONTH";

        int selectedYear = LocalDateTime.now().getYear();
        int selectedMonth = LocalDateTime.now().getMonthValue();

        String reqYear = req.getParameter("selectedYear");
        String reqMY = req.getParameter("selectedMY");

        if (reqMY != null && !reqMY.isEmpty()) {
            try {
                YearMonth ym = YearMonth.parse(reqMY);
                selectedYear = ym.getYear();
                selectedMonth = ym.getMonthValue();
            } catch (Exception e) { e.printStackTrace(); }
        } else if (reqYear != null && !reqYear.isEmpty()) {
            try {
                selectedYear = Integer.parseInt(reqYear);
            } catch (NumberFormatException e) { e.printStackTrace(); }
        } else {
            if (session.getAttribute("report_year") != null) selectedYear = (Integer) session.getAttribute("report_year");
            if (session.getAttribute("report_month") != null) selectedMonth = (Integer) session.getAttribute("report_month");
        }

        session.setAttribute("report_type", type);
        session.setAttribute("report_mode", mode);
        session.setAttribute("report_year", selectedYear);
        session.setAttribute("report_month", selectedMonth);

        int startDay = Utility.getStartDayOfUser(userId);
        LocalDateTime startDate;
        LocalDateTime endDate;

        if ("YEAR".equals(mode)) {
            startDate = LocalDateTime.of(selectedYear, 1, startDay, 0, 0, 0);
            endDate = startDate.plusYears(1).minusSeconds(1);
        } else {
            startDate = LocalDateTime.of(selectedYear, selectedMonth, startDay, 0, 0, 0);
            endDate = startDate.plusMonths(1).minusSeconds(1);
        }

        double sumIncome = itemDao.getTotalByTypeAndDateRange(userId, "INCOME", startDate, endDate);
        double sumExpense = itemDao.getTotalByTypeAndDateRange(userId, "EXPENSE", startDate, endDate);
        List<Category> savingCats = categoryDao.getByMonth(userId, startDate, endDate, "SAVING");
        double sumSavingVisible = 0;

        for (Category s : savingCats) {
            if (categoryDao.checkSavingViewInReport(s.getCategoryId())) {
                sumSavingVisible += s.getTotalAmount();
            }
        }
        sumExpense += sumSavingVisible;
        double totalBalance = sumIncome - sumExpense;

        if ("DAY".equals(mode)) {
            List<Item> allItems = itemDao.getItemsByDateRangeWithCategoryName(userId, startDate, endDate);
            List<Item> filteredItems = new ArrayList<>();
            for (Item item : allItems) {
                Category cat = categoryDao.getCategoryById(item.getCategoryId());
                if (cat != null) {
                    String catType = "SAVING".equals(cat.getType()) ? "EXPENSE" : cat.getType();
                    if (catType.equals(type)) {
                        if ("SAVING".equals(cat.getType())) {
                            if (categoryDao.checkSavingViewInReport(item.getCategoryId())) {
                                filteredItems.add(item);
                            }
                        } else {
                            filteredItems.add(item);
                        }
                    }
                }
            }
            req.setAttribute("dailyItems", filteredItems);
        } else {
            List<Category> list = categoryDao.getByMonth(userId, startDate, endDate, type);
            if ("EXPENSE".equals(type)) {
                for (Category s : savingCats) {
                    if (categoryDao.checkSavingViewInReport(s.getCategoryId())) {
                        list.add(s);
                    }
                }
            }
            req.setAttribute("categoryList", list);
        }

        MonthRange mr = new MonthRange(selectedMonth, startDate, endDate);
        req.setAttribute("totalBalance", totalBalance);
        req.setAttribute("totalIncome", sumIncome);
        req.setAttribute("totalExpense", sumExpense);
        req.setAttribute("monthRange", mr);
        req.setAttribute("type", type);
        req.setAttribute("mode", mode);
        req.setAttribute("year", selectedYear);
        req.setAttribute("month", selectedMonth);

        // Đã sửa đường dẫn
        req.getRequestDispatcher("/Views/Report/Report.jsp").forward(req, resp);
    }

    private void handleDetailCategory(HttpServletRequest req, HttpServletResponse resp, HttpSession session, String userId) throws ServletException, IOException {
        String categoryId = req.getParameter("idCategory");
        if(categoryId == null || categoryId.isEmpty()) categoryId = (String) req.getAttribute("currentCategoryId");

        String mode = (String) session.getAttribute("report_mode");
        int year = (Integer) session.getAttribute("report_year");
        int month = (Integer) session.getAttribute("report_month");
        String type = (String) session.getAttribute("report_type");

        int startDay = Utility.getStartDayOfUser(userId);
        LocalDateTime startDate, endDate;

        if ("YEAR".equals(mode)) {
            startDate = LocalDateTime.of(year, 1, startDay, 0, 0, 0);
            endDate = startDate.plusYears(1).minusSeconds(1);
        } else {
            startDate = LocalDateTime.of(year, month, startDay, 0, 0, 0);
            endDate = startDate.plusMonths(1).minusSeconds(1);
        }

        List<Item> items = itemDao.getItemsByCategoryAndRange(userId, categoryId, startDate, endDate);
        Category category = categoryDao.getCategoryById(categoryId);

        List<Map<String, Object>> chartData = new ArrayList<>();
        double maxChartValue = 0;
        if ("MONTH".equals(mode)) {
            for (int i = 3; i >= 0; i--) {
                LocalDateTime base = startDate.minusMonths(i);
                LocalDateTime subEnd = base.plusMonths(1).minusSeconds(1);
                double amount = itemDao.getSumByCategoryAndDate(userId, categoryId, base, subEnd);
                if (amount > maxChartValue) maxChartValue = amount;
                Map<String, Object> col = new HashMap<>();
                col.put("label", "T" + base.getMonthValue());
                col.put("amount", amount);
                chartData.add(col);
            }
        }

        req.setAttribute("items", items);
        req.setAttribute("category", category);
        req.setAttribute("categoryId", categoryId);
        req.setAttribute("chartData", chartData);
        req.setAttribute("maxChartValue", maxChartValue);
        req.setAttribute("type", type);
        req.setAttribute("range", mode);
        req.setAttribute("year", year);
        if ("MONTH".equals(mode)) req.setAttribute("month", month);
        req.setAttribute("currentCategoryId", categoryId);

        // Đã sửa đường dẫn
        req.getRequestDispatcher("/Views/Report/detailCategory.jsp").forward(req, resp);
    }
}