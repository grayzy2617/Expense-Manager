<%@ page import="Model.BO.Saving" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Tích lũy</title>
    <style>
        body { background-color: #111; color: white; font-family: sans-serif; padding: 10px; }
        .tab-bar { display: flex; justify-content: center; margin-bottom: 20px; }
        .tab { padding: 10px 20px; color: #888; text-decoration: none; border-bottom: 2px solid transparent; }
        .tab.active { color: #ffcc00; border-bottom: 2px solid #ffcc00; font-weight: bold; }

        .saving-card {
            background-color: #222; border-radius: 12px; padding: 15px; margin-bottom: 15px;
            display: flex; align-items: center; cursor: pointer;
        }
        .icon-box {
            width: 50px; height: 50px; background-color: #333; border-radius: 50%;
            display: flex; align-items: center; justify-content: center; font-size: 24px; margin-right: 15px; color: #ffcc00;
        }
        .info { flex-grow: 1; }
        .name { font-size: 16px; font-weight: bold; margin-bottom: 5px; }
        .money { font-size: 14px; color: #ccc; }
        .highlight { color: #ffcc00; font-weight: bold; }
        .progress-bar {
            height: 6px; background-color: #444; border-radius: 3px; margin-top: 8px; overflow: hidden;
        }
        .progress-fill { height: 100%; background-color: #ffcc00; }

        .add-btn {
            position: fixed; bottom: 80px; right: 20px;
            background-color: #ffcc00; color: black; width: 50px; height: 50px;
            border-radius: 50%; display: flex; align-items: center; justify-content: center;
            font-size: 30px; text-decoration: none; box-shadow: 0 4px 10px rgba(0,0,0,0.5);
        }
    </style>
</head>
<body>

<h2 style="text-align: center;">Mục tiêu tích lũy</h2>

<% String tab = (String) request.getAttribute("tab"); %>
<div class="tab-bar">
    <a href="SaveUpMoney?action=view&tab=ongoing" class="tab <%= "ongoing".equals(tab)?"active":"" %>">Đang thực hiện</a>
    <a href="SaveUpMoney?action=view&tab=finished" class="tab <%= "finished".equals(tab)?"active":"" %>">Đã hoàn thành</a>
</div>

<%
    List<Saving> list = (List<Saving>) request.getAttribute("list");
    if(list != null && !list.isEmpty()) {
        for(Saving s : list) {
%>
<div class="saving-card" onclick="window.location='SaveUpMoney?action=detail&id=<%= s.getCategoryId() %>'">
    <div class="icon-box">💰</div>
    <div class="info">
        <div class="name"><%= s.getName() %></div>
        <div class="money">
            <span class="highlight"><%= String.format("%,.0f", s.getSavedAmount()) %></span>
            / <%= String.format("%,.0f", s.getLimitAmount()) %> đ
        </div>
        <div class="progress-bar">
            <div class="progress-fill" style="width: <%= s.getProgressPercent() %>%;"></div>
        </div>
    </div>
    <div style="font-size: 20px; color: #666;">&rsaquo;</div>
</div>
<%
    }
} else {
%>
<div style="text-align: center; color: #666; margin-top: 50px;">
    Chưa có mục tiêu nào.
</div>
<% } %>

<a href="SaveUpMoney?action=formAdd" class="add-btn">+</a>

<!-- Menu Footer (Copy lại từ các file khác) -->
<jsp:include page="../MenuFooter.jsp" />

</body>
</html>