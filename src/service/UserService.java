package service;

import dao.UserDao;
import po.User;

public class UserService {
    private UserDao userDao = new UserDao();

    public User login(String username, String password) {
        return userDao.login(username, password);
    }

    public boolean register(User user) {
        if (userDao.existUsername(user.getUsername())) {
            return false;
        }
        return userDao.register(user);
    }
}