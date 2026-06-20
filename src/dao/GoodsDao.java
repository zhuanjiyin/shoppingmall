package dao;

import java.sql.*;
import java.util.*;
import po.Goods;
import util.DButil;

public class GoodsDao {

    public List<Goods> findAll() {
        Connection conn = DButil.getConn();
        PreparedStatement pst = null;
        ResultSet rs = null;
        List<Goods> goods = new ArrayList<>();
        try {
            String sql = "SELECT * FROM items ORDER BY id";
            pst = conn.prepareStatement(sql);
            rs = pst.executeQuery();
            while (rs.next()) {
                Goods good = new Goods(rs.getInt("id"), rs.getString("name"),
                    rs.getString("city"), rs.getInt("price"),
                    rs.getInt("number"), rs.getString("picture"));
                goods.add(good);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DButil.closeAll(conn, pst, rs);
        }
        return goods;
    }

    public List<Goods> find(Integer id, String name, String city) {
        Connection conn = DButil.getConn();
        PreparedStatement pst = null;
        ResultSet rs = null;
        List<Goods> goods = new ArrayList<>();
        String sql = "SELECT * FROM items WHERE 1=1";
        if (id != null) sql += " AND id=?";
        if (name != null) sql += " AND name=?";
        if (city != null) sql += " AND city=?";
        try {
            pst = conn.prepareStatement(sql);
            int idx = 1;
            if (id != null) pst.setInt(idx++, id);
            if (name != null) pst.setString(idx++, name);
            if (city != null) pst.setString(idx++, city);
            rs = pst.executeQuery();
            while (rs.next()) {
                Goods good = new Goods(rs.getInt("id"), rs.getString("name"),
                    rs.getString("city"), rs.getInt("price"),
                    rs.getInt("number"), rs.getString("picture"));
                goods.add(good);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DButil.closeAll(conn, pst, rs);
        }
        return goods;
    }

    public Goods findById(Integer id) {
        Connection conn = DButil.getConn();
        PreparedStatement pst = null;
        ResultSet rs = null;
        Goods good = null;
        try {
            String sql = "SELECT * FROM items WHERE id=?";
            pst = conn.prepareStatement(sql);
            pst.setInt(1, id);
            rs = pst.executeQuery();
            if (rs.next()) {
                good = new Goods(rs.getInt("id"), rs.getString("name"),
                    rs.getString("city"), rs.getInt("price"),
                    rs.getInt("number"), rs.getString("picture"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DButil.closeAll(conn, pst, rs);
        }
        return good;
    }

    public List<Goods> getGoodsByIds(String ids) {
        List<Goods> list = new ArrayList<>();
        if (ids == null || ids.isEmpty()) return list;
        Connection conn = DButil.getConn();
        PreparedStatement pst = null;
        ResultSet rs = null;
        try {
            String[] arr = ids.split(",");
            StringBuilder sql = new StringBuilder("SELECT * FROM items WHERE id IN (");
            for (int i = 0; i < arr.length; i++) sql.append("?,");
            sql.deleteCharAt(sql.length() - 1);
            sql.append(")");
            pst = conn.prepareStatement(sql.toString());
            for (int i = 0; i < arr.length; i++) pst.setInt(i + 1, Integer.parseInt(arr[i].trim()));
            rs = pst.executeQuery();
            while (rs.next()) {
                Goods good = new Goods(rs.getInt("id"), rs.getString("name"),
                    rs.getString("city"), rs.getInt("price"),
                    rs.getInt("number"), rs.getString("picture"));
                list.add(good);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DButil.closeAll(conn, pst, rs);
        }
        return list;
    }
}