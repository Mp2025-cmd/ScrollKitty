//
//  OnboardingOptions.swift
//  ScrollKitty
//
//  Enums for multiple choice options in onboarding screens
//

import Foundation

// MARK: - Daily Usage Hours
enum HourOption: String, CaseIterable, Equatable {
    case threeOrLess = "3hrs or less"
    case threeToFive = "3hrs - 5hrs"
    case sixToEight = "6hrs - 8hrs"
    case nineToEleven = "9hrs - 11hrs"
    case twelveOrMore = "12hrs+"
}

// MARK: - Addiction Level
enum AddictionOption: String, CaseIterable, Equatable, RawRepresentable {
    case yes = "Yes"
    case often = "Often"
    case sometimes = "Sometimes"
    case rarely = "Rarely"
    case notAtAll = "Not at all"
}

// MARK: - Sleep Impact
enum SleepOption: String, CaseIterable, Equatable, RawRepresentable {
    case almostEveryNight = "Almost every night"
    case fewTimesWeek = "A few times a week"
    case rarely = "Rarely"
    case never = "Never"
}

// MARK: - Phone Anxiety
enum WithoutPhoneOption: String, CaseIterable, Equatable, RawRepresentable {
    case veryAnxious = "Very anxious"
    case littleUneasy = "A little uneasy"
    case mostlyFine = "Mostly fine"
    case totallyFine = "Totally fine"
}

// MARK: - Idle Check Frequency
enum IdleCheckOption: String, CaseIterable, Equatable, RawRepresentable {
    case everyFewMinutes = "Every few minutes"
    case everyHour = "Every hour"
    case fewTimesDay = "A few times a day"
    case rarely = "Rarely"
}

// MARK: - Age Group
enum AgeOption: String, CaseIterable, Equatable, RawRepresentable {
    case under18 = "under 18"
    case age18to24 = "18 - 24yrs"
    case age25to34 = "25 - 34yrs"
    case age35to44 = "35 - 44yrs"
    case age45to54 = "45 - 54yrs"
    case age55plus = "55+yrs"
}
