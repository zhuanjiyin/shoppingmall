<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>会员登录</title>
<link rel="stylesheet" type="text/css" href="css/main.css">
<style>
    body { background: #f5f5f5; }
    .login-box {
        width: 400px;
        margin: 80px auto;
        background: #fff;
        border-radius: 8px;
        box-shadow: 0 2px 15px rgba(0,0,0,0.1);
        padding: 30px 40px;
    }
    .login-box h2 { text-align: center; color: #333; margin-bottom: 25px; }
    .login-box .form-group { margin-bottom: 18px; }
    .login-box label { display: block; margin-bottom: 6px; color: #555; font-size: 14px; }
    .login-box input[type="text"],
    .login-box input[type="password"] {
        width: 100%;
        padding: 10px;
        border: 1px solid #ddd;
        border-radius: 4px;
        box-sizing: border-box;
        font-size: 14px;
    }
    .login-box input[type="text"]:focus,
    .login-box input[type="password"]:focus { border-color: #2d8cf0; outline: none; }
    .login-box .btn {
        width: 100%;
        padding: 10px;
        background: #2d8cf0;
        color: #fff;
        border: none;
        border-radius: 4px;
        font-size: 16px;
        cursor: pointer;
        margin-top: 10px;
    }
    .login-box .btn:hover { background: #1a6ed8; }
    .login-box .tip { text-align: center; margin-top: 15px; font-size: 13px; }
    .login-box .tip a { color: #2d8cf0; text-decoration: none; }
    .login-box .error { color: #e4393c; text-align: center; margin-bottom: 15px; font-size: 14px; }
</style>
</head>
<body>
<%
    String action = request.getParameter("action");
    if ("logout".equals(action)) {
        session.invalidate();
        response.sendRedirect("login.jsp");
        return;
    }
%>
<div class="login-box">
    <h2>会员登录</h2>
    <% String message = (String)request.getAttribute("message");
       if (message != null) { %>
        <div class="error"><%=message%></div>
    <% } %>
    <form action="LoginServlet" method="post">
        <div class="form-group">
            <label>用户名</label>
            <input type="text" name="username" placeholder="请输入用户名" required>
        </div>
        <div class="form-group">
            <label>密　码</label>
            <input type="password" name="password" placeholder="请输入密码" required>
        </div>
        <button type="submit" class="btn">登 录</button>
    </form>
    <div class="tip">还没有账号？<a href="register.jsp">立即注册</a></div>
</div>
</body>
</html>