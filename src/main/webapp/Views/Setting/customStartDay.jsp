<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="Model.BO.MonthRange" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%
    Integer startDay = (Integer) request.getAttribute("startDay");
    if (startDay == null) startDay = 1;

    MonthRange preview = (MonthRange) request.getAttribute("preview");
    Integer monthBefore = (Integer) request.getAttribute("monthBefore");
    Integer monthAfter = (Integer) request.getAttribute("monthAfter");

    // Format ngày giờ cho đẹp (dd/MM/yyyy)
    DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");
%>

<html>
<head>
    <title>Cấu hình ngày bắt đầu</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            background-color: #111;
            color: white;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            margin: 0;
            padding: 0;
            padding-bottom: 80px;
        }

        .header {
            padding: 20px;
            text-align: center;
            font-size: 20px;
            font-weight: bold;
            border-bottom: 1px solid #222;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .header a {
            color: #ffcc00;
            text-decoration: none;
            font-size: 16px;
        }

        .container {
            padding: 20px;
        }

        /* Card Style */
        .card {
            background-color: #222;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 20px;
        }

        label {
            display: block;
            margin-bottom: 10px;
            font-weight: bold;
            color: #ccc;
        }

        input[type="number"], select {
            width: 100%;
            padding: 12px;
            background-color: #111;
            border: 1px solid #333;
            color: white;
            border-radius: 8px;
            font-size: 16px;
            box-sizing: border-box;
            margin-bottom: 15px;
        }

        input:focus, select:focus {
            border-color: #ffcc00;
            outline: none;
        }

        button {
            width: 100%;
            padding: 15px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            margin-top: 10px;
        }

        .btn-preview {
            background-color: #333;
            color: white;
            border: 1px solid #555;
        }
        .btn-preview:hover {
            background-color: #444;
        }

        .btn-save {
            background-color: #ffcc00;
            color: black;
        }
        .btn-save:hover {
            background-color: #e6b800;
        }

        /* Preview Box */
        .preview-box {
            border: 1px solid #ffcc00;
            background-color: rgba(255, 204, 0, 0.1);
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 20px;
            text-align: center;
        }
        .preview-title {
            color: #ffcc00;
            font-weight: bold;
            margin-bottom: 5px;
            text-transform: uppercase;
            font-size: 12px;
        }
        .preview-date {
            font-size: 18px;
            font-weight: bold;
        }

        .helper-text {
            font-size: 13px;
            color: #888;
            margin-bottom: 15px;
            line-height: 1.4;
        }
    </style>
</head>
<body>

<div class="header">
    <a href="${pageContext.request.contextPath}/SettingServlet?action=viewSettings">❮ Quay lại</a>
    <span>Ngày bắt đầu</span>
    <span style="width: 60px;"></span> <!-- Spacer -->
</div>

<div class="container">

    <!-- FORM 1: CHỌN NGÀY -->
    <div class="card">
        <form action="SettingServlet" method="post">
            <input type="hidden" name="action" value="previewRange">

            <label>Ngày bắt đầu tháng tài chính</label>
            <p class="helper-text">
                Chọn ngày bạn muốn bắt đầu tính toán cho một tháng mới (ví dụ: ngày nhận lương).
            </p>

            <input type="number" name="startDay" min="1" max="31" value="<%=startDay%>" required placeholder="Nhập từ 1-31">

            <button type="submit" class="btn-preview">Xem trước chu kỳ</button>
        </form>
    </div>

    <!-- KHỐI PREVIEW (Chỉ hiện khi có dữ liệu từ Servlet) -->
    <% if (preview != null) { %>

    <div class="preview-box">
        <div class="preview-title">Chu kỳ dự kiến</div>
        <div class="preview-date">
            <%= preview.getStart().format(fmt) %> ➔ <%= preview.getEnd().format(fmt) %>
        </div>
    </div>

    <!-- FORM 2: LƯU CẤU HÌNH -->
    <div class="card">
        <form action="${pageContext.request.contextPath}/SettingServlet?action=saveStartDay" method="post">
            <input type="hidden" name="action" value="saveStartDay">
            <input type="hidden" name="startDay" value="<%=startDay%>">

            <label>Chu kỳ này thuộc về tháng nào?</label>
            <p class="helper-text">

            </p>

            <select name="chosenMonth">
                <option value="<%=monthAfter%>">Tháng <%=monthAfter%> </option>
                <option value="<%=monthBefore%>">Tháng <%=monthBefore%> </option>

            </select>

            <button type="submit" class="btn-save">Lưu Cài Đặt</button>
        </form>
    </div>

    <% } %>

</div>

<jsp:include page="../MenuFooter.jsp" />

</body>
</html>