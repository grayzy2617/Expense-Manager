package Model.BO;

import java.time.LocalDateTime;

public class Saving extends Category {
    // Các thuộc tính kế thừa từ Category:
    // categoryId, userId, name, limitAmount (đóng vai trò là Mục tiêu tiết kiệm - Target Amount)

    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private double savedAmount; // Số tiền hiện có (tính toán từ Item)
    private boolean status;     // true: Ongoing, false: Finished
    private boolean viewInReport;

    public Saving() {
        super();
        this.setType("SAVING"); // Mặc định type là SAVING
    }

    // Constructor đầy đủ
    public Saving(String userId, String name, Double targetAmount,
                  LocalDateTime startDate, LocalDateTime endDate, boolean viewInReport) {
        super(userId, name, "SAVING", targetAmount); // Gọi constructor của Category
        this.startDate = startDate;
        this.endDate = endDate;
        this.viewInReport = viewInReport;
        this.status = true; // Mặc định là đang diễn ra
    }

    // Getters & Setters
    public LocalDateTime getStartDate() { return startDate; }
    public void setStartDate(LocalDateTime startDate) { this.startDate = startDate; }

    public LocalDateTime getEndDate() { return endDate; }
    public void setEndDate(LocalDateTime endDate) { this.endDate = endDate; }

    public double getSavedAmount() { return savedAmount; }
    public void setSavedAmount(double savedAmount) { this.savedAmount = savedAmount; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }

    public boolean isViewInReport() { return viewInReport; }
    public void setViewInReport(boolean viewInReport) { this.viewInReport = viewInReport; }

    // Helper để tính phần trăm hoàn thành
    public int getProgressPercent() {
        if (this.getLimitAmount() == null || this.getLimitAmount() == 0) return 0;
        int p = (int) ((this.savedAmount / this.getLimitAmount()) * 100);
        return p > 100 ? 100 : p;
    }
}