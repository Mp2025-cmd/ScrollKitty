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
