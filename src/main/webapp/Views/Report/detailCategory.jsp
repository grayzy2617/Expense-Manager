<%@ page import="Model.BO.Item" %>
<%@ page import="java.util.List" %>
<%@ page import="Model.BO.Category" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<Item> items = (List<Item>) request.getAttribute("items");
    Category category = (Category) request.getAttribute("category");
    List<Map<String, Object>> chartData = (List<Map<String, Object>>) request.getAttribute("chartData");
    Double maxChartValue = (Double) request.getAttribute("maxChartValue");
    if (maxChartValue == null || maxChartValue == 0) maxChartValue = 1.0; // Avoid div by zero

    String type = (String) request.getAttribute("type");
    String range = (String) request.getAttribute("range");
    Integer year = (Integer) request.getAttribute("year");
    Integer month = (Integer) request.getAttribute("month");

    // Tính tổng tiền hiển thị trên header
    double totalCurrent = 0;
    if(items != null) {
        totalCurrent = items.stream().mapToDouble(Item::getAmount).sum();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết danh mục</title>
    <style>
        body {
            background-color: #121212; /* Màu nền tối giống hình */
            color: white;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            margin: 0;
            padding: 0;
        }

        /* Header */
        .header {
            display: flex;
            align-items: center;
            padding: 15px;
            background-color: #000;
            position: sticky;
            top: 0;
            z-index: 100;
        }
        .back-btn {
            background: none;
            border: none;
            color: white;
            font-size: 24px;
            cursor: pointer;
            padding: 0 10px;
        }
        .header-title {
            flex-grow: 1;
            text-align: center;
            font-size: 18px;
            font-weight: bold;
        }

        /* Chart Section */
        .chart-container {
            padding: 20px 10px;
            background-color: #1e1e1e;
            margin-bottom: 10px;
            position: relative;
            height: 250px;
            display: flex;
            align-items: flex-end;
            justify-content: space-around;
            border-bottom: 1px solid #333;
        }

        .chart-bar-wrapper {
            display: flex;
            flex-direction: column;
            align-items: center;
            width: 15%;
            position: relative;
        }

        .chart-bar {
            width: 100%;
            background-color: #ff9f43; /* Màu cam giống hình */
            border-radius: 4px 4px 0 0;
            transition: height 0.5s ease;
            min-height: 2px; /* Luôn hiện vạch nhỏ dù giá trị = 0 */
        }

        /* Cột cuối cùng (tháng hiện tại) đậm hơn hoặc sáng hơn */
        .chart-bar-wrapper:last-child .chart-bar {
            background-color: #ff8000;
        }

        .chart-label {
            margin-top: 10px;
            font-size: 12px;
            color: #aaa;
        }

        .chart-value {
            font-size: 10px;
            color: #ff9f43;
            margin-bottom: 5px;
            font-weight: bold;
        }

        /* List lines */
        .grid-line {
            position: absolute;
            left: 0;
            right: 0;
            border-top: 1px solid #333;
            z-index: 0;
        }

        /* Transaction List */
        .list-container {
            padding-bottom: 50px;
        }

        .day-header {
            background-color: #2c2c2c;
            color: #ccc;
            padding: 8px 15px;
            font-size: 13px;
            display: flex;
            justify-content: space-between;
        }

        .item-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px;
            background-color: #000;
            border-bottom: 1px solid #222;
        }

        .item-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: #333; /* Placeholder cho icon category */
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 15px;
            color: #ff9f43;
            font-size: 20px;
        }

        .item-info {
            flex-grow: 1;
        }
        .item-name {
            font-weight: bold;
            font-size: 16px;
        }
        .item-desc {
            font-size: 12px;
            color: #888;
            margin-top: 4px;
        }

        .item-amount {
            font-weight: bold;
            font-size: 16px;
            color: white;
            margin-right: 15px;
        }

        .item-menu-btn {
            background: none;
            border: none;
            color: #666;
            font-size: 20px;
            cursor: pointer;
            padding: 5px;
        }

        /* Popup Menu (3 dots) */
        .popup-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.5);
            z-index: 200;
        }
        .popup-menu {
            position: absolute;
            background: #333;
            border-radius: 8px;
            width: 150px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.5);
            overflow: hidden;
            /* Tọa độ sẽ được set bằng JS */
        }
        .popup-item {
            display: block;
            width: 100%;
            padding: 12px;
            text-align: left;
            background: none;
            border: none;
            color: white;
            font-size: 14px;
            cursor: pointer;
        }
        .popup-item:hover {
            background-color: #444;
        }
        .popup-item.delete {
            color: #ff4d4d;
        }

    </style>
</head>
<body>

<!-- 1. Header -->
<div class="header">
    <form action="<%= request.getContextPath() %>/Report" method="get">
        <!-- Submit về Report để load lại đúng trạng thái session -->
        <button type="submit" class="back-btn">❮</button>
    </form>

    <div class="header-title">
        <%= category.getName() %> (T<%= month %>) <br>
        <span style="font-size: 14px; font-weight: normal; color: #ccc;">
                <%= String.format("%,.0f", totalCurrent) %>đ
            </span>
    </div>
    <div style="width: 44px;"></div> <!-- Spacer để cân giữa title -->
</div>

<!-- 2. Chart Section (Chỉ hiện nếu có data và mode MONTH) -->
<% if (chartData != null && !chartData.isEmpty()) { %>
<div class="chart-container">
    <!-- Đường kẻ mờ trang trí (Grid lines) -->
    <div class="grid-line" style="bottom: 25%"></div>
    <div class="grid-line" style="bottom: 50%"></div>
    <div class="grid-line" style="bottom: 75%"></div>

    <% for (Map<String, Object> col : chartData) {
        double val = (Double) col.get("amount");
        String label = (String) col.get("label");
        // Tính % chiều cao so với max, tối đa 80% chiều cao container để chừa chỗ cho label
        double percent = (val / maxChartValue) * 80;
    %>
    <div class="chart-bar-wrapper">
        <% if (val > 0) { %>
        <div class="chart-value"><%= String.format("%,.0f", val) %></div>
        <% } %>
        <div class="chart-bar" style="height: <%= percent %>%;"></div>
        <div class="chart-label"><%= label %></div>
    </div>
    <% } %>
</div>
<% } %>

<!-- 3. List Items -->
<div class="list-container">
    <%
        if (items != null && !items.isEmpty()) {
            java.time.format.DateTimeFormatter ddMM = java.time.format.DateTimeFormatter.ofPattern("dd/MM");
            java.time.LocalDate currentDay = null;

            for (Item it : items) {
                java.time.LocalDate itemDay = it.getCreatedAt().toLocalDate();

                // Group Header (Ngày)
                if (currentDay == null || !currentDay.equals(itemDay)) {
                    currentDay = itemDay;
                    // Tính tổng ngày
                    double sumDay = items.stream()
                            .filter(x -> x.getCreatedAt().toLocalDate().equals(itemDay))
                            .mapToDouble(Item::getAmount).sum();
    %>
    <div class="day-header">
        <span><%= itemDay.format(ddMM) %></span>
        <span><%= String.format("%,.0f", sumDay) %>đ</span>
    </div>
    <%
        }
    %>
    <!-- Item Row -->
    <div class="item-row">
        <!-- Icon giả lập -->
        <div class="item-icon">
            <%-- Nếu có ảnh thì dùng img, ko thì dùng ký tự đầu --%>
            <%= category.getName().substring(0,1).toUpperCase() %>
        </div>

        <div class="item-info">
            <div class="item-name"><%= category.getName() %></div>
            <div class="item-desc">
                <%= (it.getDescribe() != null && !it.getDescribe().isEmpty()) ? it.getDescribe() : "Không có ghi chú" %>
            </div>
        </div>

        <div class="item-amount">
            <%= (type.equals("EXPENSE") ? "-" : "+") + String.format("%,.0f", it.getAmount()) %>đ
        </div>
        <!-- Nút 3 chấm -->
        <button class="item-menu-btn" onclick="openMenu(event, '<%= it.getItemId() %>')">⋮</button>
    </div>
    <%
        }
    } else {
    %>
    <div style="text-align: center; padding: 30px; color: #666;">Chưa có giao dịch nào</div>
    <% } %>
</div>

<!-- 4. Popup Menu (Ẩn) -->
<div id="popupOverlay" class="popup-overlay" onclick="closeMenu()">
    <div id="popupMenu" class="popup-menu" onclick="event.stopPropagation()">
        <!-- Forms ẩn để submit action -->
        <form id="formEdit" action="<%= request.getContextPath() %>/Report" method="post">
            <input type="hidden" name="action" value="editItem">
            <input type="hidden" name="idCategory" value="<%= category.getCategoryId() %>"> <!-- Để load lại trang -->
            <input type="hidden" name="itemId" id="editItemId">
            <button type="button" class="popup-item" onclick="submitEdit()">✎ Chỉnh sửa</button>
        </form>

        <form id="formDelete" action="<%= request.getContextPath() %>/Report" method="post">
            <input type="hidden" name="action" value="deleteItem">
            <input type="hidden" name="idCategory" value="<%= category.getCategoryId() %>"> <!-- Để load lại trang -->
            <input type="hidden" name="itemId" id="delItemId">
            <button type="button" class="popup-item delete" onclick="submitDelete()">🗑 Xóa</button>
        </form>
    </div>
</div>

<script>
    let currentItemId = null;

    function openMenu(e, itemId) {
        e.stopPropagation();
        currentItemId = itemId;

        const overlay = document.getElementById('popupOverlay');
        const menu = document.getElementById('popupMenu');

        // Set vị trí menu ngay tại chỗ click chuột
        // Điều chỉnh một chút để nó không bị tràn màn hình
        let x = e.clientX - 120; // Dịch sang trái
        let y = e.clientY + 10;

        menu.style.left = x + 'px';
        menu.style.top = y + 'px';

        overlay.style.display = 'block';
    }

    function closeMenu() {
        document.getElementById('popupOverlay').style.display = 'none';
    }

    function submitDelete() {
        if(confirm("Bạn có chắc muốn xóa giao dịch này?")) {
            document.getElementById('delItemId').value = currentItemId;
            document.getElementById('formDelete').submit();
        }
        closeMenu();
    }

    function submitEdit() {
        document.getElementById('editItemId').value = currentItemId;
        // Hỏi user hoặc redirect luôn

            document.getElementById('formEdit').submit();

        closeMenu();
    }
</script>

</body>
</html>