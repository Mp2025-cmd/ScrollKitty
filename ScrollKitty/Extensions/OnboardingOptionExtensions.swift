//
//  OnboardingOptionExtensions.swift
//  ScrollKitty
//
//  Extensions for onboarding options to calculate addiction scores
//

import Foundation

// MARK: - Addiction Level Multiplier (GUILT TRIP VERSION)
extension AddictionFeature.AddictionOption {
    var multiplier: Double {
        switch self {
        case .yes: return 2.0 // Increased from 1.5
        case .often: return 1.7 // Increased from 1.3
        case .sometimes: return 1.4 // Increased from 1.1
        case .rarely: return 1.1 // Increased from 0.9
        case .notAtAll: return 0.9 // Increased from 0.7
        }
    }
}

// MARK: - Sleep Impact Multiplier (GUILT TRIP VERSION)
extension SleepFeature.SleepOption {
    var multiplier: Double {
        switch self {
        case .almostEveryNight: return 1.8 // Increased from 1.4
        case .fewTimesWeek: return 1.5 // Increased from 1.2
        case .rarely: return 1.2 // Increased from 1.0
        case .never: return 1.0 // Increased from 0.8
        }
    }
}

// MARK: - Without Phone Anxiety Multiplier (GUILT TRIP VERSION)
extension WithoutPhoneFeature.WithoutPhoneOption {
    var multiplier: Double {
        switch self {
        case .veryAnxious: return 1.8 // Increased from 1.4
        case .littleUneasy: return 1.5 // Increased from 1.2
        case .mostlyFine: return 1.2 // Increased from 1.0
        case .totallyFine: return 1.0 // Increased from 0.8
        }
    }
}

// MARK: - Idle Check Frequency Multiplier (GUILT TRIP VERSION)
extension IdleCheckFeature.IdleCheckOption {
    var multiplier: Double {
        switch self {
        case .everyFewMinutes: return 2.2 // Increased from 1.5
        case .everyHour: return 1.8 // Increased from 1.2
        case .fewTimesDay: return 1.4 // Increased from 1.0
        case .rarely: return 1.1 // Increased from 0.8
        }
    }
}

// MARK: - Daily Hours Conversion
extension UsageQuestionFeature.HourOption {
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

// MARK: - Population Average by Age
extension AgeFeature.AgeOption {
    var populationAverage: Double {
        switch self {
        case .under18, .age18to24, .age25to34: return PopulationAverages.genZMillennial
        case .age35to44: return PopulationAverages.genX
        case .age45to54, .age55plus: return PopulationAverages.boomer
        }
    }
}
