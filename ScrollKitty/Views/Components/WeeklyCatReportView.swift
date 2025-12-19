import SwiftUI

struct WeeklyCatReportView: View {
    struct DayPresentation: Identifiable {
        let date: Date
        let weekdayLabel: String
        let dayNumberText: String
        let catState: CatState?
        let hasData: Bool
        let isFuture: Bool
        let isSelected: Bool
        
        var id: Date { date }
    }
    
    let title: String
    let subtitle: String
    let days: [DayPresentation]
    let canMoveBackward: Bool
    let canMoveForward: Bool
    let onSelectDay: (Date) -> Void
    let onPreviousWeek: () -> Void
    let onNextWeek: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            dayRow
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var header: some View {
        HStack(alignment: .center) {
            ChevronButton(direction: .left, isEnabled: canMoveBackward, action: onPreviousWeek)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.custom("Sofia Pro-Semi_Bold", size: 20))
                    .foregroundColor(DesignSystem.Colors.primaryText)
                Text(subtitle)
                    .font(.custom("Sofia Pro-Regular", size: 14))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            
            ChevronButton(direction: .right, isEnabled: canMoveForward, action: onNextWeek)
        }
    }
    
    private var dayRow: some View {
        HStack(spacing: 8) {
            ForEach(days) { day in
                Button {
                    onSelectDay(day.date)
                } label: {
                    DayPill(day: day)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct DayPill: View {
    let day: WeeklyCatReportView.DayPresentation
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 5) {
            Text(day.weekdayLabel)
                .font(.custom("Sofia Pro-Medium", size: 10))
                .foregroundColor(textColor)
                .textCase(.uppercase)

            dayImage
                .frame(width: 30, height: 30)

            Text(day.dayNumberText)
                .font(.custom("Sofia Pro-Semi_Bold", size: 13))
                .foregroundColor(textColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(pillBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: 2.5)
                .shadow(color: day.isSelected ? Color.black.opacity(0.15) : .clear, radius: 6, y: 4)
        )
        .scaleEffect(day.isSelected ? 1.04 : 1.0)
        .opacity(dayOpacity)
    }
    
    private var pillBackground: Color {
        guard let catState = day.catState else {
            // No data - use visible grey in both modes
            return Color(uiColor: .systemGray5)
        }

        let base = catState.backgroundColor
        return day.isFuture ? base.opacity(0.6) : base
    }

    private var textColor: Color {
        if day.catState != nil {
            // Has data - use white on blue backgrounds
            return .white
        } else {
            // No data - use adaptive text for grey background
            return Color(uiColor: .label)
        }
    }

    private var borderColor: Color {
        if !day.isSelected {
            return .clear
        }

        // Selected state border
        if day.catState != nil {
            // Has data - white border on blue
            return .white
        } else {
            // No data - use brand blue border on grey
            return DesignSystem.Colors.primaryBlue
        }
    }
    
    private var dayImage: some View {
        Group {
            if let state = day.catState {
                state.image
                    .resizable()
                    .scaledToFit()
                    .shadow(color: Color.black.opacity(0.2), radius: 4, y: 3)
            } else {
                Image("TabBar_Dashboard")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                    .padding(8)
            }
        }
        .opacity(day.hasData ? 1 : 0.65)
    }
    
    private var dayOpacity: Double {
        guard day.isFuture else { return 1 }
        return day.hasData ? 0.85 : 0.55
    }
}

private struct ChevronButton: View {
    enum Direction {
        case left
        case right

        var systemName: String {
            switch self {
            case .left: return "chevron.left"
            case .right: return "chevron.right"
            }
        }
    }

    let direction: Direction
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: direction.systemName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(uiColor: .secondaryLabel))
                .padding(8)
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.3)
        .disabled(!isEnabled)
    }
}

#Preview {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let days = (0..<7).compactMap { offset -> WeeklyCatReportView.DayPresentation? in
        guard let date = calendar.date(byAdding: .day, value: offset, to: calendar.startOfWeek(for: today)) else {
            return nil
        }
        let catState: CatState? = offset < 4 ? CatState.allCases[min(offset, CatState.allCases.count - 1)] : nil
        return .init(
            date: date,
            weekdayLabel: DateFormatter.shortWeekdayFormatter.string(from: date),
            dayNumberText: DateFormatter.dayNumberFormatter.string(from: date),
            catState: catState,
            hasData: catState != nil,
            isFuture: calendar.isDate(date, inSameDayAs: today) ? false : date > today,
            isSelected: offset == 2
        )
    }
    return WeeklyCatReportView(
        title: "Scroll Kitty Pulse",
        subtitle: "Jan 14 – Jan 20",
        days: days,
        canMoveBackward: true,
        canMoveForward: false,
        onSelectDay: { _ in },
        onPreviousWeek: {},
        onNextWeek: {}
    )
    .padding()
    .background(Color.gray.opacity(0.2))
}

extension DateFormatter {
    static let shortWeekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    static let dayNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
}
