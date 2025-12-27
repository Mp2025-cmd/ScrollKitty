import Foundation

// MARK: - Weekday

enum Weekday: Int, CaseIterable, Codable, Equatable, Hashable {
    case sunday = 0
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6

    var shortName: String {
        switch self {
        case .sunday: return "S"
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        }
    }

    var fullName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
}

// MARK: - Blocking Preset

enum BlockingPreset: String, CaseIterable, Equatable {
    case morning = "In the morning"
    case work = "At work"
    case beforeBed = "Before bed"

    var emoji: String {
        switch self {
        case .morning: return "☀️"
        case .work: return "💼"
        case .beforeBed: return "🛏️"
        }
    }

    var defaultStartTime: DateComponents {
        switch self {
        case .morning:
            return DateComponents(hour: 6, minute: 0)
        case .work:
            return DateComponents(hour: 9, minute: 0)
        case .beforeBed:
            return DateComponents(hour: 21, minute: 0)
        }
    }

    var defaultEndTime: DateComponents {
        switch self {
        case .morning:
            return DateComponents(hour: 10, minute: 0)
        case .work:
            return DateComponents(hour: 12, minute: 0)
        case .beforeBed:
            return DateComponents(hour: 22, minute: 0)
        }
    }

    var displayName: String {
        switch self {
        case .morning: return "Morning Focus"
        case .work: return "Work Hours"
        case .beforeBed: return "Evening Wind Down"
        }
    }

    var defaultDays: Set<Weekday> {
        switch self {
        case .morning, .beforeBed:
            return Set(Weekday.allCases)
        case .work:
            return [.monday, .tuesday, .wednesday, .thursday, .friday]
        }
    }
}

// MARK: - Blocking Schedule

struct BlockingSchedule: Equatable, Codable {
    let id: UUID
    let name: String
    let emoji: String
    let startTime: Date
    let endTime: Date
    let selectedDays: Set<Weekday>
    let isEnabled: Bool

    init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        startTime: Date,
        endTime: Date,
        selectedDays: Set<Weekday>,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.startTime = startTime
        self.endTime = endTime
        self.selectedDays = selectedDays
        self.isEnabled = isEnabled
    }

    static func from(preset: BlockingPreset) -> BlockingSchedule {
        let calendar = Calendar.current
        let now = Date()

        let startTime = calendar.date(from: preset.defaultStartTime) ?? now
        let endTime = calendar.date(from: preset.defaultEndTime) ?? now

        return BlockingSchedule(
            name: preset.displayName,
            emoji: preset.emoji,
            startTime: startTime,
            endTime: endTime,
            selectedDays: preset.defaultDays
        )
    }
}
