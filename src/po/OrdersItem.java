package po;

public class OrdersItem {
    private String id;
    private int num;
    private float price;
    private int goodId;
    private Goods good;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public int getNum() { return num; }
    public void setNum(int num) { this.num = num; }
    public float getPrice() { return price; }
    public void setPrice(float price) { this.price = price; }
    public int getGoodId() { return goodId; }
    public void setGoodId(int goodId) { this.goodId = goodId; }
    public Goods getGood() { return good; }
    public void setGood(Goods good) { this.good = good; }
}