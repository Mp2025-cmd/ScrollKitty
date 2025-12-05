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

#### 1. **Active Shielding System (Core Loop)**
- **Architecture:** "Active Blocking" strategy for 100% reliability.
- **Global Health Pool:** 100 HP starting, -5 HP per bypass, resets at midnight.
- **Global Cooldown:** User-selected interval (10/20/30/45/60 min). Shield only reappears after cooldown expires.
- **Dead Cat State:** At 0 HP, all apps locked until midnight (no bypass option).
- **Monitor Extension (`ScrollKittyMonitor`):** Applies shields to selected apps.
- **Shield Configuration (`ScrollKittyShield`):** Custom blocking screen with cat state visuals.
- **Shield Action (`ScrollKittyAction`):** Handles bypass, deducts HP, starts cooldown, logs timeline event.
- **Data Flow:** Extensions write to App Group UserDefaults → Main App reads and updates UI.

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
- **Real-Time Dashboard** - Displays Cat Health (Healthy → Concerned → Tired → Weak → Dead)
- **Health Percentage** - Updates on app foreground (lazy refresh)
- **Color-Coded Progress Bar** - Visual feedback (Green → Orange → Red)
- **Midnight Reset** - Health resets to 100 on new day (lazy, checked on app open)

#### 9. **Timeline View (AI-Powered)**
- **Vertical Timeline** - Blue line with cat icons, date-grouped
- **AI-Generated Messages** - Apple Foundation Models for contextual cat responses
- **Fallback Templates** - Pre-written messages when AI unavailable
- **Event Triggers** - First bypass, cluster detection, quiet return, daily summary
- **Tone System** - Messages adjust based on cat health (playful → faint)

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

---

## ✅ Current Status (Dec 2025)

### Core Mechanics - COMPLETE
| Feature | Status |
|---------|--------|
| Global Health Pool (100 HP, -5 per bypass) | ✅ |
| Global Cooldown System (10-60 min) | ✅ |
| Midnight Health Reset (lazy) | ✅ |
| Dead Cat Lockout (0 HP = locked until midnight) | ✅ |
| Timeline Event Logging | ✅ |
| AI-Powered Timeline Messages | ✅ |

### Timeline AI - WORKING
- **Apple Foundation Models** for on-device AI generation
- **Fallback templates** when AI unavailable
- **Event triggers**: First bypass, cluster (3+ in 15 min), quiet return, daily summary
- **Tone system**: Playful → Concerned → Strained → Faint (based on cat health)
- **Pre-written welcome message** on first timeline view

---

## 🔧 Recent Improvements (Dec 2025)

### AI Prompt System Overhaul
**Problem:** AI was generating generic, repetitive responses that ignored context (tone, health, event type).

**Solution Implemented:**
1. **Structured System Prompt** (`TimelineAIService.swift`)
   - TONE_LEVEL enforcement at top (must use provided tone)
   - Emotion rules (allowed: tired, wobbly; forbidden: pain, harm)
   - Language rules (no technical terms, no hype phrases)
   - 8 style guide examples (2 per tone level)
   - Token budget: ~300 tokens for system prompt

2. **Semantic Context Format** (`TimelineAIService.swift`)
   - Per-request prompts use structured format:
     ```
     TONE_LEVEL: {{tone}}
     CONTEXT:
     - Event meaning: {{semantic description}}
     - Cat state: {{health-based state}}
     - Time of day: {{morning/afternoon/evening/late night}}
     - Pattern: {{usage pattern summary}}
     ```
   - Replaced technical language ("pushed through shield") with emotional language

3. **Generation Options**
   - Temperature: 0.25 (low for consistency)
   - Token limit: 80 tokens (concise output)

4. **Context Data**
   - Added `timestamp` to `TimelineAIContext` for time-of-day derivation
   - Personalization hints (usage vs baseline, sleep impact, idle check style)

### Critical Bugs Fixed

1. **Tone Mapping Mismatch** (`TimelineManager.swift`)
   - **Bug:** `.tired` (40-59 HP) mapped to `.concerned` instead of `.strained`
   - **Fix:** Corrected all tone mappings:
     - `.tired` → `.strained`
     - `.weak` → `.faint`
     - `.dead` → `.faint` (for AI compatibility)

2. **Dead Cat Bypass Exploit** (`ShieldActionExtension.swift`)
   - **Bug:** Health value of 0 was converted to 100, making dead cat check unreachable
   - **Fix:** Check if key exists AND value is 0 before applying default
   - **Impact:** Prevented dead cats from bypassing shields and resurrecting

3. **Invalid AI Tone Value** (`TimelineManager.swift`)
   - **Bug:** `.dead` tone sent to AI, but system instructions only accept 4 tones
   - **Fix:** Map `.dead` → `.faint` for AI context

### Current Issues Identified

**Problem:** AI still generating generic responses despite improvements.

**Root Causes:**
1. **Event Meaning Too Euphemistic** (`TimelineAIService.swift:186`)
   - `.firstBypassOfDay` described as "our first check-in" instead of acknowledging bypass
   - Should reflect actual event (bypass) in emotional language

2. **Pattern Detection Broken** (`TimelineFeature.swift:124-125`)
   - `recentEventWindow: 0` hardcoded (should calculate from actual events)
   - `timeSinceLastEvent: nil` not calculated
   - Prevents cluster detection and pattern awareness

3. **Pattern Summary Can't Work** (`TimelineAIService.swift:227-238`)
   - `patternSummary()` checks `recentEventWindow >= 3` but it's always 0
   - Pattern detection never triggers

**Next Steps:**
- Fix event meaning to acknowledge bypasses appropriately
- Calculate `recentEventWindow` from actual timeline events
- Calculate `timeSinceLastEvent` for quiet return detection
- Ensure pattern summary reflects actual usage patterns

---

## 🔮 Planned (Next)

### AI Refinements (Priority)
- [ ] Fix event meaning to acknowledge bypasses (not "check-in")
- [ ] Calculate `recentEventWindow` from actual events for pattern detection
- [ ] Calculate `timeSinceLastEvent` for quiet return detection
- [ ] Fix `patternSummary()` to work with real data
- [ ] Add daily cap enforcement to processRawEvents
- [ ] Improve cluster detection logic

### Optimizations
- [ ] Timeline UI polish
- [ ] Performance profiling
- [ ] Error handling edge cases

### Future Features
- [ ] Focus Window enforcement (time-based blocking)
- [ ] Streaks & achievements
- [ ] Analytics dashboard
