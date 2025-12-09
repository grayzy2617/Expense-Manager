package Model.BO;

public class User {
    public String userId;
    public String username;
    public String password;
    public String createdAt;

    public User(String id, String username, String password) {
        this.userId = id;
        this.username = username;
        this.password = password;
    }
  public String getUserId() {
        return userId;
    }
    public void setUserId(String userId) {
        this.userId = userId;
    }
    public String getUsername() {
        return username;
    }
    public void setUsername(String username) {
        this.username = username;
    }
    public String getPassword() {
        return password;
    }
    public void setPassword(String password)
    {
        this.password = password;
    }
    public String getCreatedAt() {
        return createdAt;
    }
    public void setCreatedAt(String createdAt) {}
}

