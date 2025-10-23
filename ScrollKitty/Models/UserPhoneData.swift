//
//  UserPhoneData.swift
//  ScrollKitty
//
//  Data models for user phone usage analysis
//

import Foundation

// MARK: - User Phone Data
struct UserPhoneData: Equatable {
    let dailyHours: Double
    let addictionLevel: AddictionFeature.AddictionOption
    let sleepImpact: SleepFeature.SleepOption
    let withoutPhoneAnxiety: WithoutPhoneFeature.WithoutPhoneOption
    let idleCheckFrequency: IdleCheckFeature.IdleCheckOption
    let ageGroup: AgeFeature.AgeOption
}

// MARK: - Population Averages (GUILT TRIP VERSION)
struct PopulationAverages {
    // GUILT TRIP: Make population averages MUCH lower to make users feel terrible
    static let genZMillennial: Double = 1.2 // Was 3.5 - now 65% lower!
    static let genX: Double = 0.8 // Was 2.8 - now 70% lower!
    static let boomer: Double = 0.6 // Was 2.1 - now 70% lower!
}
