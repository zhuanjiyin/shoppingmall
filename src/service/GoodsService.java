package service;

import java.util.List;
import dao.GoodsDao;
import po.Goods;

public class GoodsService {
    private GoodsDao goodsDao = new GoodsDao();

    public List<Goods> findAll() {
        return goodsDao.findAll();
    }

    public Goods findById(int id) {
        return goodsDao.findById(id);
    }

    public List<Goods> getGoodsByIds(String ids) {
        return goodsDao.getGoodsByIds(ids);
    }
}