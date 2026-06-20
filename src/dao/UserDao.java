package dao;

import java.sql.*;
import po.User;
import util.DButil;

public class UserDao {

    public User findByUsername(String username) {
        Connection conn = DButil.getConn();
        PreparedStatement pst = null;
        ResultSet rs = null;
        User user = null;
        try {
            String sql = "SELECT * FROM user WHERE username=?";
            pst = conn.prepareStatement(sql);
            pst.setString(1, username);
            rs = pst.executeQuery();
            if (rs.next()) {
                user = new User(rs.getInt("id"), rs.getString("username"),
                    rs.getString("password"), rs.getString("email"),
                    rs.getString("phone"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DButil.closeAll(conn, pst, rs);
        }
        return user;
    }

    public User login(String username, String password) {
        Connection conn = DButil.getConn();
        PreparedStatement pst = null;
        ResultSet rs = null;
        User user = null;
        try {
            String sql = "SELECT * FROM user WHERE username=? AND password=?";
            pst = conn.prepareStatement(sql);
            pst.setString(1, username);
            pst.setString(2, password);
            rs = pst.executeQuery();
            if (rs.next()) {
                user = new User(rs.getInt("id"), rs.getString("username"),
                    rs.getString("password"), rs.getString("email"),
                    rs.getString("phone"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DButil.closeAll(conn, pst, rs);
        }
        return user;
    }

    public boolean register(User user) {
        Connection conn = DButil.getConn();
        PreparedStatement pst = null;
        try {
            String sql = "INSERT INTO user (username, password, email, phone) VALUES (?,?,?,?)";
            pst = conn.prepareStatement(sql);
            pst.setString(1, user.getUsername());
            pst.setString(2, user.getPassword());
            pst.setString(3, user.getEmail());
            pst.setString(4, user.getPhone());
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DButil.closeAll(conn, pst, null);
        }
    }

    public boolean existUsername(String username) {
        Connection conn = DButil.getConn();
        PreparedStatement pst = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT COUNT(*) FROM user WHERE username=?";
            pst = conn.prepareStatement(sql);
            pst.setString(1, username);
            rs = pst.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DButil.closeAll(conn, pst, rs);
        }
        return false;
    }
}