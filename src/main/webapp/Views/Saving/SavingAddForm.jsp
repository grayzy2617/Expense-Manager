<%@ page import="Model.BO.Saving" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Thêm tích lũy</title>
    <style>
        body { background-color: #111; color: white; font-family: sans-serif; padding: 20px; }

        /* Form Styles */
        label { display: block; margin-bottom: 8px; font-weight: bold; color: #ccc; }

        .input-group {
            position: relative;
            margin-bottom: 20px;
        }

        input[type=text], input[type=datetime-local] {
            width: 100%; padding: 12px; background: #222; border: 1px solid #444; color: white;
            border-radius: 8px; box-sizing: border-box; font-size: 16px;
        }

        /* Thêm padding phải cho input ngày kết thúc để không bị nút mũi tên che */
        input#endDate { padding-right: 40px; }

        input:focus { border-color: #ffcc00; outline: none; }

        /* Dropdown Button inside Input */
        .dropdown-btn {
            position: absolute;
            right: 5px;
            top: 22px; /* Điều chỉnh thủ công vì top 50% có thể lệch do label */
            background: none;
            border: none;
            color: #ffcc00;
            font-size: 18px;
            cursor: pointer;
            padding: 5px 10px;
            z-index: 10;
        }

        /* Dropdown Menu */
        .dropdown-content {
            display: none;
            position: absolute;
            right: 0;
            top: 100%; /* Hiện ngay dưới input */
            background-color: #333;
            min-width: 160px;
            box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.5);
            border-radius: 8px;
            z-index: 20;
            overflow: hidden;
            border: 1px solid #444;
        }

        .dropdown-content div {
            color: white;
            padding: 12px 16px;
            text-decoration: none;
            display: block;
            cursor: pointer;
            font-size: 14px;
        }

        .dropdown-content div:hover { background-color: #444; }
        .dropdown-content div.calendar-opt { border-top: 1px solid #555; color: #ffcc00; }

        .show { display: block; }

        /* Toggle Button */
        .toggle-container {
            display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px;
            background: #222; padding: 15px; border-radius: 8px; border: 1px solid #333;
        }

        /* Submit Button */
        .submit-btn {
            width: 100%; padding: 15px; background: #ffcc00; color: black; border: none;
            border-radius: 8px; font-weight: bold; font-size: 16px; cursor: pointer;
            transition: background 0.3s;
        }
        .submit-btn:hover { background-color: #e6b800; }

        .back-btn { color: #888; text-decoration: none; display: block; margin-top: 20px; text-align: center; }
        .back-btn:hover { color: white; }

    </style>
</head>
<body>

<%
    Saving s = (Saving) request.getAttribute("saving");
    boolean isEdit = (s != null);
    String action = isEdit ? "editSaving" : "add";

    java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    // Format số tiền để hiển thị
    String targetDisplay = "";
    String startVal = "";
    String endVal = "";

    if(isEdit) {
        long val = Math.round(s.getLimitAmount());
        targetDisplay = String.format("%,d", val);
        if (s.getStartDate() != null) startVal = s.getStartDate().format(fmt);
        if (s.getEndDate() != null) endVal = s.getEndDate().format(fmt);
    } else {
        // MẶC ĐỊNH LẤY NGÀY GIỜ HIỆN TẠI NẾU LÀ THÊM MỚI
        startVal = java.time.LocalDateTime.now().format(fmt);
    }
%>

<h2 style="text-align: center;"><%= isEdit ? "Chỉnh sửa mục tiêu" : "Mục tiêu tích lũy mới" %></h2>

<form action="SaveUpMoney" method="post" onsubmit="return removeCommasBeforeSubmit()">
    <input type="hidden" name="action" value="<%= action %>">
    <% if(isEdit) { %> <input type="hidden" name="id" value="<%= s.getCategoryId() %>"> <% } %>

    <label>Tên mục tiêu</label>
    <div class="input-group">
        <input type="text" name="name" value="<%= isEdit ? s.getName() : "" %>" placeholder="Ví dụ: Mua Laptop Gaming" required>
    </div>

    <label>Số tiền cần tích lũy (VNĐ)</label>
    <div class="input-group">
        <input type="text" id="targetInput" name="target"
               value="<%= targetDisplay %>"
               placeholder="0"
               oninput="formatCurrency(this)" required>
    </div>

    <label>Ngày bắt đầu</label>
    <div class="input-group">
        <input type="datetime-local" id="startDate" name="start" value="<%= startVal %>" required>
    </div>

    <label>Dự kiến hoàn thành</label>
    <div class="input-group">
        <input type="datetime-local" id="endDate" name="end" value="<%= endVal %>" required>

        <button type="button" class="dropdown-btn" onclick="toggleDropdown()">▼</button>

        <div id="durationDropdown" class="dropdown-content">
            <div onclick="selectDuration(1)">1 Tháng</div>
            <div onclick="selectDuration(3)">3 Tháng</div>
            <div onclick="selectDuration(6)">6 Tháng</div>
            <div onclick="selectDuration(12)">1 Năm</div>
            <div onclick="selectDuration(24)">2 Năm</div>
            <div onclick="selectDuration(60)">5 Năm</div>
            <div onclick="openCalendar()" class="calendar-opt">📅 Chọn lịch...</div>
        </div>
    </div>

    <div class="toggle-container">
        <span>Hiển thị trong báo cáo tổng?</span>
        <input type="checkbox" name="viewInReport" value="true" <%= (isEdit && s.isViewInReport()) ? "checked" : "" %> style="width: 20px; height: 20px; margin: 0;">
    </div>

    <button type="submit" class="submit-btn"><%= isEdit ? "CẬP NHẬT" : "TẠO MỤC TIÊU" %></button>
</form>

<a href="SaveUpMoney?action=view" class="back-btn">Quay lại danh sách</a>

<script>
    // --- 1. FORMAT TIỀN TỆ ---
    function formatCurrency(input) {
        let value = input.value.replace(/\D/g, "");
        if (value === "") {
            input.value = "";
            return;
        }
        input.value = new Intl.NumberFormat('en-US').format(value);
    }

    function removeCommasBeforeSubmit() {
        const input = document.getElementById('targetInput');
        // Remove commas before submitting to server
        input.value = input.value.replace(/,/g, "");
        return true;
    }

    // --- 2. XỬ LÝ DROPDOWN ---
    function toggleDropdown() {
        document.getElementById("durationDropdown").classList.toggle("show");
    }

    // Close dropdown if clicking outside
    window.onclick = function(event) {
        if (!event.target.matches('.dropdown-btn')) {
            var dropdowns = document.getElementsByClassName("dropdown-content");
            for (var i = 0; i < dropdowns.length; i++) {
                var openDropdown = dropdowns[i];
                if (openDropdown.classList.contains('show')) {
                    openDropdown.classList.remove('show');
                }
            }
        }
    }

    // --- 3. TÍNH TOÁN NGÀY (UPDATED) ---
    function formatDateTimeLocal(date) {
        const year = date.getFullYear();
        // Month is 0-indexed in JS
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const hours = String(date.getHours()).padStart(2, '0');
        const minutes = String(date.getMinutes()).padStart(2, '0');

        // SỬ DỤNG CỘNG CHUỖI ĐỂ TRÁNH CONFLICT VỚI JSP EL
        return year + "-" + month + "-" + day + "T" + hours + ":" + minutes;
    }

    function selectDuration(months) {
        let startVal = document.getElementById('startDate').value;
        let startDate;

        // Nếu chưa chọn ngày bắt đầu, mặc định lấy ngày hiện tại
        if (!startVal) {
            startDate = new Date();
            document.getElementById('startDate').value = formatDateTimeLocal(startDate);
        } else {
            startDate = new Date(startVal);
        }

        const endDate = new Date(startDate.getTime());

        // Cộng thêm số tháng
        endDate.setMonth(endDate.getMonth() + months);

        // Set thời gian thành 23:59 (Cuối ngày)
        endDate.setHours(23, 59, 0, 0);

        // Hiển thị ra input
        const formattedDate = formatDateTimeLocal(endDate);
        document.getElementById('endDate').value = formattedDate;

        // Đóng dropdown
        document.getElementById("durationDropdown").classList.remove("show");
    }

    function openCalendar() {
        const dateInput = document.getElementById('endDate');
        if(dateInput.showPicker) {
            dateInput.showPicker();
        } else {
            dateInput.focus();
        }
        document.getElementById("durationDropdown").classList.remove("show");
    }
</script>

</body>
</html>