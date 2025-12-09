<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String uri = request.getRequestURI();
    String currentAction = request.getParameter("action");
    if(currentAction == null) currentAction = "";

    // Logic xác định menu active (Bỏ phần Calendar)
    boolean isReport = uri.contains("Report") || "expenseMonth".equals(currentAction) || "incomeMonth".equals(currentAction) || "view".equals(currentAction) && uri.contains("Report");
    boolean isInput = "input".equals(currentAction) || "incomeMain".equals(currentAction) || "expenseMain".equals(currentAction);
    boolean isSaving = uri.contains("SaveUpMoney") || "saving".equals(currentAction) || "view".equals(currentAction) && uri.contains("SaveUpMoney");
    boolean isSetting = uri.contains("SettingServlet") || "viewSettings".equals(currentAction);
%>

<div style="
    position: fixed;
    bottom: 20px;
    left: 50%;
    transform: translateX(-50%); /* Căn giữa màn hình */
    width: 95%;
    max-width: 450px; /* Giới hạn chiều rộng */
    background-color: #222;
    padding: 10px 0;
    border-radius: 30px; /* Bo tròn mềm mại hơn */
    box-shadow: 0 10px 30px rgba(0,0,0,0.6); /* Đổ bóng sâu hơn */
    border: 1px solid #333;
    z-index: 999;
">
    <table style="margin: 0 auto; color: white; text-align: center; width: 100%;">
        <tr>
            <!-- 1. BÁO CÁO (25%) -->
            <td style="width: 25%;">
                <form action="${pageContext.request.contextPath}/Report?action=expenseMonth" method="post" style="margin:0;">
                    <button type="submit" style="background:none; border:none; padding: 0; cursor: pointer; color: <%= isReport ? "#ffcc00" : "#888" %>; width: 100%;">
                        <div style="font-size: 22px; margin-bottom: 3px;">📊</div>
                        <div style="font-size: 11px; font-weight: <%= isReport ? "bold" : "normal" %>;">Báo cáo</div>
                    </button>
                </form>
            </td>

            <!-- 2. TÍCH LŨY (25%) - Đưa lên vị trí số 2 cho cân đối -->
            <td style="width: 25%;">
                <form action="${pageContext.request.contextPath}/SaveUpMoney?action=view" method="post" style="margin:0;">
                    <button type="submit" style="background:none; border:none; padding: 0; cursor: pointer; color: <%= isSaving ? "#ffcc00" : "#888" %>; width: 100%;">
                        <div style="font-size: 22px; margin-bottom: 3px;">💰</div>
                        <div style="font-size: 11px; font-weight: <%= isSaving ? "bold" : "normal" %>;">Tích lũy</div>
                    </button>
                </form>
            </td>

            <!-- 3. NHẬP (25%) - Nút nổi bật -->
            <td style="width: 25%;">
                <form action="${pageContext.request.contextPath}/Main?action=expenseMain" method="post" style="margin:0;">
                    <button type="submit" style="background:none; border:none; padding: 0; cursor: pointer; width: 100%; position: relative;">
                        <div style="
                                background-color: <%= isInput ? "#ffcc00" : "#444" %>;
                                color: <%= isInput ? "black" : "white" %>;
                                width: 50px; height: 50px; /* Tăng kích thước nút nổi một chút */
                                border-radius: 50%;
                                display: flex; align-items: center; justify-content: center;
                                margin: -40px auto 5px auto; /* Đẩy lên cao hơn */
                                border: 6px solid #111; /* Viền dày trùng màu nền body */
                                box-shadow: 0 5px 15px rgba(0,0,0,0.4);
                                transition: transform 0.2s;
                                ">
                            <span style="font-size: 28px; font-weight: bold;">+</span>
                        </div>
                        <div style="font-size: 11px; color: <%= isInput ? "#ffcc00" : "#888" %>; font-weight: <%= isInput ? "bold" : "normal" %>;">Nhập</div>
                    </button>
                </form>
            </td>

            <!-- 4. CÀI ĐẶT (25%) -->
            <td style="width: 25%;">
                <form action="${pageContext.request.contextPath}/SettingServlet?action=viewSettings" method="post" style="margin:0;">
                    <button type="submit" style="background:none; border:none; padding: 0; cursor: pointer; color: <%= isSetting ? "#ffcc00" : "#888" %>; width: 100%;">
                        <div style="font-size: 22px; margin-bottom: 3px;">⚙️</div>
                        <div style="font-size: 11px; font-weight: <%= isSetting ? "bold" : "normal" %>;">Cài đặt</div>
                    </button>
                </form>
            </td>
        </tr>
    </table>
</div>