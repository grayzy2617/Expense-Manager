package Model.BO;
import java.time.LocalDateTime;

public class Item {
    public String itemId;
    public String userId;
    public String categoryId;
    public double amount;
    public String description;
    public LocalDateTime createdAt;

    // Thuộc tính phụ (không lưu trong bảng items, lấy từ bảng categories qua lệnh JOIN)
    public String categoryName;

    // Các Constructor cũ giữ nguyên...
    public Item(String itemId, String userId, String categoryId, double amount, String describe, LocalDateTime createdAt) {
        this.itemId = itemId;
        this.userId = userId;
        this.categoryId = categoryId;
        this.amount = amount;
        this.description = describe;
        this.createdAt = createdAt;
    }

    public Item(String categoryId, double amount, String description, LocalDateTime createdAt) {
        this.categoryId = categoryId;
        this.amount = amount;
        this.description = description;
        this.createdAt = createdAt;
    }
    public Item(){}

    // ... (Giữ nguyên các Getter/Setter cũ)

    // Thêm Getter/Setter cho categoryName
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    // ... (Giữ nguyên phần còn lại)
    public String getItemId() { return itemId; }
    public void setItemId(String itemId) { this.itemId = itemId; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getCategoryId() { return categoryId; }
    public void setCategoryId(String categoryId) { this.categoryId = categoryId; }
    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }
    public String getDescribe() { return description; }
    public void setDescribe(String describe) { this.description = describe; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}