<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thêm danh mục</title>
    <style>
        body { background-color: #111; color: white; font-family: sans-serif; padding: 20px; }
        label { display: block; margin-bottom: 8px; font-weight: bold; }
        /* Lưu ý: input[type="text"] sẽ áp dụng cho cả tên và hạn mức mới */
        input[type="text"], input[type="number"] {
            width: 100%; padding: 12px; border-radius: 8px; border: 1px solid #333;
            background-color: #222; color: white; margin-bottom: 20px;
            box-sizing: border-box;
        }
        button {
            display: block; width: 100%; padding: 12px;
            background-color: #444; color: white; border: none; border-radius: 10px; cursor: pointer;
        }
        button:hover { background-color: #666; }
        a.back-btn { display: inline-block; margin-top: 20px; color: #ccc; text-decoration: none; }
    </style>
    <script>
        // Hàm format tiền tệ (thêm dấu phẩy)
        function formatCurrency(input) {
            // 1. Xóa mọi ký tự không phải số
            let value = input.value.replace(/\D/g, "");

            // 2. Nếu rỗng thì thoát
            if (value === "") {
                input.value = "";
                return;
            }

            // 3. Format lại có dấu phẩy
            input.value = new Intl.NumberFormat('en-US').format(value);
        }

        // Hàm xóa dấu phẩy trước khi submit form
        function cleanInputBeforeSubmit() {
            // Lấy input hạn mức (nếu có)
            const limitInput = document.getElementById('limitInput');

            // Kiểm tra xem input có tồn tại không (vì nó chỉ hiện khi type là EXPENSE)
            if (limitInput) {
                // Xóa dấu phẩy để gửi số nguyên về server
                limitInput.value = limitInput.value.replace(/,/g, "");
            }
            return true; // Cho phép submit
        }
    </script>
</head>
<body>
<h2>Thêm danh mục mới</h2>
<%
    HttpSession sessionn = request.getSession();
    String type = (String) sessionn.getAttribute("typeInCateManager");
    String pagePrev = (String) sessionn.getAttribute("pagePrev");
%>
<!-- Thêm onsubmit để gọi hàm làm sạch dữ liệu -->
<form action="${pageContext.request.contextPath}/Main?action=addCategory" method="post" onsubmit="return cleanInputBeforeSubmit()">
    <input type="hidden" name="type" value="<%= type %>">

    <label for="name">Tên danh mục</label>
    <input type="text" name="name" placeholder="Nhập tên danh mục" required>

    <!-- Chỉ hiện hạn mức nếu là EXPENSE (Chi tiêu) -->
    <% if ("EXPENSE".equals(type)) { %>
    <label for="limit">Hạn mức chi tiêu (VNĐ)</label>
    <input type="text" id="limitInput" name="limit"
           placeholder="Ví dụ: 2,000,000 (Không bắt buộc)"
           oninput="formatCurrency(this)">
    <small style="color: #888; display: block; margin-top: -15px; margin-bottom: 20px;">
        Nhập số tiền tối đa bạn muốn chi cho mục này mỗi tháng.
    </small>
    <% } %>

    <button type="submit">Lưu danh mục</button>
</form>

<a href="${pageContext.request.contextPath}/Main?action=<%=pagePrev%>" class="back-btn">← Quay lại</a>
</body>
</html>