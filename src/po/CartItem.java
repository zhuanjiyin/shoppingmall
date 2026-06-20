package po;

public class CartItem {
    private Goods good;
    private int num;
    private float price;

    public CartItem() {}

    public CartItem(Goods good, int num) {
        this.good = good;
        this.num = num;
        this.price = good.getPrice() * num;
    }

    public Goods getGood() { return good; }
    public void setGood(Goods good) { this.good = good; }
    public int getNum() { return num; }
    public void setNum(int num) { this.num = num; this.price = good.getPrice() * num; }
    public float getPrice() { return price; }
    public void setPrice(float price) { this.price = price; }
}