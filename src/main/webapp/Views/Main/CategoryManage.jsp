<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, Model.BO.*" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chỉnh sửa danh mục</title>
    <style>
        body {
            background-color: #111;
            color: white;
            font-family: sans-serif;
            padding: 20px;
        }

        /* --- HEADER --- */
        .header {
            display: flex;
            justify-content: center; /* canh giữa nội dung chính */
            align-items: center;
            position: relative; /* để đặt nút back bên trái */
            margin-bottom: 20px;
        }

        /* nút quay lại */
        .back-btn {
            position: absolute;
            left: 0;
            background-color: #222;
            color: white;
            border: none;
            border-radius: 10px;
            padding: 8px 14px;
            cursor: pointer;
            transition: background 0.3s;
        }
        .back-btn:hover {
            background-color: #444;
        }

        /* 2 nút tab */
        .tab-btn {
            background-color: #222;
            border: none;
            color: #aaa;
            padding: 8px 16px;
            border-radius: 10px;
            margin: 0 5px;
            cursor: pointer;
            transition: background 0.3s;
        }
        .tab-btn.active {
            background-color: #ffcc00;
            color: #000;
            font-weight: bold;
        }

        h3 {
            text-align: center;
            margin-top: 10px;
        }

        .category-box {
            background-color: #1b1b1b;
            padding: 10px;
            border-radius: 12px;
            margin: 10px 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .menu {
            cursor: pointer;
            color: #aaa;
            font-size: 28px;
            line-height: 1;
            padding: 5px;
            position: relative;
        }
        .menu-options {
            display: none;
            position: absolute;
            background-color: #333;
            border-radius: 10px;
            right: 0;
            top: 20px;
            padding: 5px 0;
            z-index: 10;
        }
        .menu-options button {
            display: block;
            width: 100%;
            background: none;
            border: none;
            color: white;
            text-align: left;
            padding: 10px 15px;
            cursor: pointer;
        }
        .menu-options button:hover {
            background-color: #444;
        }

        .add-category-btn {
            display: block;
            background-color: #222;
            border: 1px solid #555;
            color: white;
            padding: 12px;
            border-radius: 10px;
            text-align: center;
            text-decoration: none;
            margin-top: 20px;
        }
    </style>
</head>
<body>

<%

    HttpSession ss= request.getSession();
    String type = (String) request.getAttribute("type");
    if (type == null) type = "EXPENSE"; // mặc định là chi tiêu

%>

<div class="header">
    <!-- Nút Back -->
    <form action="${pageContext.request.contextPath}/Main?action=returnFromCategoryManager" method="post">
        <button type="submit" class="tab-btn">⬅ Quay lại</button>

    </form>


    <!-- Hai nút tab ở giữa -->
    <div>
        <form action="${pageContext.request.contextPath}/Main" method="post" style="display:inline;">
            <input type="hidden" name="action" value="expenseEdit">
            <button type="submit" class="tab-btn <%= "EXPENSE".equals(type) ? "active" : "" %>">Chi tiêu</button>
        </form>
        <form action="${pageContext.request.contextPath}/Main" method="post" style="display:inline;">
            <input type="hidden" name="action" value="incomeEdit">
            <button type="submit" class="tab-btn <%= "INCOME".equals(type) ? "active" : "" %>">Thu nhập</button>
        </form>
    </div>
</div>

<%--<h3>Chỉnh sửa danh mục</h3>--%>

<a href="${pageContext.request.contextPath}/Main?action=formAddCategory&type=<%=type%>"
   class="add-category-btn">+ Thêm danh mục</a>

<!-- Danh sách danh mục -->
<div id="category-list">
    <%
        List<Category> list = (List<Category>) request.getAttribute("list");
        if (list != null && !list.isEmpty()) {
            for (Category c : list) {
    %>
    <div class="category-box">
        <div class="category-left">
            <span><%= c.getName() %></span>
        </div>
        <div class="menu" onclick="toggleMenu(this)">⋮
            <div class="menu-options">
                <form action="${pageContext.request.contextPath}/Main?action=formEditCategory" method="post">
                    <input type="hidden" name="id" value="<%= c.getCategoryId() %>">
                    <input type="hidden" name="name" value="<%= c.getName() %>">
                    <input type="hidden" name="type" value="<%= type %>">
                     <input type="hidden" name="limit" value="<%= c.getLimitAmount() %>">
                    <button type="submit">Chỉnh sửa</button>
                </form>
                <form action="${pageContext.request.contextPath}/Main?action=delCategory" method="post">
                    <input type="hidden" name="id" value="<%= c.getCategoryId() %>">
                    <input type="hidden" name="type" value="<%= type %>">
                    <button type="submit">Xóa</button>
                </form>
            </div>
        </div>
    </div>
    <%
        }
    } else {
    %>
    <p>Không có danh mục nào.</p>
    <%
        }
    %>
</div>

<script>
    function toggleMenu(el) {
        const menu = el.querySelector('.menu-options');
        const visible = menu.style.display === 'block';
        document.querySelectorAll('.menu-options').forEach(m => m.style.display = 'none');
        menu.style.display = visible ? 'none' : 'block';
    }
    window.onclick = function(e) {
        if (!e.target.closest('.menu')) {
            document.querySelectorAll('.menu-options').forEach(m => m.style.display = 'none');
        }
    }
</script>
</body>
</html>
