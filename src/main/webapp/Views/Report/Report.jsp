<%@ page import="Model.BO.Category" %>
<%@ page import="java.util.List" %>
<%@ page import="Model.BO.MonthRange" %>
<%@ page import="Model.BO.Item" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.Locale" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Báo cáo</title>
    <style>
        body { background-color: black; color: white; font-family: Arial, sans-serif; margin: 0; padding: 0; }

        /* General Styles */
        tr.clickable:hover { background-color: #222; cursor: pointer; transition: background-color 0.2s; }
        .hidden { display: none; }
        button { cursor: pointer; border-radius: 4px; }
        .limit-subtext { color: #666; font-size: 13px; }

        /* Styles cho chế độ xem Hàng Ngày (Item List) */
        .day-header {
            background-color: #333; /* Màu nền cho line chia ngày */
            color: #ccc;
            padding: 8px 15px;
            font-size: 13px;
            font-weight: bold;
            display: flex;
            justify-content: space-between;
            margin-top: 0; /* Liền mạch */
            border-bottom: 1px solid #444;
        }

        .item-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 15px;
            border-bottom: 1px solid #222;
            background-color: #000;
        }
        .item-icon {
            width: 36px; height: 36px;
            border-radius: 50%;
            background-color: #222;
            border: 1px solid #444;
            display: flex; align-items: center; justify-content: center;
            margin-right: 12px;
            color: #ffcc00; font-size: 18px; font-weight: bold;
        }
        .item-info { flex-grow: 1; }
        .item-name { font-weight: bold; font-size: 15px; }
        .item-desc { font-size: 12px; color: #888; margin-top: 2px; }
        .item-amount { font-weight: bold; font-size: 15px; color: white; margin-right: 10px; }

        .item-menu-btn {
            background: none; border: none;
            color: #666; font-size: 20px;
            cursor: pointer; padding: 0 5px;
        }

        /* Popup Menu (Dùng chung cho Edit/Delete) */
        .popup-overlay {
            display: none;
            position: fixed; top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.5); z-index: 200;
        }
        .popup-menu {
            position: absolute;
            background: #333;
            border-radius: 8px;
            width: 150px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.5);
            overflow: hidden;
        }
        .popup-item {
            display: block; width: 100%;
            padding: 12px;
            text-align: left;
            background: none; border: none;
            color: white; font-size: 14px; cursor: pointer;
        }
        .popup-item:hover { background-color: #444; }
        .popup-item.delete { color: #ff4d4d; }
    </style>
</head>
<body>
<%
    // Lấy dữ liệu từ Servlet
    String type = (String) request.getAttribute("type");
    String mode = (String) request.getAttribute("mode");
    Integer month = (Integer) request.getAttribute("month");
    Integer year = (Integer) request.getAttribute("year");
    MonthRange range = (MonthRange) request.getAttribute("monthRange");

    // Xử lý null
    if (type == null) type = "EXPENSE";
    if (mode == null) mode = "MONTH";
    if (range == null) range = new MonthRange(1, java.time.LocalDateTime.now(), java.time.LocalDateTime.now());
%>

<!-- 1. HEADER: CHỌN CHẾ ĐỘ (NGÀY / THÁNG / NĂM) -->
<div style="text-align:center; padding:12px;">
    <form method="post" action="<%= request.getContextPath() %>/Report" style="display:inline;">
        <input type="hidden" name="action" value="view">
        <input type="hidden" name="type" value="<%= type %>">

        <button name="mode" value="DAY" style="background-color: <%= "DAY".equals(mode) ? "gold":"#333" %>; color: <%= "DAY".equals(mode) ? "black":"white" %>; padding:8px 10px; border:none; margin-right:5px;">Hàng Ngày</button>
        <button name="mode" value="MONTH" style="background-color: <%= "MONTH".equals(mode) ? "gold":"#333" %>; color: <%= "MONTH".equals(mode) ? "black":"white" %>; padding:8px 10px; border:none; margin-right:5px;">Hàng Tháng</button>
        <button name="mode" value="YEAR" style="background-color: <%= "YEAR".equals(mode) ? "gold":"#333" %>; color: <%= "YEAR".equals(mode) ? "black":"white" %>; padding:8px 10px; border:none;">Hàng Năm</button>
    </form>
</div>

<!-- 2. DATE CHOOSER (Tùy chọn thời gian theo chế độ) -->
<div style="text-align:center; margin-top:10px;">
    <label style="color: #aaa;">Thời gian:</label>

    <!-- Chọn Tháng (Dùng cho cả MONTH và DAY) -->
    <!-- Logic class: Ẩn khi là YEAR, còn lại (DAY, MONTH) đều hiện -->
    <input id="monthInput" type="month" class="<%= "YEAR".equals(mode) ? "hidden" : "" %>"
           value="<%= String.format("%04d-%02d", year, month) %>"
           style="padding: 5px; background: #333; color: white; border: 1px solid #555; border-radius: 4px;">

    <!-- Chọn Năm (Chỉ hiện khi mode YEAR) -->
    <select id="yearSelect" class="<%= "YEAR".equals(mode) ? "" : "hidden" %>"
            style="padding: 5px; background: #333; color: white; border: 1px solid #555; border-radius: 4px;">
        <% int currentY = java.time.LocalDateTime.now().getYear();
            for (int y = currentY - 5; y <= currentY + 5; y++) { %>
        <option value="<%=y%>" <%= y==year ? "selected":"" %> ><%=y%></option>
        <% } %>
    </select>

    <!-- Range Text (Hiện cho tất cả trừ khi ở chế độ Năm mà chưa chọn) -->
    <% if (!"YEAR".equals(mode) || ("YEAR".equals(mode) && year != null)) { %>
    <div style="margin-top:6px; font-size: 0.9em; color: #888; font-style: italic;">
        (<%= range.getStart().getDayOfMonth() %>/<%= range.getStart().getMonthValue() %> - <%= range.getEnd().getDayOfMonth() %>/<%= range.getEnd().getMonthValue() %>)
    </div>
    <% } %>
</div>

<!-- 3. SUMMARY INFO (Tổng Thu/Chi trong khoảng thời gian chọn) -->
<div style="text-align:center; margin-top:18px; font-size: 15px;">
    <div style="margin-bottom: 5px;">Chi tiêu: <span style="color:#ff4d4d; font-weight: bold;">-<%= String.format("%,.0f", request.getAttribute("totalExpense")) %>đ</span></div>
    <div style="margin-bottom: 5px;">Thu nhập: <span style="color:#00BFFF; font-weight: bold;">+<%= String.format("%,.0f", request.getAttribute("totalIncome")) %>đ</span></div>
    <div>Số dư: <span style="color: <%= (Double)request.getAttribute("totalBalance") >= 0 ? "#4cd137" : "#ff4d4d" %>; font-weight: bold;">
        <%= (Double)request.getAttribute("totalBalance") >= 0 ? "+" : "" %><%= String.format("%,.0f", request.getAttribute("totalBalance")) %>đ
    </span></div>
</div>

<!-- 4. TYPE SWITCHER (Lọc Thu/Chi) -->
<div style="text-align:center; margin-top:15px;">
    <form method="post" action="<%= request.getContextPath() %>/Report" style="display:inline;">
        <input type="hidden" name="action" value="view">
        <input type="hidden" name="mode" value="<%=mode%>">
        <input type="hidden" name="type" value="EXPENSE">
        <input type="hidden" name="selectedMY" value="<%= String.format("%04d-%02d", year, month) %>">
        <input type="hidden" name="selectedYear" value="<%= year %>">
        <button style="background-color: <%= "EXPENSE".equals(type) ? "gold":"#333" %>; color: <%= "EXPENSE".equals(type) ? "black":"white" %>; padding:8px 20px; border:none; margin-right:6px; font-weight: bold;">Chi tiêu</button>
    </form>

    <form method="post" action="<%= request.getContextPath() %>/Report" style="display:inline;">
        <input type="hidden" name="action" value="view">
        <input type="hidden" name="mode" value="<%=mode%>">
        <input type="hidden" name="type" value="INCOME">
        <input type="hidden" name="selectedMY" value="<%= String.format("%04d-%02d", year, month) %>">
        <input type="hidden" name="selectedYear" value="<%= year %>">
        <button style="background-color: <%= "INCOME".equals(type) ? "gold":"#333" %>; color: <%= "INCOME".equals(type) ? "black":"white" %>; padding:8px 20px; border:none; font-weight: bold;">Thu nhập</button>
    </form>
</div>

<!-- 5. MAIN CONTENT -->
<div style="margin:20px; background-color:#111; padding:0 12px; border-radius:12px; padding-bottom: 60px;">

    <!-- CASE 1: MODE HÀNG NGÀY (HIỂN THỊ LIST ITEM CHI TIẾT GOM NHÓM THEO NGÀY) -->
    <% if ("DAY".equals(mode)) {
        List<Item> dailyItems = (List<Item>) request.getAttribute("dailyItems");

        if (dailyItems != null && !dailyItems.isEmpty()) {
            LocalDate currentDay = null;
            DateTimeFormatter dayFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy"); // Format ngày

            for (Item it : dailyItems) {
                // --- LOGIC GOM NHÓM NGÀY ---
                LocalDate itemDay = it.getCreatedAt().toLocalDate();

                // Nếu ngày của item này khác ngày đang xét -> In Header ngày mới
                if (!itemDay.equals(currentDay)) {
                    currentDay = itemDay;

                    // Tính tổng tiền cho riêng ngày này để hiển thị trên Header
                    double dailySum = 0;
                    for(Item sub : dailyItems) {
                        if(sub.getCreatedAt().toLocalDate().equals(currentDay)) {
                            dailySum += sub.getAmount();
                        }
                    }
    %>
    <!-- HEADER CHIA NGÀY -->
    <div class="day-header">
        <span><%= itemDay.format(dayFmt) %></span>
        <span><%= String.format("%,.0f", dailySum) %> đ</span>
    </div>
    <%         } // Kết thúc if check ngày mới %>

    <!-- ITEM ROW (HIỂN THỊ ITEM) -->
    <div class="item-row">
        <!-- Icon lấy chữ cái đầu của Category -->
        <div class="item-icon"><%= it.getCategoryName() != null ? it.getCategoryName().substring(0,1).toUpperCase() : "?" %></div>

        <div class="item-info">
            <div class="item-name"><%= it.getCategoryName() %></div>
            <div class="item-desc"><%= it.getDescribe() != null ? it.getDescribe() : "" %></div>
        </div>

        <div class="item-amount">
            <%= String.format("%,.0f", it.getAmount()) %> đ
        </div>

        <!-- Nút 3 chấm mở menu Sửa/Xóa -->
        <button class="item-menu-btn" onclick="openMenu(event, '<%= it.getItemId() %>')">⋮</button>
    </div>

    <%     } // End for items
    } else { %>
    <div style="text-align:center; padding:30px; color:#666;">Không có giao dịch nào trong khoảng thời gian này</div>
    <% }
    } else { %>

    <!-- CASE 2: MODE THÁNG/NĂM (HIỂN THỊ LIST CATEGORY TỔNG HỢP - GIỮ NGUYÊN) -->
    <table style="width:100%; color:white; border-collapse: collapse;">
        <%
            List<Category> list = (List<Category>) request.getAttribute("categoryList");
            if (list != null && !list.isEmpty()) {
                for (Category c : list) {
                    double spent = c.getTotalAmount();
                    Double limit = c.getLimitAmount();
                    String amountStyle = "color: white; font-weight: bold;";
                    if (limit != null && limit > 0 && spent > limit && "EXPENSE".equals(type)) {
                        amountStyle = "color: #ff4d4d; font-weight: bold;";
                    }
        %>
        <tr class="clickable" onclick="submitDetail('<%=c.getCategoryId()%>')" style="border-bottom: 1px solid #222;">
            <td style="padding: 15px 5px;"><div style="font-size: 16px;"><%=c.getName()%></div></td>
            <td style="text-align:right; padding: 15px 5px;">
                <% if (limit != null && limit > 0 && "EXPENSE".equals(type)) { %>
                <div style="<%= amountStyle %>"><%= String.format("%,.0f", spent) %> đ <span class="limit-subtext"> / <%= String.format("%,.0f", limit) %> đ</span></div>
                <% } else { %>
                <div style="<%= amountStyle %>"><%= String.format("%,.0f", spent) %> đ</div>
                <% } %>
            </td>
        </tr>
        <% } } else { %>
        <tr><td colspan="2" style="text-align:center; padding: 20px; color: #666;">Chưa có dữ liệu</td></tr>
        <% } %>
    </table>
    <% } %>

    <!-- Form ẩn để chuyển trang Detail -->
    <form id="detailForm" method="post" action="<%= request.getContextPath() %>/Report">
        <input type="hidden" name="action" value="detailCategory">
        <input type="hidden" name="idCategory" id="detailCategoryId">
    </form>
</div>

<!-- POPUP MENU (Cho chế độ Hàng Ngày) -->
<div id="popupOverlay" class="popup-overlay" onclick="closeMenu()">
    <div id="popupMenu" class="popup-menu" onclick="event.stopPropagation()">
        <!-- Form Sửa -->
        <form id="formEdit" action="<%= request.getContextPath() %>/Report" method="post">
            <input type="hidden" name="action" value="editItem">
            <input type="hidden" name="itemId" id="editItemId">
            <button type="button" class="popup-item" onclick="submitEdit()">✎ Chỉnh sửa</button>
        </form>
        <!-- Form Xóa -->
        <form id="formDelete" action="<%= request.getContextPath() %>/Report" method="post">
            <input type="hidden" name="action" value="deleteItem">
            <input type="hidden" name="itemId" id="delItemId">
            <button type="button" class="popup-item delete" onclick="submitDelete()">🗑 Xóa</button>
        </form>
    </div>
</div>

<jsp:include page="../MenuFooter.jsp" />

<script>
    // --- JS CHO VIEW REPORT CHUNG ---
    function submitDetail(catId) {
        document.getElementById('detailCategoryId').value = catId;
        document.getElementById('detailForm').submit();
    }

    function submitViewForm(name, val) {
        const form = document.createElement('form');
        form.method = 'post';
        form.action = '<%= request.getContextPath() %>/Report';

        const iAction = document.createElement('input'); iAction.type='hidden'; iAction.name='action'; iAction.value='view'; form.appendChild(iAction);
        const iMode = document.createElement('input'); iMode.type='hidden'; iMode.name='mode'; iMode.value = '<%=mode%>'; form.appendChild(iMode);
        const iType = document.createElement('input'); iType.type='hidden'; iType.name='type'; iType.value = '<%=type%>'; form.appendChild(iType);

        const iVal = document.createElement('input'); iVal.type='hidden'; iVal.name=name; iVal.value=val; form.appendChild(iVal);

        document.body.appendChild(form);
        form.submit();
    }

    // Event Listeners cho Month/Year input
    const mInput = document.getElementById('monthInput');
    if(mInput) mInput.addEventListener('change', function(){ submitViewForm('selectedMY', this.value); });

    const ySelect = document.getElementById('yearSelect');
    if(ySelect) ySelect.addEventListener('change', function(){ submitViewForm('selectedYear', this.value); });

    // --- JS CHO POPUP MENU (DAY MODE) ---
    let currentItemId = null;
    function openMenu(e, itemId) {
        e.stopPropagation();
        currentItemId = itemId;
        const overlay = document.getElementById('popupOverlay');
        const menu = document.getElementById('popupMenu');

        // Tính toán vị trí menu (tránh bị tràn màn hình)
        let x = e.clientX - 140;
        let y = e.clientY + 10;

        menu.style.left = x + 'px';
        menu.style.top = y + 'px';
        overlay.style.display = 'block';
    }

    function closeMenu() { document.getElementById('popupOverlay').style.display = 'none'; }

    function submitDelete() {
        if(confirm("Bạn có chắc muốn xóa giao dịch này?")) {
            document.getElementById('delItemId').value = currentItemId;
            document.getElementById('formDelete').submit();
        }
        closeMenu();
    }

    function submitEdit() {
        document.getElementById('editItemId').value = currentItemId;
        document.getElementById('formEdit').submit();
        closeMenu();
    }
</script>
</body>
</html>