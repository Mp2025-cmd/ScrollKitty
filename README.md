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

#### 1. **Onboarding Flow (7 Steps)**
- **Splash Screen** - Auto-advance after 2 seconds (intro animation)
- **Welcome Screen** - Introduction with cat mascot
- **Usage Question** - Daily phone hours selection (3hrs → 12hrs+)
- **Addiction Assessment** - "Do you feel addicted to your phone?" (Not at all → Yes)
- **Sleep Impact** - "Does phone use interfere with your sleep?" (Never → Almost every night)
- **Without Phone** - "How do you feel without your phone?" (Totally fine → Very anxious)
- **Idle Check** - "How often do you check your phone when idle?" (Rarely → Every few minutes)
- **Age Selection** - User age range (Under 18 → 55+)

#### 2. **Navigation System**
- **Enum-based destination pattern** - Type-safe state machine (single source of truth)
- **OnboardingFeature** - Stack-based navigation with `StackState` for 7-step flow
- **AppFeature** - Enum destination for post-onboarding screens (12 destinations)
- **Back button support** - Full backward navigation throughout app
- **Type safety** - Impossible to show multiple screens or invalid states

#### 3. **Results Loading Screen**
- **Circular Progress Ring** - 3 concentric circles with percentage counter
- **Dynamic Gen Z Captions** - Rotating every 1.5 seconds:
  - "calculating how cooked your brain is..."
  - "checking your dopamine damage..."
  - "measuring your scroll addiction..."
  - "analyzing your digital detox needs..."
  - "computing your phone dependency..."
  - "evaluating your screen time chaos..."
  - "processing your doomscroll data..."
  - "calculating your FOMO levels..."
  - "measuring how chronically online you are..."
  - "checking if you're terminally online..."
- **10-second duration** with smooth progress animation
- **"Analyzing..." title** with Sofia Pro Bold typography

#### 4. **Results & Analysis Screens**
- **Results Loading Screen** - 10-second analysis with Gen Z captions and circular progress
- **Results Screen** - Personalized addiction score display
- **Addiction Score Screen** - Bar graph comparing user vs population average with "guilt trip" messaging
- **Years Lost Screen** - Shows "17 years" of life lost to screens (red emphasis)
- **Solution Intro Screen** - Introduces Scroll Kitty as the solution

#### 5. **Screen Time Integration**
- **Permission Request Screen** - System-style UI requesting Screen Time access with Face ID
- **App Selection Screen** - FamilyActivityPicker for selecting apps/categories to track
- **Daily Limit Screen** - Set daily limit (3-8 hours) with clean pill-button UI
- **Permission Handling** - Graceful denial handling with "Open Settings" option
- **Flow Order** - Follows Apple guidelines: educate → request → configure

#### 6. **Character Introduction & Lifecycle**
- **Character Intro Screen** - Introduces "Scroll Kitty" mascot with cheerful cat image
- **Scroll Kitty Lifecycle Carousel** - Horizontal scrollable cards showing 5 health states:
  - Healthy (green) - Happy, energetic
  - Slightly Sick (cyan) - Getting concerned  
  - Sick (blue) - Tired and needs rest
  - Extremely Sick (orange) - Very sick from overuse
  - Dead (red) - Passed away from neglect
- **Interactive Features** - Page control dots, state-specific colors, rounded square containers, ellipse indicators

#### 7. **Commitment Screen**
- **Ready to Take Back Control** - Final onboarding step with commitment pledge
- **Interactive Checkbox** - Custom checkbox with checkmark icon and toggle switch
- **Four Commitments** - Light blue box with bullet points:
  - Guarding my focus and attention
  - Building healthier digital habits
  - Reclaiming my time from the scroll
  - Protecting Scroll Kitty as I protect my mind
- **TCA Binding Pattern** - Uses `BindableAction` and `@Bindable` for two-way state binding
- **Toggle Button** - iOS-style toggle switch (gray → green) with smooth spring animation
- **Continue Button** - Only appears after user commits (taps "I'm ready to commit!")

#### 8. **Screen Time Integration & App Configuration**
- **Screen Time Access Screen** - Face ID permission request with Apple-style UI
- **App Selection Screen** - FamilyActivityPicker for selecting apps/categories to track
- **Daily Limit Screen** - User selects limit (3-8 hours) with OptionSelector pattern
- **Permission Denial Handling** - Alert with "Open Settings" when denied (blocks progress)
- **Data Persistence** - Saves selections to App Group UserDefaults for extension access
- **Flow Order** - Follows Apple guidelines: educate → permission → configure

#### 9. **Cat Health System (Core Game Loop)**
- **UserSettingsManager** - TCA dependency for App Group persistence
  - Saves/loads selected apps (FamilyActivitySelection)
  - Saves/loads daily limit (minutes)
  - Reads `todayTotal` from App Group (shared with extension)
- **CatHealthManager** - TCA dependency for health calculations
  - Formula: `health = 100 - (usedMinutes / limitMinutes * 100)`
  - Returns cat stage based on health thresholds
  - Midnight reset logic with date checking
- **Real-Time Dashboard**
  - Loads cat health on appear
  - Displays real screen time from UserDefaults
  - Dynamic cat image (healthy → dead based on usage)
  - Color-coded progress bar (green → cyan → blue → orange → red)
  - 30-second polling for live updates
  - Cancellable background effects

#### 10. **Home/Dashboard Screen**
- **Scroll Kitty Title** - Centered app name
- **Cat Display** - Real-time health state with dynamic image
- **Health Percentage** - Live calculation based on usage vs limit
- **Color-Coded Progress Bar** - Visual feedback on health status
- **Screen Time Display** - Formatted time (e.g., "1h 25m") from real data
- **Background Polling** - Updates every 30 seconds while active
- **TCA-Compliant TabBar** - Dashboard and Timeline tabs
  - `HomeFeature` reducer co-located in `HomeView.swift`
  - `BindableAction` with `BindingReducer` for tab selection
  - Dependency injection for health and settings managers

#### 11. **Timeline View**
- **Vertical Timeline** - Blue line (#BBDBFF) with cat dashboard icons
- **Chat-Style Cards** - Messages from Scroll Kitty about app usage
- **Cat State Integration** - Uses `CatState` enum for images and colors
- **Color-Coded Backgrounds** - Progressively darker blues as cat gets sicker
- **Date Headers** - "Jan 1 • Monday" format with blue dots
- **AttributedString Messages** - Colored highlights for time amounts (cyan, orange, red)
- **Cat Images** - Positioned on right side of cards (133x120)
- **Timestamps** - Light blue (#BBDBFF) time labels

#### 12. **CatState Enum**
- **Centralized Cat Management** - Single source of truth for all cat states
- **5 Health States**: healthy, concerned, tired, sick, dead
- **Properties**: images, colors, display names, health levels
- **Helper Methods**: `from(screenTimeHours:)`, `from(percentage:)`
- **Nested HealthLevel Enum** - Descriptions for each state
- **Timeline Integration** - Background colors, time colors, icon colors

#### 13. **Design System**
- **Colors:** Primary blue (#015AD7), light blue (#BBDBFF), grays, black/white
- **Typography:** Sofia Pro font family with proper weight variants
- **Components:** Reusable buttons, progress indicators, option selectors, back buttons
- **Spacing:** Consistent padding and margins throughout

#### 14. **User Data Collection**
- Hour selection (3hrs or less → 12hrs+)
- Addiction level (Not at all → Yes)
- Sleep interference (Never → Almost every night)
- Phone dependency (Totally fine → Very anxious)
- Idle checking frequency (Rarely → Every few minutes)
- Age range (Under 18 → 55+)
- All data stored in AppFeature state for results calculation

## 🔮 Planned Features (Post-Lifecycle Screen)

### 1. **Main App Dashboard**
- **Daily Usage Overview** - Real-time screen time tracking
- **Cat Mood System** - Scroll Kitty's emotional state based on usage
- **Progress Tracking** - Daily/weekly usage monitoring
- **Streaks & Achievements** - Gamified reduction goals

### 2. **Screen Time Integration**
- **Native iOS Screen Time API** - Real usage data collection
- **App Blocking** - Custom blocking rules and schedules
- **Focus Modes** - Custom focus sessions with cat rewards
- **Usage Analytics** - Detailed breakdowns by app category

### 3. **Advanced Features**
- **AI Insights** - Machine learning for usage patterns
- **Custom Notifications** - Smart reminders
- **Integration** - Calendar, productivity apps
- **Analytics** - Detailed usage breakdowns

## 🛠️ Technical Implementation

### File Structure
```
ScrollKitty/
├── Features/
│   ├── App/
│   │   └── AppFeature.swift (Root coordinator)
│   └── Onboarding/
│       └── OnboardingFeature.swift (Navigation coordinator)
├── Views/
│   ├── Onboarding/
│   │   ├── SplashView.swift
│   │   ├── WelcomeView.swift
│   │   ├── UsageQuestionView.swift
│   │   ├── AddictionView.swift
│   │   ├── SleepView.swift
│   │   ├── WithoutPhoneView.swift
│   │   ├── IdleCheckView.swift
│   │   ├── AgeView.swift
│   │   ├── CommitmentView.swift (contains CommitmentFeature)
│   │   ├── OnboardingView.swift (contains OnboardingFeature)
│   │   ├── ResultsLoadingView.swift
│   │   ├── ResultsView.swift
│   │   ├── AddictionScoreView.swift
│   │   ├── YearsLostView.swift
│   │   ├── SolutionIntroView.swift
│   │   ├── CharacterIntroView.swift
│   │   ├── ScrollKittyLifecycleView.swift
│   │   └── ScreenTimeAccessView.swift
│   ├── Home/
│   │   ├── HomeView.swift (contains HomeFeature + HomeTab enum)
│   │   └── TimelineView.swift
│   └── Components/
│       ├── PrimaryButton.swift
│       ├── ProgressIndicator.swift
│       ├── OptionSelector.swift
│       ├── BackButton.swift
│       ├── ScrollKittyCard.swift
│       ├── PageControl.swift
│       ├── ProgressBar.swift
│       ├── TabBar.swift
│       └── CatShadow.swift
├── Models/
│   ├── UserPhoneData.swift
│   ├── ScrollKittyState.swift
│   └── CatState.swift (enum with 5 states + HealthLevel)
├── Services/
│   ├── ScreenTimeManager.swift (TCA dependency for DeviceActivity)
│   ├── UserSettingsManager.swift (TCA dependency for App Group persistence)
│   └── CatHealthManager.swift (TCA dependency for health calculations)
├── Enums/
│   └── OnboardingOptions.swift (all multiple-choice enums)
├── Features/
│   ├── App/
│   │   └── AppFeature.swift (root navigation coordinator)
│   └── Onboarding/
│       └── OnboardingFeature.swift (onboarding flow coordinator - co-located in Views/Onboarding/)
├── Assets.xcassets/
│   ├── Cat Images/ (1_Healthy_Cheerful through 5_Tombstone_Dead)
│   ├── Ellipse 3.imageset/ (commitment checkmark background)
│   └── Layer_1.imageset/ (commitment checkmark icon)
├── DesignSystem.swift
├── ContentView.swift
└── ScrollKittyApp.swift
```

**Note:** Features are co-located with their views where appropriate. `HomeFeature` is embedded in `HomeView.swift`, while `AppFeature` and `OnboardingFeature` remain as standalone coordinator files.

### Key TCA Patterns
- **Enum-based navigation** - `Destination` enum for type-safe, single-source-of-truth navigation (AppFeature)
- **Stack-based navigation** - `StackState<Path.State>` for multi-step flows (OnboardingFeature)
- **Feature + View co-location** - `HomeFeature` embedded in `HomeView.swift` for simple features
- **Coordinator pattern** - AppFeature manages 13 destinations with enum state machine
- **Delegate pattern** - Child features communicate with parents via `.delegate(Delegate)` actions
- **Dependency injection** - Custom TCA dependencies for screen time, health, and settings
  - `@Dependency(\.screenTimeManager)` - DeviceActivity integration
  - `@Dependency(\.userSettings)` - App Group persistence
  - `@Dependency(\.catHealth)` - Health calculation engine
- **App Group sharing** - UserDefaults suite for main app ↔ extension communication
- **TabBar navigation** - `BindableAction` with `BindingReducer` for tab selection
- **Observable state** - `@ObservableState` for SwiftUI integration
- **Bindable state** - `BindableAction` with `@Bindable` for two-way bindings
- **Effect.run** - Async/await effects with proper error handling
- **Cancellable effects** - Background polling with `CancelID` enum
- **Timer effects** - `continuousClock.timer()` for 30-second health updates
- **Effect composition** - `.merge()` for parallel effects (load + start polling)

## 📊 Data & Statistics

### Screen Time Benchmarks
- **Gen Z (18-24):** 8.5 hours/day average
- **Millennials (25-30):** 7.2 hours/day average
- **Combined 18-30:** ~8 hours/day baseline

### Calculation Logic
User responses are weighted and compared against these benchmarks to generate personalized addiction scores and recommendations.

## 🎨 Design Philosophy

ScrollKitty uses a **friendly confrontation** approach - delivering hard truths about phone addiction through a cute, non-judgmental cat mascot. The app balances:

- **Honesty** - Direct feedback about addiction levels
- **Humor** - Gen Z slang and playful language
- **Support** - Constructive solutions, not just criticism
- **Personality** - Cat mascot that reacts to user behavior

## ⚠️ CURRENT BLOCKER: DeviceActivityReport Extension Not Firing

### Implementation Summary
We implemented a `DeviceActivityReportExtension` to track screen time for selected apps only (no websites). The extension should process Apple's `DeviceActivityResults`, sum usage for selected apps, and write to App Group UserDefaults for the main app to read.

### Architecture

```
┌─────────────────────────────────────────────────────┐
│ HomeView (Main App)                                 │
│ ├─ Hidden DeviceActivityReport view                │
│ └─ Reads: selectedTotalSecondsToday from UserDefaults│
└─────────────────────────────────────────────────────┘
                     ↓ triggers
┌─────────────────────────────────────────────────────┐
│ ScrollKittyReport Extension (ExtensionKit)          │
│ ├─ makeConfiguration() receives DeviceActivityData │
│ ├─ Filters only selected app tokens                │
│ ├─ Sums totalActivityDuration                      │
│ └─ Writes: selectedTotalSecondsToday, lastActivityUpdate│
└─────────────────────────────────────────────────────┘
                     ↓ shares via
┌─────────────────────────────────────────────────────┐
│ App Group: group.com.scrollkitty.app                │
│ Keys: selectedApps, selectedTotalSecondsToday       │
└─────────────────────────────────────────────────────┘
```

### Files Created

**ScrollKittyReport Extension:**
- `ScrollKittyReport.swift` - Entry point with `@main` attribute
- `DailyUsageReport.swift` - DeviceActivityReportScene implementation
  - Reads selected apps from App Group UserDefaults
  - Iterates `DeviceActivityResults<DeviceActivityData>`
  - Filters apps by token match
  - Returns `UsageData(totalSeconds: Double)`
- `DailyUsageReportView.swift` - Writes to UserDefaults on appear/change
- `Info.plist` - Uses `EXAppExtensionAttributes` with `com.apple.deviceactivityui.report-extension`
- `ScrollKittyReport.entitlements` - Family Controls + App Groups

**Configuration:**
- Product type: `com.apple.product-type.extensionkit-extension`
- File wrapper: `wrapper.extensionkit-extension`
- Embed: `Embed ExtensionKit Extensions` with `dstSubfolderSpec = 16`
- Target dependencies: Added to main ScrollKitty app

### Main App Integration

**HomeView.swift:**
- Added `DeviceActivityReport(.daily, filter: filter)` hidden view
- Filter: Daily segment, selected apps/categories only, NO webDomains
- Updated health calculation to read from `selectedTotalSecondsToday`
- Health formula: `100 - min(1, used/limit) × 100`

**UserSettingsManager.swift:**
- Changed from `NSKeyedArchiver` to `JSONEncoder` for FamilyActivitySelection
- Consistent encoding across main app and extension

**Entitlements:**
- Added App Groups to both main app and extension
- Shared container: `group.com.scrollkitty.app`

### What's NOT Working

**Extension never fires:**
```
Expected logs (MISSING):
[ScrollKittyReport] makeConfiguration called
[ScrollKittyReport] Tracking X selected apps
[ScrollKittyReport] ✅ Wrote Xs to UserDefaults

Actual logs:
[AppFeature] ⚠️ No apps selected - monitoring will start after app selection
[HomeFeature] Read 0.0s (0m) from selectedTotalSecondsToday (apps only)
```

**Symptoms:**
1. Extension logs never appear in console
2. `selectedTotalSecondsToday` always reads `0.0`
3. Hidden DeviceActivityReport view renders (confirmed in code)
4. Apps ARE selected during onboarding (verified logs before encoding fix)
5. App Groups capability enabled on both targets

### What We've Tried

1. ✅ **Correct product type** - ExtensionKit extension (matches ScreenBreak)
2. ✅ **Info.plist** - Uses `EXAppExtensionAttributes` (not NSExtension)
3. ✅ **@main attribute** - ScrollKittyReport struct marked as entry point
4. ✅ **App Groups** - Added to both main app and extension entitlements
5. ✅ **Encoding consistency** - Changed to JSONEncoder/Decoder everywhere
6. ✅ **Hidden report** - DeviceActivityReport embedded in HomeView with filter
7. ✅ **Daily filter** - Uses `.daily(during:)` segment
8. ✅ **Apps only** - `webDomains: []` to exclude Safari/Chrome
9. ✅ **Embed phase** - Correct ExtensionKit embedding with dstSubfolderSpec 16
10. ✅ **Clean reinstall** - Deleted app, cleaned build, fresh install

### Encoding Issue (RESOLVED)

**Problem:** UserSettingsManager saved with `NSKeyedArchiver` but extension/HomeView read with `JSONDecoder`

**Solution:** Changed UserSettingsManager to use `JSONEncoder`/`JSONDecoder` consistently

**Status:** Fixed in UserSettingsManager.swift:22-38, but extension still doesn't fire

### Current Hypothesis

**Possible causes:**
1. Extension needs real app usage (not just selection) to trigger for the first time
2. Daily filter requires 24 hours before first invocation
3. Missing runtime permission or capability in Xcode project settings
4. DeviceActivityReport view isn't actually triggering extension despite rendering
5. App Group permissions issue on physical device (despite showing in capabilities)

### Reference Implementation

**ScreenBreak (working):**
- Product type: `com.apple.product-type.extensionkit-extension` ✅ Same
- Info.plist: `EXAppExtensionAttributes` ✅ Same
- Entitlements: Family Controls only (NO App Groups) ❌ Different
- Extension writes: NO - only displays in-place ❌ Different

**Key difference:** ScreenBreak doesn't write to UserDefaults from extension. They only display data in DeviceActivityReport view itself.

### Questions for Reviewer

1. Is writing to App Group UserDefaults from DeviceActivityReportExtension actually blocked? (Apple DTS said it's sandboxed)
2. Should we use DeviceActivityMonitor with interval events instead?
3. Does the hidden DeviceActivityReport actually trigger makeConfiguration(), or does it need to be visible?
4. Is there a way to force the extension to fire for testing?
5. Are there any Xcode project settings we're missing (beyond capabilities)?

### Debug Logs Location

**Extension logs:** Should appear in Xcode console with `[ScrollKittyReport]` prefix
**Main app logs:** `[HomeFeature]`, `[UserSettings]`, `[AppFeature]`

## 🚀 Next Steps

### **Immediate Priorities (To Complete Core Loop):**

1. **UserSettingsManager** - Persist selected apps + daily limit to App Group UserDefaults
2. **DeviceActivityMonitor Extension** - Background monitoring to collect real screen time data
3. **CatHealthManager** - Calculate cat health from screen time (100% → 0% drain logic)
4. **HomeView Integration** - Display real data, update cat image based on health
5. **Background Refresh** - Poll UserDefaults when app is active for real-time updates

### **Post-MVP Features:**

6. **Timeline Messaging** - Threshold-triggered messages when cat health drops
7. **AI-Generated Messages** - Sarcastic cat commentary (on-device or template-based)
8. **Midnight Reset** - Cat revives daily, usage resets
9. **Focus Sessions** - Timer-based app blocking with cat rewards
10. **Advanced Analytics** - Weekly/monthly usage trends and insights

---

*ScrollKitty: Because sometimes you need a cat to tell you you're chronically online* 🐱📱
