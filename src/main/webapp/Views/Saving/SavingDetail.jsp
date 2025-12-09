<%@ page import="Model.BO.Saving" %>
<%@ page import="Model.BO.Item" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Chi tiết tích lũy</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { background-color: #111; color: white; font-family: sans-serif; padding: 0; margin: 0; }
        .header { padding: 20px; text-align: center; background: #222; border-bottom: 1px solid #333; }
        .big-amount { font-size: 32px; font-weight: bold; color: #ffcc00; margin: 10px 0; }
        .sub-text { color: #888; font-size: 14px; }

        .action-bar {
            display: flex; justify-content: space-around; padding: 20px; background: #000;
        }
        .action-btn {
            background: #333; color: white; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer;
            display: flex; flex-direction: column; align-items: center; width: 45%;
        }
        .action-btn span { font-size: 20px; margin-bottom: 5px; }

        .trans-list { padding: 15px; padding-bottom: 80px; }
        .trans-item {
            display: flex; justify-content: space-between; align-items: center; padding: 15px 0; border-bottom: 1px solid #222;
        }
        .trans-date { color: #666; font-size: 12px; }
        .trans-amount { font-weight: bold; font-size: 16px; margin-right: 10px;}
        .plus { color: #00e676; }
        .minus { color: #ff4d4d; }

        /* Nút 3 chấm */
        .item-menu-btn {
            background: none; border: none; color: #666; font-size: 20px; cursor: pointer; padding: 5px;
        }

        /* Popup Menu */
        .popup-overlay {
            display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.5); z-index: 200;
        }
        .popup-menu {
            position: absolute; background: #333; border-radius: 8px; width: 150px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.5); overflow: hidden;
        }
        .popup-item {
            display: block; width: 100%; padding: 12px; text-align: left;
            background: none; border: none; color: white; font-size: 14px; cursor: pointer;
        }
        .popup-item:hover { background-color: #444; }
        .popup-item.delete { color: #ff4d4d; }

        /* Modal Gửi/Rút/Sửa */
        .modal {
            display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.8); align-items: flex-end; justify-content: center; z-index: 300;
        }
        .modal-content {
            background: #222; width: 100%; padding: 20px; border-radius: 20px 20px 0 0;
        }
        .modal input {
            width: 100%; padding: 12px; margin-bottom: 10px; background: #111; border: 1px solid #333; color: white; border-radius: 8px;
            box-sizing: border-box;
        }
        .full-btn { width: 100%; padding: 15px; border-radius: 8px; border: none; font-weight: bold; cursor: pointer; }
        .green-btn { background: #00e676; color: black; }
        .red-btn { background: #ff4d4d; color: white; }
        .yellow-btn { background: #ffcc00; color: black; }

        .menu-options { text-align: right; padding: 10px; }
        .menu-options a { color: #aaa; margin-left: 15px; text-decoration: none; font-size: 14px; }
    </style>

    <script>
        // --- CÁC HÀM FORMAT TIỀN TỆ ---

        // 1. Format khi đang nhập liệu (oninput)
        function formatCurrency(input) {
            let value = input.value.replace(/\D/g, "");
            if (value === "") {
                input.value = "";
                return;
            }
            input.value = new Intl.NumberFormat('en-US').format(value);
        }

        // 2. Format số nguyên sang chuỗi có phẩy (Dùng khi đổ dữ liệu vào form sửa)
        function formatNumber(num) {
            if(!num) return "";
            return new Intl.NumberFormat('en-US').format(num);
        }

        // 3. Xóa dấu phẩy trước khi submit
        function cleanInputBeforeSubmit() {
            const amountInput = document.getElementById('inputAmount');
            amountInput.value = amountInput.value.replace(/,/g, "");
            return true;
        }
    </script>
</head>
<body>
<%
    String errorMessage = (String) request.getAttribute("errorMessage");
    if (errorMessage != null) {
%>
<div style="background-color: #ff4d4d; color: white; padding: 10px; text-align: center; font-weight: bold; position: fixed; top: 0; left: 0; width: 100%; z-index: 9999;">
    <%= errorMessage %>
</div>
<script>
    setTimeout(function() {
        document.querySelector('div[style*="background-color: #ff4d4d"]').style.display = 'none';
    }, 3000);
</script>
<% } %>
<%
    Saving s = (Saving) request.getAttribute("saving");
    List<Item> transactions = (List<Item>) request.getAttribute("transactions");
%>

<div class="menu-options">
    <a href="SaveUpMoney?action=view">❮ Quay lại</a>
    <% if(s.isStatus()) { %>
    <a href="SaveUpMoney?action=formEditSaving&id=<%=s.getCategoryId()%>">🖊 Sửa</a>
    <a href="SaveUpMoney?action=toggleStatus&id=<%=s.getCategoryId()%>">🏁 Kết thúc</a>
    <% } else { %>
    <a href="SaveUpMoney?action=deleteSaving&id=<%=s.getCategoryId()%>" onclick="return confirm('Xóa vĩnh viễn?')">🗑 Xóa</a>
    <a href="SaveUpMoney?action=toggleStatus&id=<%=s.getCategoryId()%>">🔄 Mở lại</a>
    <% } %>
</div>

<div class="header">
    <div style="font-size: 18px;"><%= s.getName() %></div>
    <div class="big-amount"><%= String.format("%,.0f", s.getSavedAmount()) %> đ</div>
    <div class="sub-text">Mục tiêu: <%= String.format("%,.0f", s.getLimitAmount()) %> đ</div>
    <div class="sub-text">Còn lại: <%= String.format("%,.0f", s.getLimitAmount() - s.getSavedAmount()) %> đ</div>
</div>

<% if(s.isStatus()) { %>
<div class="action-bar">
    <button class="action-btn" onclick="openModal('deposit')">
        <span>📥</span> Gửi vào
    </button>
    <button class="action-btn" onclick="openModal('withdraw')">
        <span>📤</span> Rút ra
    </button>
</div>
<% } %>

<div class="trans-list">
    <h4 style="color: #666; margin-bottom: 10px;">Lịch sử giao dịch</h4>
    <%
        if(transactions != null) {
            java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
            java.time.format.DateTimeFormatter valueFmt = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

            for(Item i : transactions) {
                boolean isPlus = i.getAmount() >= 0;
                double absAmount = Math.abs(i.getAmount());
                String dateVal = i.getCreatedAt().format(valueFmt);
                String descVal = i.getDescribe() != null ? i.getDescribe() : "";
    %>
    <div class="trans-item">
        <div>
            <div><%= descVal %></div>
            <div class="trans-date"><%= i.getCreatedAt().format(fmt) %></div>
        </div>
        <div style="display: flex; align-items: center;">
            <div class="trans-amount <%= isPlus?"plus":"minus" %>">
                <%= isPlus ? "+" : "" %><%= String.format("%,.0f", i.getAmount()) %>
            </div>

            <% if(s.isStatus()) { %>
            <!-- Nút 3 chấm: Lưu data item vào hàm onclick -->
            <button class="item-menu-btn"
                    onclick="openMenu(event, '<%=i.getItemId()%>', '<%=String.format("%.0f", absAmount)%>', '<%=descVal%>', '<%=dateVal%>', '<%= isPlus ? "deposit" : "withdraw" %>')">
                ⋮
            </button>
            <% } %>
        </div>
    </div>
    <%
        }
    } else {
    %>
    <div style="text-align: center; color: #666;">Chưa có giao dịch nào</div>
    <% } %>
</div>

<!-- POPUP MENU (Edit/Delete) -->
<div id="popupOverlay" class="popup-overlay" onclick="closeMenu()">
    <div id="popupMenu" class="popup-menu" onclick="event.stopPropagation()">
        <!-- Nút Sửa gọi JS để mở Modal -->
        <button type="button" class="popup-item" onclick="submitEdit()">✎ Chỉnh sửa</button>

        <!-- Form Xóa submit trực tiếp -->
        <form id="formDelete" action="SaveUpMoney" method="post" style="margin:0;">
            <input type="hidden" name="action" value="deleteTransaction">
            <input type="hidden" name="savingId" value="<%= s.getCategoryId() %>">
            <input type="hidden" name="itemId" id="delItemId">
            <button type="submit" class="popup-item delete" onclick="return confirm('Xóa giao dịch này?')">🗑 Xóa</button>
        </form>
    </div>
</div>

<!-- MODAL GIAO DỊCH (Dùng chung cho Add/Edit) -->
<div id="transModal" class="modal" onclick="if(event.target==this) closeModal()">
    <div class="modal-content">
        <h3 id="modalTitle">Gửi tiền</h3>
        <!-- Thêm onsubmit để clean input -->
        <form action="SaveUpMoney" method="post" id="transForm" onsubmit="return cleanInputBeforeSubmit()">
            <!-- Action mặc định là transaction, JS sẽ đổi thành updateTransaction khi sửa -->
            <input type="hidden" name="action" id="formAction" value="transaction">
            <input type="hidden" name="savingId" value="<%= s.getCategoryId() %>">
            <input type="hidden" name="itemId" id="formItemId"> <!-- Dùng khi Edit -->
            <input type="hidden" name="transType" id="transType">

            <!-- Đổi type="text" và thêm oninput -->
            <input type="text" name="amount" id="inputAmount"
                   placeholder="Nhập số tiền" required
                   oninput="formatCurrency(this)">

            <input type="text" name="description" id="inputDesc" placeholder="Ghi chú thêm ">
            <input type="datetime-local" name="date" id="inputDate" value="<%= java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")) %>">

            <button type="submit" id="modalBtn" class="full-btn">XÁC NHẬN</button>
        </form>
    </div>
</div>

<script>
    // --- 1. POPUP MENU LOGIC ---
    let currentItemData = {}; // Biến toàn cục lưu tạm thông tin item để fill vào form edit

    function openMenu(e, itemId, amount, desc, date, type) {
        e.stopPropagation();

        // Lưu data vào biến tạm
        currentItemData = { itemId, amount, desc, date, type };
        // Set ID cho form xóa
        document.getElementById('delItemId').value = itemId;

        // Tính toán vị trí hiển thị menu
        const overlay = document.getElementById('popupOverlay');
        const menu = document.getElementById('popupMenu');

        let x = e.clientX - 120;
        let y = e.clientY + 10;

        // Giới hạn không cho tràn màn hình bên phải
        if (x + 150 > window.innerWidth) x = window.innerWidth - 160;

        menu.style.left = x + 'px';
        menu.style.top = y + 'px';
        overlay.style.display = 'block';
    }

    function closeMenu() {
        document.getElementById('popupOverlay').style.display = 'none';
    }

    function submitEdit() {
        // Mở modal và fill dữ liệu từ biến tạm, bật cờ isEdit = true
        openModal(currentItemData.type, true);
        closeMenu();
    }

    // --- 2. MODAL LOGIC ---
    function openModal(type, isEdit = false) {
        document.getElementById('transModal').style.display = 'flex';
        document.getElementById('transType').value = type;

        if (isEdit) {
            // CHẾ ĐỘ SỬA: Fill data cũ
            document.getElementById('formAction').value = 'updateTransaction';
            document.getElementById('formItemId').value = currentItemData.itemId;

            // Format số tiền có sẵn (ví dụ 500000 -> 500,000)
            document.getElementById('inputAmount').value = formatNumber(currentItemData.amount);

            document.getElementById('inputDesc').value = currentItemData.desc;
            document.getElementById('inputDate').value = currentItemData.date;

            document.getElementById('modalTitle').innerText = 'Chỉnh sửa giao dịch';
            document.getElementById('modalBtn').innerText = 'CẬP NHẬT';
            document.getElementById('modalBtn').className = 'full-btn yellow-btn'; // Màu vàng
        } else {
            // CHẾ ĐỘ THÊM MỚI: Reset form
            document.getElementById('formAction').value = 'transaction';
            document.getElementById('formItemId').value = '';
            document.getElementById('inputAmount').value = '';
            document.getElementById('inputDesc').value = '';
            // Date giữ nguyên ngày giờ hiện tại (đã set value mặc định trong HTML)

            if(type === 'deposit') {
                document.getElementById('modalTitle').innerText = 'Gửi tiền vào quỹ';
                document.getElementById('modalBtn').innerText = 'GỬI VÀO';
                document.getElementById('modalBtn').className = 'full-btn green-btn';
            } else {
                document.getElementById('modalTitle').innerText = 'Rút tiền từ quỹ';
                document.getElementById('modalBtn').innerText = 'RÚT RA';
                document.getElementById('modalBtn').className = 'full-btn red-btn';
            }
        }
    }

    function closeModal() {
        document.getElementById('transModal').style.display = 'none';
    }
</script>

</body>
</html>