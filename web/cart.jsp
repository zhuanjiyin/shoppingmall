<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, po.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>购物车</title>
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
    .cart-container {
        width: 900px;
        margin: 30px auto;
        background: #fff;
        border-radius: 8px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        padding: 20px 30px;
    }
    .cart-container h2 { border-bottom: 2px solid #2d8cf0; padding-bottom: 10px; }
    table { width: 100%; border-collapse: collapse; margin: 15px 0; }
    table th { background: #f7f7f7; padding: 10px; border: 1px solid #ddd; font-size: 14px; }
    table td { padding: 10px; border: 1px solid #ddd; text-align: center; font-size: 14px; }
    table img { width: 80px; height: 60px; }
    .empty { text-align: center; padding: 40px; color: #999; }
    .total { text-align: right; font-size: 18px; padding: 15px 0; }
    .total span { color: #e4393c; font-weight: bold; font-size: 22px; }
    .actions { text-align: right; margin-top: 15px; }
    .actions a, .actions button {
        display: inline-block;
        padding: 8px 20px;
        margin-left: 10px;
        border-radius: 4px;
        text-decoration: none;
        font-size: 14px;
    }
    .btn-clear { background: #999; color: #fff; }
    .btn-order { background: #e4393c; color: #fff; }
    .btn-back { background: #2d8cf0; color: #fff; }
    .btn-remove { color: #e4393c; text-decoration: none; font-size: 12px; }
    .btn-remove:hover { text-decoration: underline; }
</style>
</head>
<body>
<div class="header">
    <h1>🛒 购物商城</h1>
    <div class="nav">
        <a href="index.jsp">首页</a>
        <a href="OrderServlet?operation=showUsersOrders">我的订单</a>
    </div>
</div>

<div class="cart-container">
    <h2>我的购物车</h2>
    <%
        Cart cart = (Cart) session.getAttribute("cart");
        if (cart == null || cart.getItems().isEmpty()) {
    %>
        <div class="empty">
            <p style="font-size:16px;">购物车为空</p>
            <p><a href="index.jsp" style="color:#2d8cf0;">去逛逛</a></p>
        </div>
    <%
        } else {
    %>
    <table>
        <tr>
            <th>商品图片</th>
            <th>商品名称</th>
            <th>单价</th>
            <th>数量</th>
            <th>小计</th>
            <th>操作</th>
        </tr>
        <%
            for (Map.Entry<Integer, CartItem> entry : cart.getItems().entrySet()) {
                CartItem item = entry.getValue();
                Goods g = item.getGood();
        %>
        <tr>
            <td><img src="images/<%=g.getPicture()%>" alt="<%=g.getName()%>"></td>
            <td><%=g.getName()%></td>
            <td>¥<%=g.getPrice()%></td>
            <td><%=item.getNum()%></td>
            <td>¥<%=item.getPrice()%></td>
            <td>
                <a class="btn-remove" href="CartServlet?operation=remove&id=<%=g.getId()%>">移除</a>
            </td>
        </tr>
        <%
            }
        %>
    </table>
    <div class="total">
        商品总数：<%=cart.getNum()%> 件　
        总金额：<span>¥<%=String.format("%.2f", cart.getPrice())%></span>
    </div>
    <div class="actions">
        <a class="btn-clear" href="CartServlet?operation=clear">清空购物车</a>
        <a class="btn-back" href="index.jsp">继续购物</a>
        <a class="btn-order" href="OrderServlet?operation=genOrders">提交订单</a>
    </div>
    <%
        }
    %>
</div>
</body>
</html>