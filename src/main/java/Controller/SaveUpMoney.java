package Controller;

import Model.BO.CurrentUser;
import Model.BO.Item;
import Model.BO.Saving;
import Model.DAO.ItemDao;
import Model.DAO.SavingDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet(urlPatterns = "/SaveUpMoney")
public class SaveUpMoney extends HttpServlet {
    SavingDao savingDao = new SavingDao();
    ItemDao itemDao = new ItemDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        process(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        process(req, resp);
    }

    private void process(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if (action == null) action = "view";

        String userId = CurrentUser.getInstance().getUserId();

        switch (action) {
            case "view":
                viewSavings(req, resp, userId);
                break;
            case "formAdd":
                // Đã sửa đường dẫn
                req.getRequestDispatcher("/Views/Saving/SavingAddForm.jsp").forward(req, resp);
                break;
            case "add":
                handleAdd(req, resp, userId);
                break;
            case "detail":
                viewDetail(req, resp);
                break;
            case "transaction":
                handleTransaction(req, resp, userId);
                break;
            case "updateTransaction":
                handleUpdateTransaction(req, resp);
                break;
            case "deleteTransaction":
                deleteTransaction(req, resp);
                break;
            case "formEditSaving":
                formEditSaving(req, resp);
                break;
            case "editSaving":
                handleEditSaving(req, resp);
                break;
            case "toggleStatus":
                handleToggleStatus(req, resp);
                break;
            case "deleteSaving":
                handleDeleteSaving(req, resp, userId);
                break;
            default:
                viewSavings(req, resp, userId);
        }
    }

    private void viewSavings(HttpServletRequest req, HttpServletResponse resp, String userId) throws ServletException, IOException {
        String tab = req.getParameter("tab");
        if(tab == null) tab = "ongoing";
        boolean status = "ongoing".equals(tab);
        List<Saving> list = savingDao.getSavingsByStatus(userId, status);
        req.setAttribute("list", list);
        req.setAttribute("tab", tab);
        // Đã sửa đường dẫn
        req.getRequestDispatcher("/Views/Saving/SavingMain.jsp").forward(req, resp);
    }

    private void handleAdd(HttpServletRequest req, HttpServletResponse resp, String userId) throws IOException {
        try {
            String name = req.getParameter("name");
            String targetStr = req.getParameter("target").replace(",", "").replace(".", "");
            double target = Double.parseDouble(targetStr);
            LocalDateTime start = LocalDateTime.parse(req.getParameter("start"));
            LocalDateTime end = LocalDateTime.parse(req.getParameter("end"));
            boolean viewReport = req.getParameter("viewInReport") != null;
            Saving s = new Saving(userId, name, target, start, end, viewReport);
            if(savingDao.addSaving(s)) {
                resp.sendRedirect("SaveUpMoney?action=view&tab=ongoing");
            } else {
                resp.sendRedirect("SaveUpMoney?action=formAdd&error=1");
            }
        } catch (Exception e) { e.printStackTrace(); resp.sendRedirect("SaveUpMoney?action=formAdd&error=1"); }
    }

    private void viewDetail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String id = req.getParameter("id");
        Saving s = savingDao.getSavingById(id);
        LocalDateTime min = LocalDateTime.of(2000,1,1,0,0);
        LocalDateTime max = LocalDateTime.of(2100,1,1,0,0);
        List<Item> transactions = itemDao.getItemsByCategoryAndRange(s.getUserId(), id, min, max);
        req.setAttribute("saving", s);
        req.setAttribute("transactions", transactions);
        // Đã sửa đường dẫn
        req.getRequestDispatcher("/Views/Saving/SavingDetail.jsp").forward(req, resp);
    }

    private void handleTransaction(HttpServletRequest req, HttpServletResponse resp, String userId) throws ServletException, IOException {
        String savingId = req.getParameter("savingId");
        Saving currentSaving = savingDao.getSavingById(savingId);

        try {
            double amount = Double.parseDouble(req.getParameter("amount"));
            String type = req.getParameter("transType");
            String desc = req.getParameter("description");
            LocalDateTime date = LocalDateTime.parse(req.getParameter("date"));

            if ("withdraw".equals(type)) {
                if (amount > currentSaving.getSavedAmount()) {
                    req.setAttribute("errorMessage", "Số dư không đủ để rút! (Hiện có: "
                            + String.format("%,.0f", currentSaving.getSavedAmount()) + " đ)");
                    req.setAttribute("saving", currentSaving);
                    LocalDateTime min = LocalDateTime.of(2000, 1, 1, 0, 0);
                    LocalDateTime max = LocalDateTime.of(2100, 1, 1, 0, 0);
                    List<Item> transactions = itemDao.getItemsByCategoryAndRange(userId, savingId, min, max);
                    req.setAttribute("transactions", transactions);
                    // Đã sửa đường dẫn
                    req.getRequestDispatcher("/Views/Saving/SavingDetail.jsp").forward(req, resp);
                    return;
                }
                amount = -amount;
            }

            Item item = new Item(savingId, amount, desc, date);
            itemDao.createItem(item);
            resp.sendRedirect("SaveUpMoney?action=detail&id=" + savingId);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect("SaveUpMoney?action=view");
        }
    }

    private void handleUpdateTransaction(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            String savingId = req.getParameter("savingId");
            String itemId = req.getParameter("itemId");
            double amount = Double.parseDouble(req.getParameter("amount"));
            String type = req.getParameter("transType");
            String desc = req.getParameter("description");
            LocalDateTime date = LocalDateTime.parse(req.getParameter("date"));

            if ("withdraw".equals(type)) {
                amount = -Math.abs(amount);
            } else {
                amount = Math.abs(amount);
            }

            Item item = new Item();
            item.setItemId(itemId);
            item.setCategoryId(savingId);
            item.setAmount(amount);
            item.setDescribe(desc);
            item.setCreatedAt(date);

            itemDao.updateItem(item);

            resp.sendRedirect("SaveUpMoney?action=detail&id=" + savingId);
        } catch (Exception e) {
            e.printStackTrace();
            String savingId = req.getParameter("savingId");
            if(savingId != null) resp.sendRedirect("SaveUpMoney?action=detail&id=" + savingId);
            else resp.sendRedirect("SaveUpMoney?action=view");
        }
    }

    private void deleteTransaction(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String itemId = req.getParameter("itemId");
        String savingId = req.getParameter("savingId");
        itemDao.deleteItem(itemId);
        resp.sendRedirect("SaveUpMoney?action=detail&id=" + savingId);
    }

    private void handleDeleteSaving(HttpServletRequest req, HttpServletResponse resp, String userId) throws IOException {
        String id = req.getParameter("id");
        savingDao.deleteSaving(id);
        resp.sendRedirect("SaveUpMoney?action=view");
    }

    private void handleToggleStatus(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String id = req.getParameter("id");
        Saving s = savingDao.getSavingById(id);
        if(s != null) {
            s.setStatus(!s.isStatus());
            savingDao.updateSaving(s);
            String tab = s.isStatus() ? "ongoing" : "finished";
            resp.sendRedirect("SaveUpMoney?action=view&tab=" + tab);
        }
    }

    private void formEditSaving(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String id = req.getParameter("id");
        Saving s = savingDao.getSavingById(id);
        req.setAttribute("saving", s);
        // Đã sửa đường dẫn
        req.getRequestDispatcher("/Views/Saving/SavingAddForm.jsp").forward(req, resp);
    }

    private void handleEditSaving(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            String id = req.getParameter("id");
            Saving s = savingDao.getSavingById(id);
            s.setName(req.getParameter("name"));
            String targetStr = req.getParameter("target").replace(",", "").replace(".", "");
            s.setLimitAmount(Double.parseDouble(targetStr));
            s.setStartDate(LocalDateTime.parse(req.getParameter("start")));
            s.setEndDate(LocalDateTime.parse(req.getParameter("end")));
            s.setViewInReport(req.getParameter("viewInReport") != null);
            savingDao.updateSaving(s);
            resp.sendRedirect("SaveUpMoney?action=detail&id=" + id);
        } catch (Exception e) { e.printStackTrace(); }
    }
}