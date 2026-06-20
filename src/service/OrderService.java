package service;

import java.util.List;
import dao.OrderDao;
import po.*;

public class OrderService {
    private OrderDao orderDao = new OrderDao();

    public void addOrders(Orders orders, User user) {
        orderDao.addOrders(orders, user);
    }

    public List<Orders> findOrdersByUserId(int userId) {
        return orderDao.findOrdersByUserId(userId);
    }
}