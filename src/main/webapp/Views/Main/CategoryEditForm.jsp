<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chỉnh sửa danh mục</title>
    <style>
        body { background-color: #111; color: white; font-family: sans-serif; padding: 20px; }
        label { display: block; margin-bottom: 8px; font-weight: bold; }
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
<h2>Chỉnh sửa danh mục</h2>
<%
    HttpSession sessionn = request.getSession();
    String type = (String) sessionn.getAttribute("type");
    String name = (String) sessionn.getAttribute("name");
    String id = (String) sessionn.getAttribute("id");
    String limit = (String) sessionn.getAttribute("limit"); // Lấy limit gốc (có thể là "2000000.0")
    String pagePrev = (String) sessionn.getAttribute("pagePrev");

    // --- XỬ LÝ FORMAT HIỂN THỊ SỐ TIỀN ---
    String displayLimit = "";
    if (limit != null && !limit.isEmpty() && !limit.equals("null")) {
        try {
            // Chuyển chuỗi về Double, sau đó ép về long để bỏ số thập phân
            double val = Double.parseDouble(limit);
            // Format thêm dấu phẩy (2000000 -> 2,000,000) cho dễ nhìn ngay từ đầu
            displayLimit = String.format("%,d", (long)val);
        } catch (Exception e) {
            displayLimit = limit; // Fallback nếu lỗi
        }
    }
%>
<form action="${pageContext.request.contextPath}/Main?action=editCategory" method="post" onsubmit="return cleanInputBeforeSubmit()">
    <input type="hidden" name="type" value="<%= type %>">
    <input type="hidden" name="id" value="<%=id%>">

    <label for="name">Tên danh mục</label>
    <input type="text" name="name" value="<%=name%>" required>

    <% if ("EXPENSE".equals(type)) { %>
    <label for="limit">Hạn mức chi tiêu (VNĐ)</label>
    <!--
         1. Đổi type="text" để nhận dấu phẩy.
         2. Thêm id="limitInput" để JS xử lý lúc submit.
         3. Value dùng biến displayLimit đã format đẹp.
    -->
    <input type="text" id="limitInput" name="limit"
           value="<%= displayLimit %>"
           placeholder="Không giới hạn"
           oninput="formatCurrency(this)">
    <% } %>

    <button type="submit">Cập nhật danh mục</button>
</form>

<a href="${pageContext.request.contextPath}/Main?action=<%=pagePrev%>" class="back-btn">← Quay lại</a>
</body>
</html>