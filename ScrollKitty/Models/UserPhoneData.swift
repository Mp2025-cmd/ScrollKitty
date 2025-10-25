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
