<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, po.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>我的订单</title>
<link rel="stylesheet" type="text/css" href="css/main.css">
<style>
    body { background: #f5f5f5; }
    .header {
        background: #2d8cf0;
        color: white;
        padding: 10px 30px;
        overflow: hidden;
    }
    .header h1 { float: left; margin: 0; font-size: 22px; line-height: 40px; }
    .header .nav { float: right; line-height: 40px; }
    .header .nav a { color: #fff; margin-left: 15px; text-decoration: none; }
    .order-container {
        width: 800px;
        margin: 30px auto;
        background: #fff;
        border-radius: 8px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        padding: 20px 30px;
    }
    .order-container h2 { border-bottom: 2px solid #2d8cf0; padding-bottom: 10px; }
    table { width: 100%; border-collapse: collapse; margin: 15px 0; }
    table th { background: #f7f7f7; padding: 10px; border: 1px solid #ddd; font-size: 14px; }
    table td { padding: 10px; border: 1px solid #ddd; text-align: center; font-size: 14px; }
    .empty { text-align: center; padding: 40px; color: #999; }
    .state-unshipped { color: #e4393c; }
    .state-shipped { color: #19be6b; }
</style>
</head>
<body>
<div class="header">
    <h1>🛒 购物商城</h1>
    <div class="nav">
        <a href="index.jsp">首页</a>
        <a href="CartServlet?operation=showCart">购物车</a>
    </div>
</div>

<div class="order-container">
    <h2>我的订单</h2>
    <%
        List<Orders> userOrders = (List<Orders>) request.getAttribute("UserOrders");
        if (userOrders == null || userOrders.isEmpty()) {
    %>
        <div class="empty">
            <p style="font-size:16px;">暂无订单</p>
            <p><a href="index.jsp" style="color:#2d8cf0;">去购物</a></p>
        </div>
    <%
        } else {
    %>
    <table>
        <tr>
            <th>订单号</th>
            <th>金额</th>
            <th>商品数量</th>
            <th>订单状态</th>
        </tr>
        <%
            for (Orders order : userOrders) {
        %>
        <tr>
            <td><%=order.getOrderId()%></td>
            <td>¥<%=String.format("%.2f", order.getPrice())%></td>
            <td><%=order.getNum()%></td>
            <td>
                <span class="<%=order.getState() == 0 ? "state-unshipped" : "state-shipped"%>">
                    <%=order.getState() == 0 ? "未发货" : "已发货"%>
                </span>
            </td>
        </tr>
        <%
            }
        %>
    </table>
    <%
        }
    %>
</div>
</body>
</html>