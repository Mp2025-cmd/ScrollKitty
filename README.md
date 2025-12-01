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

#### 1. **Active Shielding System (Brain Rot Core Loop)**
- **Architecture:** "Active Blocking" strategy for 100% reliability (bypasses iOS 26 Monitor bugs).
- **Monitor Extension (`ScrollKittyMonitor`):** 
  - Applies immediate shields to selected apps upon monitoring start.
  - Tracks intervals and manages `ManagedSettingsStore`.
- **Shield Configuration (`ScrollKittyShield`):**
  - Custom "Scroll Kitty says NO!" blocking screen.
  - "Ignore for 15m (-10 Health)" button logic.
- **Shield Action (`ScrollKittyAction`):**
  - Handles "Unlock" interaction.
  - **Penalizes Health:** Drops cat health by 10% per unlock.
  - **Notifications:** Sends "Cat is Sick!" alerts immediately.
  - **Unblocking:** Temporarily unblocks app for 15 minutes.
- **Data Flow:** Extensions write `catHealthPercentage` / `catStage` to App Group UserDefaults -> Main App reads and updates UI.

#### 2. **Onboarding Flow (21 Screens)**
All onboarding screens are managed by `OnboardingFeature` using stack-based navigation:

**Initial Survey (8 screens):**
- **Splash Screen** - Auto-advance after 2 seconds (intro animation)
- **Welcome Screen** - Introduction with cat mascot
- **Usage Question** - Daily phone hours selection (3hrs → 12hrs+)
- **Addiction Assessment** - "Do you feel addicted to your phone?" (Not at all → Yes)
- **Sleep Impact** - "Does phone use interfere with your sleep?" (Never → Almost every night)
- **Without Phone** - "How do you feel without your phone?" (Totally fine → Very anxious)
- **Idle Check** - "How often do you check your phone when idle?" (Rarely → Every few minutes)
- **Age Selection** - User age range (Under 18 → 55+)

**Results & Analysis (4 screens):**
- **Results Loading** - Circular progress ring with Gen Z captions
- **Results** - Personalized addiction summary
- **Addiction Score** - Bar graph comparing user vs recommended usage
- **Years Lost** - Shows estimated years lost to screen time

**Solution Setup (9 screens):**
- **Solution Intro** - Introduction to Scroll Kitty solution
- **Screen Time Access** - Request Screen Time permissions
- **App Selection** - FamilyActivityPicker for apps to block
- **Daily Limit** - Set daily usage limit (3-8 hours)
- **Shield Frequency** - Set shield re-application interval
- **Focus Window** - Configure active protection hours
- **Character Intro** - Meet Scroll Kitty mascot
- **Lifecycle Carousel** - 5 health states (Healthy → Dead)
- **Commitment** - Final pledge to take back control

#### 3. **Navigation System**
- **Simplified AppFeature** - Only 2 destinations: `onboarding` and `home`
- **OnboardingFeature** - Stack-based navigation with `StackState` managing all 21 onboarding screens
- **Self-contained navigation** - OnboardingFeature owns its complete flow, delegating only `.onboardingComplete` to AppFeature
- **Back button support** - Full backward navigation throughout onboarding
- **Type safety** - Impossible to show multiple screens or invalid states

#### 4. **Results Loading & Analysis**
- **Circular Progress Ring** - 3 concentric circles with percentage counter
- **Dynamic Gen Z Captions** - Rotating every 1.5 seconds
- **Results Screen** - Personalized addiction score display
- **Addiction Score Screen** - Bar graph comparing user vs population average
- **Years Lost Screen** - Shows "17 years" of life lost to screens

#### 5. **Screen Time Integration**
- **Permission Request Screen** - System-style UI requesting Screen Time access
- **App Selection Screen** - FamilyActivityPicker for selecting apps/categories to track
- **Daily Limit Screen** - Set daily limit (3-8 hours)
- **Flow Order** - Follows Apple guidelines: educate → request → configure

#### 6. **Character Introduction & Lifecycle**
- **Character Intro Screen** - Introduces "Scroll Kitty" mascot
- **Lifecycle Carousel** - 5 health states (Healthy → Dead)
- **Interactive Features** - Page control dots, state-specific colors

#### 7. **Commitment Screen**
- **Ready to Take Back Control** - Final onboarding step with commitment pledge
- **Interactive Checkbox** - Custom checkbox with checkmark icon
- **TCA Binding Pattern** - Uses `BindableAction` and `@Bindable`

#### 8. **Home/Dashboard Screen**
- **Real-Time Dashboard** - Displays live Cat Health (Healthy/Sick/Dead)
- **Health Percentage** - Updates dynamically based on Shield usage
- **Color-Coded Progress Bar** - Visual feedback (Green → Red)
- **Background Polling** - Updates every 30 seconds to fetch extension data

#### 9. **Timeline View**
- **Vertical Timeline** - Blue line with cat dashboard icons
- **Chat-Style Cards** - Messages from Scroll Kitty about app usage
- **Cat State Integration** - Uses `CatState` enum for images and colors

#### 10. **Technical Implementation**
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
├── ScrollKittyMonitor/ (New)
│   └── DeviceActivityMonitorExtension.swift
├── ScrollKittyShield/ (New)
│   └── ShieldConfigurationExtension.swift
├── ScrollKittyAction/ (New)
│   └── ShieldActionExtension.swift
└── Services/
    ├── ScreenTimeManager.swift
    ├── UserSettingsManager.swift
    └── CatHealthManager.swift
```

### Key TCA Patterns
- **Simplified root navigation** - AppFeature manages only 2 destinations (onboarding/home)
- **Stack-based child navigation** - OnboardingFeature uses `StackState<Path.State>` for 21 screens
- **Delegate pattern** - Child features communicate via delegate actions (e.g., `.onboardingComplete`)
- **Feature + View co-location** - Each screen has paired Feature + View files
- **Dependency injection** - `@Dependency` for Screen Time & Settings managers
- **App Group sharing** - UserDefaults for main app ↔ extension communication

## 📊 Data & Statistics
- **Gen Z (18-24):** 8.5 hours/day average
- **Millennials (25-30):** 7.2 hours/day average

## 🎨 Design Philosophy
ScrollKitty uses a **friendly confrontation** approach - delivering hard truths about phone addiction through a cute, non-judgmental cat mascot.

---

## ⚠️ PREVIOUS BLOCKER: DeviceActivityReport Extension (RESOLVED)

**Resolution:**
We pivoted from the passive "Report Extension" approach (which was sandboxed and couldn't write data) to an **Active Shielding Architecture**.
- **Old Approach:** Try to read usage from `DeviceActivityReport` (Blocked by Apple privacy).
- **New Approach:** Use `ShieldActionExtension` to capture "Unlock" events.
  - User unlocks app -> Extension runs -> Deducts Health -> Updates Main App.
  - This bypasses the "iOS 26 Monitor Bug" by relying on user interaction triggers.

**Status:** ✅ Fixed. Core loop is functional.

## 📝 Next Tasks (Lives + Timed Shields)

1.  **Update Daily Limit Logic:**
    - Map Daily Limit (3h, 4h, etc.) to **Cat Lives** (5, 7, etc.) instead of raw Health Cost.
    - Update `DailyLimitView` and `DailyLimitFeature`.
2.  **Update Shield Logic (`ShieldConfigurationExtension`):**
    - Implement logic to check **Focus Window** (Time & Day).
    - Implement logic to check **Shield Cooldown** (is shield active?).
    - Display remaining **Lives** on the shield.
3.  **Update Bypass Action (`ShieldActionExtension`):**
    - Deduct **1 Life** per bypass.
    - Set **Cooldown Expiration** (Now + Frequency).
    - Unblock app temporarily.
4.  **Re-Shielding Reliability:**
    - Implement mechanism to re-block apps after cooldown expires (using `DeviceActivityMonitor` or Main App check).
