<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Đăng nhập</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            background-color: #111;
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .login-container {
            background-color: #222;
            padding: 40px 30px;
            border-radius: 20px;
            box-shadow: 0px 10px 30px rgba(0,0,0,0.5);
            width: 100%;
            max-width: 350px;
            text-align: center;
        }
        h2 {
            margin-bottom: 30px;
            color: #ffcc00;
            font-size: 28px;
        }

        .input-group {
            margin-bottom: 20px;
            text-align: left;
        }

        label {
            display: block;
            margin-bottom: 8px;
            color: #aaa;
            font-size: 14px;
        }

        input[type=text], input[type=password] {
            width: 100%;
            padding: 12px;
            background-color: #111;
            border: 1px solid #333;
            border-radius: 8px;
            color: white;
            font-size: 16px;
            box-sizing: border-box;
            transition: border-color 0.3s;
        }

        input:focus {
            outline: none;
            border-color: #ffcc00;
        }

        input[type=submit] {
            width: 100%;
            background-color: #ffcc00;
            color: black;
            padding: 12px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            font-weight: bold;
            margin-top: 10px;
            transition: transform 0.1s;
        }

        input[type=submit]:active {
            transform: scale(0.98);
        }

        .error {
            color: #ff4d4d;
            background-color: rgba(255, 77, 77, 0.1);
            padding: 10px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
        }

        .success {
            color: #00e676;
            background-color: rgba(0, 230, 118, 0.1);
            padding: 10px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
        }

        .register-link {
            margin-top: 20px;
            font-size: 14px;
            color: #888;
        }
        .register-link a {
            color: #ffcc00;
            text-decoration: none;
            font-weight: bold;
        }
    </style>
</head>
<body>

<div class="login-container">
    <h2>Expense Manager</h2>

    <%
        String error = (String) request.getAttribute("error"); // Lấy từ attribute (do servlet set)
        if (error == null) error = request.getParameter("error"); // Fallback lấy từ param

        String msg = request.getParameter("msg");

        if (error != null) {
    %>
    <div class="error"><%= error %></div>
    <% } else if ("registered".equals(msg)) { %>
    <div class="success">Đăng ký thành công! Vui lòng đăng nhập.</div>
    <% } %>

    <form action="CheckLogin" method="post">
        <div class="input-group">
            <label for="username">Tên đăng nhập</label>
            <input type="text" name="username" required>
        </div>

        <div class="input-group">
            <label for="password">Mật khẩu</label>
            <input type="password" name="password" required>
        </div>

        <input type="submit" value="Đăng nhập">
    </form>

    <div class="register-link">
        Chưa có tài khoản? <a href="Register">Đăng ký ngay</a>
    </div>
</div>

</body>
</html>