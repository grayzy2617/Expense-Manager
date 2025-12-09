<%@ page import="Model.BO.Category" %>
<%@ page import="java.util.List" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nhập thu chi</title>
    <style>
        /* Giữ nguyên CSS cũ của bạn */
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #111;
            color: white;
            padding-bottom: 80px;
        }

        .tabs-container {
            display: flex;
            justify-content: center;
            gap: 15px;
            padding: 20px 0;
            background-color: #111;
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .tab-btn {
            padding: 10px 25px;
            border: none;
            border-radius: 20px;
            color: #888;
            background-color: #222;
            cursor: pointer;
            font-weight: bold;
            transition: all 0.3s;
        }

        .tab-btn.active {
            background-color: #ffcc00;
            color: black;
            box-shadow: 0 0 10px rgba(255, 204, 0, 0.4);
        }

        .form-container {
            padding: 0 20px;
            max-width: 600px;
            margin: 0 auto;
        }

        .input-group {
            background-color: #222;
            border-radius: 12px;
            padding: 15px;
            margin-bottom: 15px;
            display: flex;
            flex-direction: column;
        }

        .input-label {
            font-size: 13px;
            color: #888;
            margin-bottom: 5px;
            font-weight: bold;
        }

        .input-field {
            background: none;
            border: none;
            color: white;
            font-size: 18px;
            width: 100%;
            outline: none;
        }

        .input-field::placeholder { color: #555; }

        .amount-input {
            font-size: 32px;
            color: #ffcc00;
            font-weight: bold;
            text-align: center;
            width: 100%;
            background: none;
            border: none;
            outline: none;
            margin: 10px 0;
        }

        .category-section { margin-top: 20px; }
        .section-title {
            color: #888;
            font-size: 14px;
            margin-bottom: 10px;
            text-align: center;
        }

        .category-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px;
            max-height: 250px;
            overflow-y: auto;
            padding-bottom: 10px;
        }

        .category-item {
            background-color: #222;
            border-radius: 10px;
            padding: 15px 5px;
            cursor: pointer;
            text-align: center;
            border: 2px solid transparent;
            transition: all 0.2s;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 80px;
        }

        .category-item.active {
            background-color: rgba(255, 204, 0, 0.2);
            border-color: #ffcc00;
        }

        .cat-name { font-size: 13px; margin-top: 5px; color: #ddd; }
        .cat-icon { font-size: 24px; color: #ffcc00; }

        .manage-link {
            display: block;
            text-align: center;
            color: #ffcc00;
            text-decoration: none;
            font-size: 13px;
            margin-top: 15px;
            padding: 10px;
            cursor: pointer; /* Thêm con trỏ chuột */
        }

        .action-bar {
            margin-top: 20px;
            padding-bottom: 20px;
        }

        .btn-save {
            width: 100%;
            padding: 16px;
            background-color: #ffcc00;
            color: black;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            box-shadow: 0 4px 15px rgba(255, 204, 0, 0.3);
            transition: transform 0.1s;
        }
        .btn-save:active { transform: scale(0.98); }

        .btn-secondary {
            display: block;
            width: 100%;
            padding: 16px;
            margin-top: 15px;
            background-color: #333;
            color: #ccc;
            border: 1px solid #444;
            border-radius: 12px;
            font-size: 16px;
            font-weight: bold;
            text-align: center;
            text-decoration: none;
            cursor: pointer;
            box-sizing: border-box;
            transition: all 0.2s;
        }
        .btn-secondary:hover {
            background-color: #444;
            color: white;
            border-color: #666;
        }
        .btn-secondary:active { transform: scale(0.98); }

        .flash-msg {
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            background: rgba(0,0,0,0.8);
            padding: 10px 20px;
            border-radius: 20px;
            z-index: 9999;
            color: #00e676;
            font-weight: bold;
            border: 1px solid #333;
        }
    </style>

    <script>
        function setType(newType) {
            document.getElementById('typeField').value = newType;
        }
        function formatCurrency(input) {
            let value = input.value.replace(/\D/g, "");
            if (value === "") { input.value = ""; return; }
            input.value = new Intl.NumberFormat('en-US').format(value);
        }
        function cleanInputBeforeSubmit() {
            const amountInput = document.getElementById('amountInput');
            amountInput.value = amountInput.value.replace(/,/g, "");
            return true;
        }
        function selectCategory(element, categoryId) {
            document.querySelectorAll('.category-item').forEach(el => el.classList.remove('active'));
            element.classList.add('active');
            document.getElementById('selectedCategory').value = categoryId;
        }

        // --- HÀM MỚI: Xử lý chuyển sang trang Quản lý danh mục ---
        function goToCategoryManager() {
            // 1. Xóa dấu phẩy ở ô tiền để gửi đi không bị lỗi
            const amountInput = document.getElementById('amountInput');
            amountInput.value = amountInput.value.replace(/,/g, "");

            // 2. Lấy Form
            const form = document.getElementById('mainForm');//

            // 3. Đổi đích đến (Action) của Form thành 'saveTempSession'
            // Action này sẽ lưu dữ liệu vào session, sau đó Backend tự redirect sang trang quản lý
            form.action = "${pageContext.request.contextPath}/Main?action=saveTempSession";

            // 4. Submit form
            form.submit();
        }
        // --------------------------------------------------------

        setTimeout(() => {
            let flash = document.querySelectorAll('.flash-msg');
            if(flash) flash.forEach(el => el.style.display = 'none');
        }, 3000);
    </script>
</head>

<body>
<%
    HttpSession sessionn = request.getSession();

    if (request.getParameter("cancel") != null) {
        sessionn.removeAttribute("successMessage");
        sessionn.removeAttribute("errorMessage");
        sessionn.setAttribute("successMessage", null);
    }

    String success = (String) sessionn.getAttribute("successMessage");
    String error = (String) sessionn.getAttribute("errorMessage");
    String type = (String) request.getAttribute("type");
    if (type == null) type = "EXPENSE";

    if (success != null) { %><div class="flash-msg"><%= success %></div><% sessionn.removeAttribute("successMessage"); }
    if (error != null) { %><div class="flash-msg" style="color: #ff4d4d;"><%= error %></div><% sessionn.removeAttribute("errorMessage"); }
%>

<%
    String tempType = (String) sessionn.getAttribute("tempType");
    String tempDesc = (String) sessionn.getAttribute("tempDescription");
    String tempAmount = (String) sessionn.getAttribute("tempAmount");
    String tempCatId = (String) sessionn.getAttribute("tempCategoryId");
    String tempDay = (String) sessionn.getAttribute("tempDay");
    String tempItemId = (String) sessionn.getAttribute("tempItemId");


    String displayAmount = "";
    if (tempAmount != null && !tempAmount.isEmpty()) {
        try {
            long val = Long.parseLong(tempAmount.replace(".0", ""));
            displayAmount = String.format("%,d", val);
        } catch (Exception e) { displayAmount = tempAmount; }
    }

    java.time.LocalDateTime now = java.time.LocalDateTime.now();
    String formattedDateTime = now.format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"));
%>

<div class="tabs-container">
    <form action="${pageContext.request.contextPath}/Main?action=expenseMain" method="post" style="margin:0">
        <button type="submit" onclick="setType('EXPENSE')" class="tab-btn <%= "EXPENSE".equals(type) ? "active" : "" %>">Tiền chi</button>
    </form>
    <form action="${pageContext.request.contextPath}/Main?action=incomeMain" method="post" style="margin:0">
        <button type="submit" onclick="setType('INCOME')" class="tab-btn <%= "INCOME".equals(type) ? "active" : "" %>">Tiền thu</button>
    </form>
</div>

<div class="form-container">
    <form id="mainForm" action="${pageContext.request.contextPath}/Main?action=save" method="post" onsubmit="return cleanInputBeforeSubmit()">
        <input type="hidden" name="type" id="typeField" value="<%= type %>">
        <input type="hidden" name="itemId" value="<%= tempItemId != null ? tempItemId : "" %>">

        <input type="text" id="amountInput" name="amount" class="amount-input" value="<%= displayAmount %>" placeholder="0" oninput="formatCurrency(this)" required autofocus>
        <div style="text-align: center; color: #666; margin-bottom: 20px; font-size: 14px;">VNĐ</div>

        <div class="input-group">
            <div class="input-label">Ghi chú</div>
            <input type="text" name="description" class="input-field" value="<%= tempDesc != null ? tempDesc : "" %>" placeholder="Ví dụ: Ăn sáng, Cafe...">
        </div>

        <div class="input-group">
            <div class="input-label">Thời gian</div>
            <input type="datetime-local" name="day" class="input-field" value="<%= tempDay != null ? tempDay : formattedDateTime %>" style="color-scheme: dark;">
        </div>

        <div class="category-section">
            <div class="section-title">Danh mục</div>
            <%
                List<Category> list = (List<Category>) request.getAttribute("list");
                String targetId = "";
                if (tempCatId != null && !tempCatId.isEmpty()) { targetId = tempCatId; }
                else if (list != null && !list.isEmpty()) { targetId = list.get(0).getCategoryId(); }
            %>
            <input type="hidden" id="selectedCategory" name="categoryId" value="<%= targetId %>">

            <div class="category-grid">
                <% if (list != null && !list.isEmpty()) {
                    for (Category s : list) {
                        String activeClass = s.getCategoryId().equals(targetId) ? " active" : "";
                %>
                <div class="category-item<%= activeClass %>" data-id="<%= s.getCategoryId() %>" onclick="selectCategory(this, '<%= s.getCategoryId() %>')">
                    <div class="cat-icon"><%= s.getName().substring(0,1).toUpperCase() %></div>
                    <div class="cat-name"><%= s.getName() %></div>
                </div>
                <% } } else { %>
                <div style="grid-column: 1/-1; text-align: center; color: #666; padding: 20px;">Chưa có danh mục nào</div>
                <% } %>
            </div>

            <a onclick="goToCategoryManager()" class="manage-link">⚙ Quản lý danh mục</a>

        </div>

        <div class="action-bar">
            <button type="submit" class="btn-save">
                <%= tempItemId != null ? "CẬP NHẬT GIAO DỊCH" : "LƯU GIAO DỊCH" %>
            </button>

            <% if (tempItemId != null) { %>
            <a href="${pageContext.request.contextPath}/Main?action=<%= "INCOME".equals(type)?"incomeMain":"expenseMain" %>"
               class="btn-secondary">
                Hủy bỏ chỉnh sửa
            </a>
            <% } %>
        </div>
    </form>
</div>

<jsp:include page="../MenuFooter.jsp" />
</body>
</html>