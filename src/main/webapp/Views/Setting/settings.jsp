<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="Model.BO.CurrentUser" %>
<html>
<head>
    <title>Cài đặt</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            background-color: #111; /* Nền tối đồng bộ */
            color: white;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            margin: 0;
            padding: 0;
            padding-bottom: 80px; /* Chừa chỗ cho footer */
        }

        .header {
            padding: 20px;
            text-align: center;
            font-size: 20px;
            font-weight: bold;
            border-bottom: 1px solid #222;
        }

        /* Profile Section */
        .profile-section {
            display: flex;
            align-items: center;
            background-color: #222;
            margin: 20px;
            padding: 15px;
            border-radius: 12px;
        }
        .avatar {
            width: 50px; height: 50px;
            background-color: #ffcc00;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 24px; font-weight: bold; color: black;
            margin-right: 15px;
        }
        .user-info h3 { margin: 0; font-size: 18px; }
        .user-info p { margin: 5px 0 0 0; color: #888; font-size: 14px; }

        /* Settings Group */
        .settings-group {
            margin: 20px;
            background-color: #222;
            border-radius: 12px;
            overflow: hidden; /* Để bo tròn các item con */
        }

        .setting-row {
            border-bottom: 1px solid #333;
        }
        .setting-row:last-child {
            border-bottom: none;
        }

        /* Biến nút form thành dòng menu */
        .menu-btn {
            width: 100%;
            background: none;
            border: none;
            padding: 15px;
            color: white;
            font-size: 16px;
            text-align: left;
            cursor: pointer;
            display: flex;
            justify-content: space-between; /* Đẩy mũi tên sang phải */
            align-items: center;
            transition: background 0.2s;
        }
        .menu-btn:hover {
            background-color: #333;
        }

        .arrow {
            color: #666;
            font-size: 20px;
            font-weight: bold;
        }

        /* Danger Zone */
        .danger-text {
            color: #ff4d4d;
            font-weight: bold;
        }

        /* Thông báo */
        #msgBox {
            margin: 20px;
            padding: 15px;
            border-radius: 8px;
            text-align: center;
            display: none; /* Mặc định ẩn */
        }
        .msg-success { background: rgba(0, 255, 0, 0.1); border: 1px solid lime; color: lime; }
        .msg-error { background: rgba(255, 0, 0, 0.1); border: 1px solid red; color: red; }

        .section-title {
            margin-left: 30px;
            margin-bottom: 5px;
            color: #888;
            font-size: 13px;
            text-transform: uppercase;
        }
    </style>
</head>
<body>

<div class="header">Cài đặt</div>

<div class="profile-section">
    <div class="avatar">
        <%= CurrentUser.getInstance().getUsername() != null ? CurrentUser.getInstance().getUsername().substring(0,1).toUpperCase() : "U" %>
    </div>
    <div class="user-info">
        <h3><%= CurrentUser.getInstance().getUsername() %></h3>
        <p>ID: <%= CurrentUser.getInstance().getUserId() %></p>
    </div>
</div>

<%
    String msg = request.getParameter("msg");
    if (msg != null) {
        String msgClass = "saved".equals(msg) ? "msg-success" : "msg-error";
        String msgText = "saved".equals(msg) ? "✔ Cập nhật thành công!" : "✔ Đã xóa dữ liệu!";
%>
<div id="msgBox" class="<%= msgClass %>" style="display: block;">
    <%= msgText %>
</div>
<script>
    setTimeout(() => {
        const box = document.getElementById("msgBox");
        if(box) {
            box.style.transition = "opacity 0.5s";
            box.style.opacity = "0";
            setTimeout(() => box.style.display = "none", 500);
        }
    }, 3000);
</script>
<% } %>

<div class="section-title">Cấu hình chung</div>
<div class="settings-group">

    <div class="setting-row">
        <form action="${pageContext.request.contextPath}/SettingServlet?action=customStartDay" method="post" style="margin:0;">
            <button type="submit" class="menu-btn">
                <span>📅 Ngày bắt đầu tháng tài chính</span>
                <span class="arrow">›</span>
            </button>
        </form>
    </div>

    <div class="setting-row">
        <button type="button" class="menu-btn" onclick="alert('Chức năng đang cập nhật!')">
            <span>🏠 Trang chủ mặc định</span>
            <span class="arrow">›</span>
        </button>
    </div>

    <div class="setting-row">
        <button type="button" class="menu-btn" onclick="alert('Chức năng đang cập nhật!')">
            <span>🔔 Nhắc nhở nhập chi tiêu </span>
            <span class="arrow">›</span>
        </button>
    </div>
</div>

<div class="section-title">Dữ liệu</div>
<div class="settings-group">
    <div class="setting-row">
        <button onclick="confirmDelete()" class="menu-btn">
            <span class="danger-text">🗑 Xóa tất cả dữ liệu</span>
            <span class="arrow">›</span>
        </button>
    </div>

    <div class="setting-row">
        <form action="${pageContext.request.contextPath}/Login" method="get" style="margin:0;">
            <button type="submit" class="menu-btn" onclick="return confirm('Bạn muốn đăng xuất?');">
                <span style="color: #ffcc00;">🚪 Đăng xuất</span>
                <span class="arrow">›</span>
            </button>
        </form>
    </div>
</div>

<script>
    function confirmDelete() {
        if (confirm("CẢNH BÁO: Hành động này không thể hoàn tác!\nBạn có chắc chắn muốn xóa toàn bộ dữ liệu chi tiêu, danh mục và tích lũy không?")) {
            // Chuyển hướng đến servlet xóa dữ liệu
            window.location.href = "${pageContext.request.contextPath}/SettingServlet?action=deleteAll";
        }
    }
</script>

<jsp:include page="../MenuFooter.jsp" />

</body>
</html>