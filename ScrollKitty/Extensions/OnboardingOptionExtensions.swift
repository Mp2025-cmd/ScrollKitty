//
//  OnboardingOptionExtensions.swift
//  ScrollKitty
//
//  Extensions for onboarding options to convert user selections to usable values
//

import Foundation

// MARK: - Daily Hours Conversion
extension HourOption {
    var dailyHours: Double {
        switch self {
        case .threeOrLess: return 2.5
        case .threeToFive: return 4.0
        case .sixToEight: return 7.0
        case .nineToEleven: return 10.0
        case .twelveOrMore: return 12.0
        }
    }
}

// MARK: - UserOnboardingProfile Mapping
extension SleepOption {
    var profileValue: String {
        switch self {
        case .almostEveryNight: return "significant"
        case .fewTimesWeek: return "some"
        case .rarely, .never: return "none"
        }
    }
}

extension IdleCheckOption {
    var profileValue: String {
        switch self {
        case .everyFewMinutes: return "constantly"
        case .everyHour: return "often"
        case .fewTimesDay: return "sometimes"
        case .rarely: return "rarely"
        }
    }
}

extension AgeOption {
    var profileValue: String {
        switch self {
        case .under18: return "13-17"
        case .age18to24: return "18-24"
        case .age25to34, .age35to44: return "25-34"
        case .age45to54, .age55plus: return "35+"
        }
    }
}
