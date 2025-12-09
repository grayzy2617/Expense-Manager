package Controller;

import Model.BO.Category;
import Model.BO.CurrentUser;
import Model.BO.Item;
import Model.DAO.CategoryDao;
import Model.DAO.ItemDao;
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

@WebServlet(urlPatterns = "/Main")
public class Main extends HttpServlet {
    CategoryDao cd = new CategoryDao();
    ItemDao itemDao = new ItemDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        switch (action) {
            case "incomeMain":
                handlerIncomeAndExpenseInMain(req, resp, "INCOME");
                break;
            case "expenseMain":
                handlerIncomeAndExpenseInMain(req, resp, "EXPENSE");
                break;
            case "incomeEdit":
                handlerIncomeAndExpenseInEdit(req, resp, "INCOME");
                break;
            case "expenseEdit":
                handlerIncomeAndExpenseInEdit(req, resp, "EXPENSE");
                break;
            case "save":
                handleSave(req, resp);
                break;
            case "formAddCategory":
                formAddCategory(req, resp);
                break;
            case "addCategory":
                addCategory(req, resp);
                break;
            case "formEditCategory":
                formEditCategory(req, resp);
                break;
            case "editCategory":
                editCategory(req, resp);
                break;
            case "delCategory":
                deleteCategory(req, resp);
                break;
            case "saveTempSession":
                saveTempSession(req, resp);
                break;
            case "returnFromCategoryManager":
                handlerReturnFromCategory(req, resp);
                break;
            default:
                handlerIncomeAndExpenseInMain(req, resp, "EXPENSE");
        }
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        switch (action) {
            case "incomeMain":
                handlerIncomeAndExpenseInMain(req, resp, "INCOME");
                break;
            case "expenseMain":
                handlerIncomeAndExpenseInMain(req, resp, "EXPENSE");
                break;
            case "incomeEdit":
                handlerIncomeAndExpenseInEdit(req, resp, "INCOME");
                break;
            case "expenseEdit":
                handlerIncomeAndExpenseInEdit(req, resp, "EXPENSE");
                break;
            case "save":
                handleSave(req, resp);
                break;
            case "formAddCategory":
                formAddCategory(req, resp);
                break;
            case "addCategory":
                addCategory(req, resp);
                break;
            case "formEditCategory":
                formEditCategory(req, resp);
                break;
            case "editCategory":
                editCategory(req, resp);
                break;
            case "delCategory":
                deleteCategory(req, resp);
                break;
            case "saveTempSession":
                saveTempSession(req, resp);
                break;
            case "returnFromCategoryManager":
                handlerReturnFromCategory(req, resp);
                break;
            default:
                handlerIncomeAndExpenseInMain(req, resp, "EXPENSE");
        }
    }

    public void handlerReturnFromCategory(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        resp.sendRedirect(req.getContextPath() + "/Main?action=" +
                ("INCOME".equals(session.getAttribute("tempType")) ? "incomeMain" : "expenseMain"));
    }

    private void saveTempSession(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        session.setAttribute("tempType", request.getParameter("type"));
        session.setAttribute("tempDescription", request.getParameter("description"));
        session.setAttribute("tempAmount", request.getParameter("amount"));
        session.setAttribute("tempCategoryId", request.getParameter("categoryId"));
        session.setAttribute("tempDay", request.getParameter("day"));

        String type = request.getParameter("type");
        if (type.equals("INCOME"))
            response.sendRedirect("Main?action=incomeEdit");
        else{
            response.sendRedirect("Main?action=expenseEdit");
        }
    }

    public void formEditCategory(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession sessionn = req.getSession();
        sessionn.setAttribute("id", req.getParameter("id"));
        sessionn.setAttribute("name", req.getParameter("name"));
        sessionn.setAttribute("type", req.getParameter("type"));
        sessionn.setAttribute("limit", req.getParameter("limit"));
        if (sessionn.getAttribute("type").equals("INCOME")) {
            sessionn.setAttribute("pagePrev", "incomeEdit");
        } else if (sessionn.getAttribute("type").equals("EXPENSE")) {
            sessionn.setAttribute("pagePrev", "expenseEdit");
        }
        // Đã sửa đường dẫn
        resp.sendRedirect(req.getContextPath() + "/Views/Main/CategoryEditForm.jsp");
    }

    public void editCategory(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String name = req.getParameter("name");
        String type = req.getParameter("type");
        String id = req.getParameter("id");
        double limitAmountStr;
        if (!type.equals("INCOME")) {
            limitAmountStr = Double.valueOf(req.getParameter("limit"));
        } else {
            limitAmountStr = 0.0;
        }
        Category category = new Category();
        category.setCategoryId(id);
        category.setName(name);
        category.setLimitAmount(limitAmountStr);
        String url = getUrl(type, "edit");
        HttpSession sessionn = req.getSession();
        if (cd.updateCategory(category)) {
            sessionn.setAttribute("successMessage", "Chỉnh sửa thành công!");
            resp.sendRedirect("Main?action=" + url);
        } else {
            sessionn.setAttribute("errorMessage", "Lỗi khi chỉnh sửa, kiểm tra lại thông tin đã nhập!");
            req.getRequestDispatcher("Main?action=" + url).forward(req, resp);
        }
    }

    public void formAddCategory(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession ss = req.getSession();
        ss.setAttribute("typeInCateManager", req.getParameter("type"));
        String type = req.getParameter("type");
        System.out.println(type);
        String pagePrev = "expenseEdit";
        if (type.equals("INCOME")) pagePrev = "incomeEdit";
        ss.setAttribute("pagePrev", pagePrev);
        // Đã sửa đường dẫn
        resp.sendRedirect(req.getContextPath() + "/Views/Main/CategoryAddForm.jsp");
    }

    public void addCategory(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String type = req.getParameter("type");
        String name = req.getParameter("name");
        String limit= req.getParameter("limit");
        System.out.println("type: "+type+ " limit "+ req.getParameter("limit"));
        double limitAmountStr;
        if (!type.equals("INCOME")&& limit!=null && !limit.isEmpty()) {
            limitAmountStr = Double.valueOf(limit);
        }
        else {
            limitAmountStr = 0.0;
        }

        String url = getUrl(type, "add");
        Category category = new Category(CurrentUser.getInstance().getUserId(), name, type, limitAmountStr);
        HttpSession session = req.getSession();

        if (cd.addCategory(category)) {
            session.setAttribute("successMessage", "Thêm thành công!");
            resp.sendRedirect("Main?action=" + url);
        } else {
            session.setAttribute("errorMessage", "Lỗi khi thêm, kiểm tra lại thông tin đã nhập!");
            req.getRequestDispatcher("Main?action" + url).forward(req, resp);
        }
    }

    public void deleteCategory(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String type = req.getParameter("type");
        String idCate = req.getParameter("id");
        HttpSession session = req.getSession();
        String url = getUrl(type, "del");
        if (cd.deleteCategory(CurrentUser.getInstance().getUserId(), idCate)) {
            session.setAttribute("successMessage", "Xóa thành công!");
            resp.sendRedirect("Main?action=" + url);
        } else {
            session.setAttribute("errorMessage", "Lỗi khi xóa!");
            req.getRequestDispatcher("Main?action=" + url).forward(req, resp);
        }
    }

    public void handlerIncomeAndExpenseInEdit(HttpServletRequest req, HttpServletResponse resp, String type) throws ServletException, IOException {
        List<Category> list = cd.getCategory(CurrentUser.getInstance().getUserId(), type);
        req.setAttribute("list", list);
        req.setAttribute("type", type);
        // Đã sửa đường dẫn
        req.getRequestDispatcher("/Views/Main/CategoryManage.jsp").forward(req, resp);
    }

    public void handlerIncomeAndExpenseInMain(HttpServletRequest req, HttpServletResponse resp, String type) throws ServletException, IOException {
        List<Category> list = cd.getCategory(CurrentUser.getInstance().getUserId(), type);
        req.setAttribute("list", list);
        req.setAttribute("type", type);
        // Đã sửa đường dẫn
        req.getRequestDispatcher("/Views/Main/Main.jsp").forward(req, resp);
    }

    private void handleSave(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        HttpSession session = req.getSession();
        String type = req.getParameter("type");
        String day = req.getParameter("day");
        String description = req.getParameter("description");
        String amountStr = req.getParameter("amount");
        String categoryIdStr = req.getParameter("categoryId");
        String itemId = req.getParameter("itemId");

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
        LocalDateTime dateTime = LocalDateTime.parse(day, formatter);

        String url = "INCOME".equals(type) ? "incomeMain" : "expenseMain";

        Item item = new Item(categoryIdStr, Double.valueOf(amountStr), description, dateTime);
        item.setUserId(CurrentUser.getInstance().getUserId());

        boolean isSuccess;
        if (itemId != null && !itemId.isEmpty()) {
            item.setItemId(itemId);
            isSuccess = itemDao.updateItem(item);
            session.removeAttribute("tempItemId");
        } else {
            isSuccess = itemDao.createItem(item);
        }

        if (isSuccess) {
            session.setAttribute("successMessage", (itemId != null ? "Cập nhật" : "Thêm") + " thành công!");
            session.removeAttribute("tempDescription");
            session.removeAttribute("tempAmount");
            session.removeAttribute("tempCategoryId");
            session.removeAttribute("tempDay");
            resp.sendRedirect(req.getContextPath() + "/Main?action=" + url);
        } else {
            session.setAttribute("errorMessage", "Lỗi, kiểm tra lại thông tin!");
            req.getRequestDispatcher("/Main?action=" + url).forward(req, resp);
        }
    }

    public String getUrl(String type, String func) {
        if (func.equals("edit") || func.equals("del") || func.equals("add")) {
            if (type.equals("INCOME")) return "incomeEdit";
            else if (type.equals("EXPENSE")) return "expenseEdit";
        } else if (func.equals("main")) {
            if (type.equals("INCOME")) return "incomeMain";
            else if (type.equals("EXPENSE")) return "expenseMain";
        }
        return null;
    }
}