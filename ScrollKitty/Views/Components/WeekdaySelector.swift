import SwiftUI

struct WeekdaySelector: View {
    @Binding var selectedDays: Set<Weekday>

    var body: some View {
        HStack(spacing: 12) {
            ForEach(Weekday.allCases, id: \.self) { day in
                WeekdayButton(
                    day: day,
                    isSelected: selectedDays.contains(day),
                    action: {
                        toggleDay(day)
                    }
                )
            }
        }
    }

    private func toggleDay(_ day: Weekday) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
}

// MARK: - Weekday Button

private struct WeekdayButton: View {
    let day: Weekday
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(day.shortName)
                .font(.custom("Sofia Pro-Medium", size: 16))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(isSelected ? DesignSystem.Colors.primaryBlue : DesignSystem.Colors.gray)
                )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("All Days Selected")
        WeekdaySelector(selectedDays: .constant(Set(Weekday.allCases)))

        Text("Weekdays Only")
        WeekdaySelector(selectedDays: .constant([.monday, .tuesday, .wednesday, .thursday, .friday]))

        Text("None Selected")
        WeekdaySelector(selectedDays: .constant([]))
    }
    .padding()
}
