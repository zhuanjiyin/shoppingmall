<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>会员注册</title>
<link rel="stylesheet" type="text/css" href="css/main.css">
<style>
    body { background: #f5f5f5; }
    .reg-box {
        width: 450px;
        margin: 50px auto;
        background: #fff;
        border-radius: 8px;
        box-shadow: 0 2px 15px rgba(0,0,0,0.1);
        padding: 30px 40px;
    }
    .reg-box h2 { text-align: center; color: #333; margin-bottom: 25px; }
    .reg-box .form-group { margin-bottom: 16px; }
    .reg-box label { display: block; margin-bottom: 6px; color: #555; font-size: 14px; }
    .reg-box input[type="text"],
    .reg-box input[type="password"] {
        width: 100%;
        padding: 10px;
        border: 1px solid #ddd;
        border-radius: 4px;
        box-sizing: border-box;
        font-size: 14px;
    }
    .reg-box input:focus { border-color: #2d8cf0; outline: none; }
    .reg-box .btn {
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
    .reg-box .btn:hover { background: #1a6ed8; }
    .reg-box .tip { text-align: center; margin-top: 15px; font-size: 13px; }
    .reg-box .tip a { color: #2d8cf0; text-decoration: none; }
    .reg-box .error { color: #e4393c; text-align: center; margin-bottom: 15px; font-size: 14px; }
</style>
<script>
function validateForm() {
    var username = document.forms[0].username.value.trim();
    var password = document.forms[0].password.value;
    var repassword = document.forms[0].repassword.value;
    if (username === "") {
        alert("用户名不能为空！");
        return false;
    }
    if (password.length < 6) {
        alert("密码长度不能少于6位！");
        return false;
    }
    if (password !== repassword) {
        alert("两次输入的密码不一致！");
        return false;
    }
    var email = document.forms[0].email.value.trim();
    if (email !== "" && !/^\S+@\S+\.\S+$/.test(email)) {
        alert("邮箱格式不正确！");
        return false;
    }
    return true;
}
</script>
</head>
<body>
<div class="reg-box">
    <h2>会员注册</h2>
    <% String message = (String)request.getAttribute("message");
       if (message != null) { %>
        <div class="error"><%=message%></div>
    <% } %>
    <form action="RegisterServlet" method="post" onsubmit="return validateForm()">
        <div class="form-group">
            <label>用户名 *</label>
            <input type="text" name="username" placeholder="请输入用户名" required>
        </div>
        <div class="form-group">
            <label>密码 *</label>
            <input type="password" name="password" placeholder="请输入密码（至少6位）" required>
        </div>
        <div class="form-group">
            <label>确认密码 *</label>
            <input type="password" name="repassword" placeholder="请再次输入密码" required>
        </div>
        <div class="form-group">
            <label>邮箱</label>
            <input type="text" name="email" placeholder="请输入邮箱地址">
        </div>
        <div class="form-group">
            <label>手机号</label>
            <input type="text" name="phone" placeholder="请输入手机号">
        </div>
        <button type="submit" class="btn">注 册</button>
    </form>
    <div class="tip">已有账号？<a href="login.jsp">立即登录</a></div>
</div>
</body>
</html>
