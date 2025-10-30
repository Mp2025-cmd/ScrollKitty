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
    let addictionLevel: AddictionOption
    let sleepImpact: SleepOption
    let withoutPhoneAnxiety: WithoutPhoneOption
    let idleCheckFrequency: IdleCheckOption
    let ageGroup: AgeOption
}
