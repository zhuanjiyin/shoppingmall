package dao;

import java.sql.*;
import java.util.*;
import po.*;
import util.DButil;

public class OrderDao {

    public void addOrders(Orders orders, User user) {
        Connection conn = DButil.getConn();
        PreparedStatement pst = null;
        ResultSet rs = null;
        try {
            conn.setAutoCommit(false);
            String sql = "INSERT INTO orders (orderId, num, price, state, user_id) VALUES (?,?,?,?,?)";
            pst = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pst.setString(1, orders.getOrderId());
            pst.setInt(2, orders.getNum());
            pst.setFloat(3, orders.getPrice());
            pst.setInt(4, orders.getState());
            pst.setInt(5, user.getId());
            pst.executeUpdate();
            rs = pst.getGeneratedKeys();
            if (rs.next()) {
                orders.setId(String.valueOf(rs.getInt(1)));
            }
            if (pst != null) pst.close();

            List<OrdersItem> items = orders.getItems();
            if (items != null && items.size() > 0) {
                String sql2 = "INSERT INTO ordersitem (num, price, orders_id, good_id) VALUES (?,?,?,?)";
                pst = conn.prepareStatement(sql2);
                for (OrdersItem item : items) {
                    pst.setInt(1, item.getNum());
                    pst.setFloat(2, item.getPrice());
                    pst.setInt(3, Integer.parseInt(orders.getId()));
                    pst.setInt(4, item.getGood().getId());
                    pst.executeUpdate();
                }
            }
            conn.commit();
        } catch (Exception e) {
            try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            DButil.closeAll(conn, pst, null);
        }
    }

    public List<Orders> findOrdersByUserId(int userId) {
        Connection conn = DButil.getConn();
        PreparedStatement pst = null;
        ResultSet rs = null;
        List<Orders> list = new ArrayList<>();
        try {
            String sql = "SELECT * FROM orders WHERE user_id=? ORDER BY orderId DESC";
            pst = conn.prepareStatement(sql);
            pst.setInt(1, userId);
            rs = pst.executeQuery();
            while (rs.next()) {
                Orders order = new Orders();
                order.setId(rs.getString("id"));
                order.setOrderId(rs.getString("orderId"));
                order.setNum(rs.getInt("num"));
                order.setState(rs.getInt("state"));
                order.setPrice(rs.getFloat("price"));
                order.setUserId(rs.getInt("user_id"));
                list.add(order);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DButil.closeAll(conn, pst, rs);
        }
        return list;
    }
}