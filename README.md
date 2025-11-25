# ScrollKitty 🐱

**A Screen Time Management App with Personality**

ScrollKitty is a SwiftUI app built with The Composable Architecture (TCA) that helps users understand and manage their phone addiction through a personalized, cat-themed experience.

## 🎯 Project Overview

ScrollKitty takes users on a journey of self-discovery about their phone usage habits. The app uses a friendly cat mascot to deliver personalized insights about screen time addiction, making the often uncomfortable topic of digital wellness more approachable and engaging.

## 🏗️ Architecture

- **Framework:** SwiftUI + The Composable Architecture (TCA)
- **Navigation:** Enum-based destination pattern with type-safe state machine
- **State Management:** TCA reducers with `@ObservableState` and dependency injection
- **Design System:** Centralized design tokens in `DesignSystem.swift`
- **Font:** Sofia Pro (Bold, Medium, Regular variants)
- **Screen Time API:** DeviceActivity, FamilyControls, ManagedSettings frameworks
- **Data Persistence:** App Group UserDefaults for main app ↔ extension communication

## 📱 Current Implementation

### ✅ Completed Features

#### 1. **Active Shielding System (Per-App HP + Timed Shields)**
- **Core Loop:** "Hardcore" mode where bypassing shields costs HP from that specific app.
- **Per-App Health System:**
  - Cat has **100 HP total** shared across all selected apps (max 10 apps).
  - Each app gets equal HP allocation: `100 HP ÷ number of apps`.
  - Each bypass costs **10 HP** from that specific app only.
  - Global Cat Health = Sum of all app HPs.
  - **0 Global HP** = Cat Dies + **Hard Lock on ALL apps** (No bypass button).
- **Timed Shields (Cooldown):**
  - User selects Shield Frequency (e.g., 15 min).
  - Bypassing unblocks the app for that duration.
  - Local notifications prompt re-shielding.
- **Focus Window:**
  - User defines specific Hours & Days for protection.
- **Extensions:**
  - `ScrollKittyShield`: Displays per-app HP (e.g., "Instagram: 15/25 HP | Total: 70 HP") or "Dead" shield.
  - `ScrollKittyAction`: Handles "Continue" tap -> Deducts 10 HP from specific app -> Unblocks App -> Sets Timer.
  - Uses Swift **Actors** for thread-safe cross-extension communication.

#### 2. **Onboarding Flow (9 Steps)**
- **Splash Screen** - Auto-advance after 2 seconds (intro animation)
- **Welcome Screen** - Introduction with cat mascot
- **Usage Question** - Daily phone hours selection
- **Addiction Assessment** - "Do you feel addicted?"
- **Sleep Impact** - "Does it affect sleep?"
- **Without Phone** - "Anxiety check"
- **Idle Check** - "Check frequency"
- **Age Selection** - User demographics
- **Configuration Phase:**
  - **App Selection:** FamilyActivityPicker with **10-app maximum** (enforced with live counter)
  - **Daily Limit:** User awareness setting (3-8 hours) - HP system is consistent across all limits
  - **Shield Frequency:** Cooldown timer (10-60 min)
  - **Focus Window:** Active hours & days

#### 3. **Navigation System**
- **Enum-based destination pattern** - Type-safe state machine (single source of truth)
- **OnboardingFeature** - Stack-based navigation for assessment
- **AppFeature** - Enum destination for configuration screens
- **Back button support** - Full backward navigation

#### 4. **Results Loading & Analysis**
- **Circular Progress Ring** - 3 concentric circles
- **Dynamic Captions** - Rotating every 1.5 seconds
- **Results Screen** - Personalized addiction score
- **Addiction Score Screen** - Bar graph comparison
- **Years Lost Screen** - "17 years lost" visualization

#### 5. **Home/Dashboard Screen**
- **Real-Time Dashboard** - Displays live Cat Health & Stage
- **Health Percentage** - Calculated as sum of all app HPs
- **Per-App Health Breakdown** - Shows individual app HP allocations
- **Visual Feedback** - Progress bar changes color (Green → Red)
- **Background Polling** - Updates automatically
- **Automatic Migration** - Converts old lives-based data to HP system on first launch

#### 6. **Timeline View**
- **Vertical Timeline** - Chat-style usage updates from Scroll Kitty

#### 7. **Technical Implementation**
- **Framework:** SwiftUI + The Composable Architecture (TCA)
- **Persistence:** App Group UserDefaults (`group.com.scrollkitty.app`)
- **Screen Time API:** DeviceActivity, FamilyControls, ManagedSettings
- **Extensions:**
  - `ScrollKittyMonitor` (Device Activity Monitor)
  - `ScrollKittyShield` (Shield Configuration)
  - `ScrollKittyAction` (Shield Action)

## 🔮 Planned Features (Post-Lifecycle Screen)

### 1. **Main App Dashboard**
- **Daily Usage Overview** - Real-time screen time tracking
- **Cat Mood System** - Scroll Kitty's emotional state based on usage
- **Progress Tracking** - Daily/weekly usage monitoring
- **Streaks & Achievements** - Gamified reduction goals

### 2. **Advanced Features**
- **AI Insights** - Machine learning for usage patterns
- **Custom Notifications** - Smart reminders
- **Integration** - Calendar, productivity apps

## 🛠️ Technical Implementation

### File Structure
```
ScrollKitty/
├── Features/
│   ├── App/
│   │   └── AppFeature.swift
│   └── Onboarding/
│       └── OnboardingFeature.swift
├── Views/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── TimelineView.swift
│   └── Onboarding/
│       └── ... (Onboarding Views)
├── ScrollKittyMonitor/
│   └── DeviceActivityMonitorExtension.swift
├── ScrollKittyShield/
│   └── ShieldConfigurationExtension.swift
├── ScrollKittyAction/
│   └── ShieldActionExtension.swift
└── Services/
    ├── ScreenTimeManager.swift
    ├── UserSettingsManager.swift
    ├── CatHealthManager.swift
    └── AppHealthManager.swift (Per-app health data + thread-safe actor)
```

### Key TCA Patterns
- **Enum-based navigation**
- **Stack-based navigation**
- **Feature + View co-location**
- **Dependency injection** for Screen Time & Settings
- **App Group sharing** for Extension communication
- **Modern Concurrency (2024+):**
  - Async/await instead of Combine
  - Swift Actors for thread-safe UserDefaults access
  - `.run` effects for async operations
  - Atomic health updates to prevent race conditions

## 📊 Data & Statistics
- **Gen Z (18-24):** 8.5 hours/day average
- **Millennials (25-30):** 7.2 hours/day average

## 🎨 Design Philosophy
ScrollKitty uses a **friendly confrontation** approach - delivering hard truths about phone addiction through a cute, non-judgmental cat mascot.

---

## ⚠️ PREVIOUS BLOCKER: DeviceActivityReport Extension (RESOLVED)

**Resolution:**
We pivoted from the passive "Report Extension" approach to an **Active Shielding Architecture**.
- **Old Approach:** Try to read usage from `DeviceActivityReport` (Blocked by Apple privacy).
- **New Approach:** Use `ShieldActionExtension` to capture "Unlock" events.
  - User unlocks app -> Extension runs -> Deducts Lives -> Updates Main App.
  - This bypasses the "iOS 26 Monitor Bug" by relying on user interaction triggers.

**Status:** ✅ Fixed. Core loop is functional.

---

## ✅ RESOLVED: Token Identifier Mismatch

### Problem
Per-app health tracking was not working correctly. All apps mapped to the same dictionary key because `String(describing: ApplicationToken)` produces a non-unique string.

### Root Cause
`"ApplicationToken(data: 128 bytes)"` is identical for all apps when converted to String directly.

### Fix Applied
We switched to using **Base64-encoded token data** as the unique identifier:
```swift
guard let tokenData = try? JSONEncoder().encode(token) else { return }
let tokenId = tokenData.base64EncodedString()
```
This ensures every app has a unique, stable key for health tracking and shield configuration.

### Files Updated
1. `UserSettingsManager.swift` - `initializeAppHealth` closure
2. `ShieldActionExtension.swift` - `handleBypassForApp` method
3. `ShieldConfigurationExtension.swift` - `configuration(shielding:)` methods

---

## 🚨 Critical Issues (To Fix)

### 1. Shield Persists During Cooldown
- **Symptom:** After tapping "Continue" and unlocking the app, the shield (or a generic system shield) remains visible or reappears immediately, blocking access to the app.
- **Cause:** The `ShieldActionExtension` is failing to successfully remove the app from `ManagedSettingsStore`, or the `DeviceActivityMonitor` is aggressively re-applying it.

### 2. Re-Shielding Reliability
- **Symptom:** After the cooldown period expires, the shield does not reliably return to block the app again.
- **Cause:** Lack of a reliable trigger (like `DeviceActivitySchedule` update) to wake up the extension and re-apply the block.

### 3. Notifications Not Appearing
- **Symptom:** The "Lost 10 HP" and "Shield Returning" notifications are not showing up.
- **Cause:** Likely missing Notification permissions or authorization request in the main app flow.

### 4. Health Deduction Verification
- **Status:** Needs verification. Logs indicate deductions happen, but the broken shield UX makes it hard to confirm visually.
