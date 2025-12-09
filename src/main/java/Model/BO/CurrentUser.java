package Model.BO;

public class CurrentUser {
    private static CurrentUser instance;
    public String userId;
    public String username;
    public String password;
    public String createdAt;
     public static CurrentUser getInstance(){
         if(instance==null){
             instance=new CurrentUser();
         }
       return instance;
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
    public void setPassword(String password) {
         this.password = password;
    }
    public String getCreatedAt() {
         return createdAt;
    }
    public void setCreatedAt(String createdAt) {
         this.createdAt = createdAt;
    }
}

