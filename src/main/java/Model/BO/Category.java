package Model.BO;

import java.awt.*;

public class Category {
    public String categoryId;
    public String userId;
    public String name;
    public String type;        // "INCOME" hoặc "EXPENSE" (có thể dùng ENUM trong DB)
    public String image;
    public double totalAmount;
    public Double limitAmount;
    public Category(String categoryId, String userId, String name, String type) {
        this.categoryId = categoryId;
        this.userId = userId;
        this.name = name;
        this.type = type;
    }
    public Category( String userId, String name, String type, double limitAmount) {
        this.userId = userId;
        this.name = name;
        this.type = type;
        this.limitAmount = limitAmount;
    }
    public  Category(String categoryId, String userId, String name, String type, double limitAmount) {
        this.categoryId = categoryId;
        this.userId = userId;
        this.name = name;
        this.type = type;
        this.limitAmount = limitAmount;
    }
    public Category() {
    }

    // Getter và Setter cho categoryId
    public String getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(String categoryId) {
        this.categoryId = categoryId;
    }

    // Getter và Setter cho userId
    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    // Getter và Setter cho name
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    // Getter và Setter cho type
    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    // Getter và Setter cho image
    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }
    public Double getLimitAmount() {
        return limitAmount;
    }
    public void setLimitAmount(Double limitAmount) {
        this.limitAmount = limitAmount;
    }



}
