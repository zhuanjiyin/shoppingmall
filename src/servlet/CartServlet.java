package servlet;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.http.*;
import po.*;
import service.GoodsService;

public class CartServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String operation = request.getParameter("operation");
        if (operation == null) operation = "showCart";

        switch (operation) {
            case "add":
                addCart(request, response);
                break;
            case "remove":
                removeCart(request, response);
                break;
            case "clear":
                clearCart(request, response);
                break;
            default:
                showCart(request, response);
                break;
        }
    }

    private void showCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/cart.jsp").forward(request, response);
    }

    private void addCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            request.setAttribute("message", "请先登录，再添加购物车！<meta http-equiv='Refresh' content='2;URL="
                + request.getContextPath() + "/login.jsp'>");
            request.getRequestDispatcher("/message.jsp").forward(request, response);
            return;
        }

        int goodsId = Integer.parseInt(request.getParameter("id"));
        GoodsService goodsService = new GoodsService();
        Goods goods = goodsService.findById(goodsId);

        Cart cart = (Cart) session.getAttribute("cart");
        if (cart == null) {
            cart = new Cart();
        }
        cart.addGood(goods);
        session.setAttribute("cart", cart);
        response.sendRedirect(request.getContextPath() + "/CartServlet?operation=showCart");
    }

    private void removeCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Cart cart = (Cart) session.getAttribute("cart");
        if (cart != null) {
            int id = Integer.parseInt(request.getParameter("id"));
            cart.removeGood(id);
        }
        response.sendRedirect(request.getContextPath() + "/CartServlet?operation=showCart");
    }

    private void clearCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Cart cart = (Cart) session.getAttribute("cart");
        if (cart != null) {
            cart.clear();
        }
        response.sendRedirect(request.getContextPath() + "/CartServlet?operation=showCart");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}