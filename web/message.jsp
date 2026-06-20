<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>提示信息</title>
<link rel="stylesheet" type="text/css" href="css/main.css">
<style>
    body { background: #f5f5f5; }
    .msg-box {
        width: 500px;
        margin: 100px auto;
        background: #fff;
        border-radius: 8px;
        box-shadow: 0 2px 15px rgba(0,0,0,0.1);
        padding: 40px;
        text-align: center;
    }
    .msg-box h2 { color: #2d8cf0; margin-bottom: 20px; }
    .msg-box p { color: #666; font-size: 16px; line-height: 1.8; }
    .msg-box a { color: #2d8cf0; text-decoration: none; }
</style>
</head>
<body>
<div class="msg-box">
    <h2>提示</h2>
    <p><%=request.getAttribute("message")%></p>
    <p><a href="index.jsp">返回首页</a></p>
</div>
</body>
</html>