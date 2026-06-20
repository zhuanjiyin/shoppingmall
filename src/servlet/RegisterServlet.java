package servlet;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.http.*;
import po.User;
import service.UserService;

public class RegisterServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { 
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String repassword = request.getParameter("repassword");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");

        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            request.setAttribute("message", "用户名和密码不能为空！");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(repassword)) {
            request.setAttribute("message", "两次输入的密码不一致！");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        User user = new User();
        user.setUsername(username);
        user.setPassword(password);
        user.setEmail(email);
        user.setPhone(phone);

        UserService userService = new UserService();
        if (userService.register(user)) {
            request.setAttribute("message", "注册成功，请登录！<meta http-equiv='Refresh' content='2;URL="
                + request.getContextPath() + "/login.jsp'>");
            request.getRequestDispatcher("/message.jsp").forward(request, response);
        } else {
            request.setAttribute("message", "用户名已存在，请重新注册！");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }
}