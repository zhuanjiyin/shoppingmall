package servlet;

import java.io.IOException;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import po.*;
import service.OrderService;
import util.IdUtils;

public class OrderServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String operation = request.getParameter("operation");
        if ("genOrders".equals(operation)) {
            genOrders(request, response);
        } else {
            showUsersOrders(request, response);
        }
    }

    private void showUsersOrders(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            request.setAttribute("message", "请先登录！<meta http-equiv='Refresh' content='2;URL="
                + request.getContextPath() + "/login.jsp'>");
            request.getRequestDispatcher("/message.jsp").forward(request, response);
            return;
        }
        OrderService oService = new OrderService();
        List<Orders> userOrders = oService.findOrdersByUserId(user.getId());
        request.setAttribute("UserOrders", userOrders);
        request.getRequestDispatcher("/orderList.jsp").forward(request, response);
    }

    private void genOrders(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            request.setAttribute("message", "请先登录！<meta http-equiv='Refresh' content='2;URL="
                + request.getContextPath() + "/login.jsp'>");
            request.getRequestDispatcher("/message.jsp").forward(request, response);
            return;
        }
        Cart cart = (Cart) session.getAttribute("cart");
        if (cart == null || cart.getItems().isEmpty()) {
            request.setAttribute("message", "购物车为空，无法提交订单！");
            request.getRequestDispatcher("/message.jsp").forward(request, response);
            return;
        }

        String ordersId = IdUtils.genId();
        Orders orders = new Orders();
        orders.setNum(cart.getNum());
        orders.setPrice(cart.getPrice());
        orders.setState(0);
        orders.setOrderId(ordersId);

        List<OrdersItem> ordersItems = new ArrayList<>();
        for (Map.Entry<Integer, CartItem> entry : cart.getItems().entrySet()) {
            CartItem cartItem = entry.getValue();
            OrdersItem orderItem = new OrdersItem();
            orderItem.setNum(cartItem.getNum());
            orderItem.setPrice(cartItem.getPrice());
            orderItem.setGood(cartItem.getGood());
            ordersItems.add(orderItem);
        }
        orders.setItems(ordersItems);

        OrderService oService = new OrderService();
        oService.addOrders(orders, user);
        session.removeAttribute("cart");

        request.setAttribute("message", "付款成功，请等待店家发货！<br/><a href='"
            + request.getContextPath() + "/OrderServlet?operation=showUsersOrders'>查看我的订单</a>");
        request.getRequestDispatcher("/message.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}