//
//  MonthCalendarView.swift
//  ScrollKitty
//
//  Full month calendar grid with cat state images
//

import SwiftUI

struct MonthCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    var dateHealthStates: [Date: Int] // Maps date -> health value
    let onDateSelected: (Date) -> Void
    let onMonthChanged: (Date) -> Void
    
    @State private var showingMonthPicker = false
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    var body: some View {
        VStack(spacing: 12) {
            // Month header with navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.primaryBlue)
                }
                .frame(width: 44, height: 44)
                
                Spacer()
                
                Button(action: { 
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showingMonthPicker.toggle()
                    }
                }) {
                    HStack(spacing: 6) {
                        Text(monthYearText)
                            .font(.custom("Sofia Pro-Medium", size: 18))
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        Image(systemName: showingMonthPicker ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.primaryBlue)
                    }
                }
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.primaryBlue)
                }
                .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 12)
            
            // Dropdown month/year picker (conditionally shown)
            if showingMonthPicker {
                MonthYearPickerView(currentMonth: $currentMonth, onDismiss: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showingMonthPicker = false
                    }
                    onMonthChanged(currentMonth)
                })
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
            
            // Day of week headers
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.custom("Sofia Pro-Regular", size: 11))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 8)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(calendarDates, id: \.self) { date in
                    CalendarCellView(
                        date: date,
                        isCurrentMonth: isInCurrentMonth(date),
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        healthValue: dateHealthStates[calendar.startOfDay(for: date)],
                        onTap: {
                            onDateSelected(date)
                        }
                    )
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 16)
        .background(DesignSystem.Colors.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Computed Properties
    
    private var monthYearText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var calendarDates: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else {
            return []
        }
        
        var dates: [Date] = []
        var currentDate = monthFirstWeek.start
        
        while currentDate <= monthLastWeek.end {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return dates
    }
    
    private func isInCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    // MARK: - Actions
    
    private func previousMonth() {
        guard let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) else { return }
        currentMonth = newMonth
        onMonthChanged(newMonth)
    }
    
    private func nextMonth() {
        guard let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) else { return }
        currentMonth = newMonth
        onMonthChanged(newMonth)
    }
}

// MARK: - Month/Year Picker View

private struct MonthYearPickerView: View {
    @Binding var currentMonth: Date
    let onDismiss: () -> Void
    
    @State private var selectedMonth: Int
    @State private var selectedYear: Int
    
    private let calendar = Calendar.current
    private let months = Calendar.current.monthSymbols
    private let years: [Int]
    
    init(currentMonth: Binding<Date>, onDismiss: @escaping () -> Void) {
        self._currentMonth = currentMonth
        self.onDismiss = onDismiss
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .year], from: currentMonth.wrappedValue)
        _selectedMonth = State(initialValue: components.month ?? 1)
        _selectedYear = State(initialValue: components.year ?? 2025)
        
        // Generate years from 2020 to 2030
        self.years = Array(2020...2030)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Done button bar
            HStack {
                Spacer()
                Button("Done") {
                    updateCurrentMonth()
                    onDismiss()
                }
                .font(.custom("Sofia Pro-Medium", size: 14))
                .foregroundColor(DesignSystem.Colors.primaryBlue)
                .padding(12)
            }
            .background(Color.white)
            
            Divider()
            
            // Custom month/year picker
            HStack(spacing: 0) {
                // Month picker
                Picker("Month", selection: $selectedMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text(months[month - 1])
                            .tag(month)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                
                // Year picker
                Picker("Year", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text(String(year))
                            .tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .frame(height: 200)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 12)
    }
    
    private func updateCurrentMonth() {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 1
        
        if let newDate = calendar.date(from: components) {
            currentMonth = newDate
        }
    }
}

// MARK: - Calendar Cell View

private struct CalendarCellView: View {
    let date: Date
    let isCurrentMonth: Bool
    let isSelected: Bool
    let healthValue: Int?
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                // Date number
                Text("\(calendar.component(.day, from: date))")
                    .font(.custom("Sofia Pro-Medium", size: 14))
                    .foregroundColor(textColor)
                
                // Cat state image
                if let health = healthValue, isCurrentMonth {
                    let catState = CatState.from(health: health)
                    Image(catState.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 38, height: 38)
                } else {
                    // Empty space to maintain consistent cell height
                    Color.clear
                        .frame(width: 38, height: 38)
                }
            }
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isCurrentMonth)
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return DesignSystem.Colors.secondaryText.opacity(0.3)
        }
        return isSelected ? DesignSystem.Colors.white : DesignSystem.Colors.primaryText
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return DesignSystem.Colors.primaryBlue
        }
        return Color.clear
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            MonthCalendarView(
                selectedDate: .constant(Date()),
                currentMonth: .constant(Date()),
                dateHealthStates: generateMockHealthStates(),
                onDateSelected: { _ in },
                onMonthChanged: { _ in }
            )
            .padding()
        }
    }
    .background(Color.gray.opacity(0.1))
}

// MARK: - Mock Data for Preview

private func generateMockHealthStates() -> [Date: Int] {
    let calendar = Calendar.current
    var states: [Date: Int] = [:]
    let today = Date()
    
    // Generate random health states for the past 20 days
    for dayOffset in -20...0 {
        guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
        let startOfDay = calendar.startOfDay(for: date)
        
        // Create a pattern: declining health
        let baseHealth = 100 - abs(dayOffset) * 3
        let randomVariation = Int.random(in: -10...10)
        let health = max(0, min(100, baseHealth + randomVariation))
        
        states[startOfDay] = health
    }
    
    return states
}
