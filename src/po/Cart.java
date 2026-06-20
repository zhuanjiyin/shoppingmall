package po;

import java.util.*;

public class Cart {
    private Map<Integer, CartItem> items = new LinkedHashMap<>();
    private int num;
    private float price;

    public void addGood(Goods good) {
        CartItem item = items.get(good.getId());
        if (item == null) {
            item = new CartItem(good, 1);
            items.put(good.getId(), item);
        } else {
            item.setNum(item.getNum() + 1);
        }
        recalculate();
    }

    public void removeGood(int id) {
        items.remove(id);
        recalculate();
    }

    public void clear() {
        items.clear();
        num = 0;
        price = 0;
    }

    public void recalculate() {
        num = 0;
        price = 0;
        for (CartItem item : items.values()) {
            num += item.getNum();
            price += item.getPrice();
        }
    }

    public Map<Integer, CartItem> getItems() { return items; }
    public void setItems(Map<Integer, CartItem> items) { this.items = items; }
    public int getNum() { return num; }
    public void setNum(int num) { this.num = num; }
    public float getPrice() { return price; }
    public void setPrice(float price) { this.price = price; }
}