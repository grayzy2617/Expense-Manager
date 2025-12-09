package Model.BO;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class MonthRange {
    private int month;                // Tháng tương ứng (1-12)
    private LocalDateTime start;
    private LocalDateTime end;

    public MonthRange(int month, LocalDateTime start, LocalDateTime end) {
        this.month = month;
        this.start = start;
        this.end = end;
    }

    public int getMonth() {
        return month;
    }

    public LocalDateTime getStart() {
        return start;
    }

    public LocalDateTime getEnd() {
        return end;
    }

    @Override
    public String toString() {
        return "Tháng " + month + ": " + start + " → " + end;
    }

    public static List<MonthRange> generateCustomMonths(int startDay, int baseMonth, int targetMonth) {
        List<MonthRange> result = new ArrayList<>();
        int year = LocalDate.now().getYear();

        // Tính khoảng start/end của targetMonth dựa trên startDay/baseMonth
        LocalDate baseDate = LocalDate.of(year, baseMonth, startDay);

        // Tính offset để dịch sang targetMonth
        int monthOffset = targetMonth - baseMonth;
        LocalDate start = baseDate.plusMonths(monthOffset);
        LocalDate end = start.plusMonths(1).minusDays(1);

        // Tạo 12 tháng liên tiếp
        for (int i = 0; i < 12; i++) {
            LocalDate monthStart = start.plusMonths(i);
            LocalDate monthEnd = end.plusMonths(i);

            result.add(new MonthRange(
                    monthStart.getMonthValue(),
                    monthStart.atStartOfDay(),
                    monthEnd.atTime(23, 59, 59)
            ));
        }

        return result;
    }


}
