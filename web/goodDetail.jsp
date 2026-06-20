<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.GoodsDao, po.Goods, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>商品详情</title>
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
    .header a { color: #fff; float: right; line-height: 40px; text-decoration: none; }
    .container { width: 900px; margin: 30px auto; background: #fff; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); overflow: hidden; }
    .detail { display: flex; padding: 30px; }
    .detail img { width: 300px; height: 240px; object-fit: cover; border: 1px solid #eee; }
    .detail .info { margin-left: 30px; flex: 1; }
    .detail .info h2 { margin: 0 0 15px; font-size: 20px; }
    .detail .info p { margin: 8px 0; color: #666; font-size: 14px; }
    .detail .info .price { color: #e4393c; font-size: 24px; font-weight: bold; }
    .detail .info .btn {
        display: inline-block;
        margin-top: 15px;
        padding: 10px 30px;
        background: #e4393c;
        color: #fff;
        text-decoration: none;
        border-radius: 4px;
        font-size: 16px;
    }
    .detail .info .btn:hover { background: #c62e2e; }
    .history { padding: 20px 30px; border-top: 1px solid #eee; }
    .history h3 { margin-bottom: 15px; }
    .history-item {
        display: inline-block;
        width: 180px;
        margin: 5px 10px;
        padding: 8px;
        border: 1px solid #eee;
        text-align: center;
        vertical-align: top;
    }
    .history-item img { width: 120px; height: 90px; }
    .history-item .hname { font-size: 12px; color: #2d8cf0; margin: 5px 0; }
    .history-item .hprice { font-size: 12px; color: #e4393c; }
</style>
</head>
<body>
<div class="header">
    <h1>🛒 购物商城</h1>
    <a href="index.jsp">返回首页</a>
</div>
<%
    int goodsId = Integer.parseInt(request.getParameter("id"));
    GoodsDao goodsDao = new GoodsDao();
    Goods good = goodsDao.findById(goodsId);

    if (good == null) {
        out.println("<div style='text-align:center;padding:50px;'>商品不存在</div>");
        return;
    }

    // Cookie 记录浏览历史
    String cookieName = "viewedGoods";
    String viewed = "";
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie c : cookies) {
            if (cookieName.equals(c.getName())) {
                viewed = c.getValue();
                break;
            }
        }
    }
    List<String> idList = new ArrayList<>(Arrays.asList(viewed.split(",")));
    idList.removeIf(String::isEmpty);
    idList.remove(String.valueOf(goodsId));
    idList.add(0, String.valueOf(goodsId));
    if (idList.size() > 5) idList = idList.subList(0, 5);
    String newViewed = String.join(",", idList);
    Cookie cookie = new Cookie(cookieName, newViewed);
    cookie.setMaxAge(60 * 60 * 24 * 7);
    response.addCookie(cookie);
%>
<div class="container">
    <div class="detail">
        <img src="images/<%=good.getPicture()%>" alt="<%=good.getName()%>">
        <div class="info">
            <h2><%=good.getName()%></h2>
            <p>产地：<%=good.getCity()%></p>
            <p>库存：<%=good.getNumber()%> 件</p>
            <p class="price">¥<%=good.getPrice()%></p>
            <a class="btn" href="CartServlet?operation=add&id=<%=good.getId()%>">加入购物车</a>
        </div>
    </div>

    <div class="history">
        <h3>您最近浏览过的商品</h3>
        <%
            if (!newViewed.isEmpty()) {
                List<Goods> historyGoods = goodsDao.getGoodsByIds(newViewed);
                for (Goods hg : historyGoods) {
        %>
            <div class="history-item">
                <a href="goodDetail.jsp?id=<%=hg.getId()%>">
                    <img src="images/<%=hg.getPicture()%>" alt="<%=hg.getName()%>">
                </a>
                <div class="hname"><%=hg.getName()%></div>
                <div class="hprice">¥<%=hg.getPrice()%></div>
            </div>
        <%
                }
            }
        %>
    </div>
</div>
</body>
</html>