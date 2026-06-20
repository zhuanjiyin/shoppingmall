<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, dao.GoodsDao, po.Goods" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>购物商城 - 首页</title>
<link rel="stylesheet" type="text/css" href="css/main.css">
<link rel="stylesheet" type="text/css" href="css/style.css">
<style>
    .header {
        background: #2d8cf0;
        color: white;
        padding: 10px 30px;
        overflow: hidden;
    }
    .header h1 { float: left; margin: 0; font-size: 22px; line-height: 40px; }
    .header .user-info { float: right; line-height: 40px; }
    .header .user-info a { color: #fff; margin-left: 15px; text-decoration: none; }
    .header .user-info a:hover { text-decoration: underline; }
    .product-grid { padding: 20px; overflow: hidden; }
    .product-item {
        float: left;
        width: 200px;
        margin: 10px 15px;
        border: 1px solid #ddd;
        padding: 10px;
        text-align: center;
        background: #fff;
        transition: box-shadow 0.3s;
    }
    .product-item:hover { box-shadow: 0 2px 10px rgba(0,0,0,0.15); }
    .product-item img { width: 160px; height: 120px; object-fit: cover; }
    .product-item .name { color: #2d8cf0; font-weight: bold; margin: 8px 0; font-size: 14px; }
    .product-item .info { color: #666; font-size: 12px; margin: 4px 0; }
    .product-item .price { color: #e4393c; font-size: 16px; font-weight: bold; }
    .product-item .btn { display: inline-block; margin-top: 8px; padding: 5px 15px; background: #2d8cf0; color: #fff; text-decoration: none; border-radius: 3px; font-size: 12px; }
    .product-item .btn:hover { background: #1a6ed8; }
</style>
</head>
<body>
<div class="header">
    <h1>🛒 购物商城</h1>
    <div class="user-info">
        <% if (session.getAttribute("user") != null) { %>
            欢迎，<%= ((po.User)session.getAttribute("user")).getUsername() %>！
            <a href="CartServlet?operation=showCart">🛒 购物车</a>
            <a href="OrderServlet?operation=showUsersOrders">📋 我的订单</a>
            <a href="login.jsp?action=logout">退出</a>
        <% } else { %>
            <a href="login.jsp">登录</a>
            <a href="register.jsp">注册</a>
        <% } %>
    </div>
</div>

<div style="padding: 0 30px;">
    <h2 style="border-bottom: 2px solid #2d8cf0; padding-bottom: 10px;">全部商品</h2>
    <div class="product-grid">
    <%
        GoodsDao goodsDao = new GoodsDao();
        List<Goods> goodsList = goodsDao.findAll();
        for (Goods good : goodsList) {
    %>
        <div class="product-item">
            <a href="goodDetail.jsp?id=<%=good.getId()%>">
                <img src="images/<%=good.getPicture()%>" alt="<%=good.getName()%>">
            </a>
            <div class="name"><%=good.getName()%></div>
            <div class="info">产地：<%=good.getCity()%></div>
            <div class="price">¥<%=good.getPrice()%></div>
            <a class="btn" href="CartServlet?operation=add&id=<%=good.getId()%>">加入购物车</a>
        </div>
    <%
        }
    %>
    </div>
</div>
</body>
</html>