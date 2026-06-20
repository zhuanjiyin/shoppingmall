package po;

import java.util.*;

public class Orders {
    private String id;
    private String orderId;
    private int num;
    private float price;
    private int state;
    private List<OrdersItem> items = new ArrayList<>();
    private int userId;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getOrderId() { return orderId; }
    public void setOrderId(String orderId) { this.orderId = orderId; }
    public int getNum() { return num; }
    public void setNum(int num) { this.num = num; }
    public float getPrice() { return price; }
    public void setPrice(float price) { this.price = price; }
    public int getState() { return state; }
    public void setState(int state) { this.state = state; }
    public List<OrdersItem> getItems() { return items; }
    public void setItems(List<OrdersItem> items) { this.items = items; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
}