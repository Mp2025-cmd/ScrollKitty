# ScrollKitty

**A Screen Time Management App with Personality**

ScrollKitty is a SwiftUI app built with The Composable Architecture (TCA) that helps users understand and manage their phone usage through a gentle, supportive cat companion.

## Project Overview

ScrollKitty takes users on a journey of self-awareness about their phone usage habits. The app uses a cat companion whose energy reflects the user's daily patterns, providing gentle diary-style reflections that increase awareness without judgment, blame, or shame.

## Architecture

- **Framework:** SwiftUI + The Composable Architecture (TCA)
- **Navigation:** Enum-based destination pattern with type-safe state machine
- **State Management:** TCA reducers with `@ObservableState` and dependency injection
- **Design System:** Centralized design tokens in `DesignSystem.swift`
- **Font:** Sofia Pro (Bold, Medium, Regular variants)
- **Screen Time API:** DeviceActivity, FamilyControls, ManagedSettings frameworks
- **AI:** Apple Foundation Models (on-device, privacy-first)
- **Data Persistence:** App Group UserDefaults for main app <-> extension communication
- **Logging:** Structured logging with `os.log` Logger

## Current Implementation

### Completed Features

#### 1. Active Shielding System (Core Loop)
- **Architecture:** "Active Blocking" strategy for 100% reliability
- **Global Health Pool:** 100 HP starting, -5 HP per bypass, resets at midnight
- **Global Cooldown:** User-selected interval (10/20/30/45/60 min)
- **Dead Cat State:** At 0 HP, all apps locked until midnight (no bypass option)
- **Monitor Extension (`ScrollKittyMonitor`):** Applies shields to selected apps
- **Shield Configuration (`ScrollKittyShield`):** Custom blocking screen with cat state visuals
- **Shield Action (`ScrollKittyAction`):** Handles bypass, deducts HP, starts cooldown, logs timeline event

#### 2. Onboarding Flow (21 Screens)
All onboarding screens managed by `OnboardingFeature` using stack-based navigation:

**Initial Survey (8 screens):**
- Splash Screen, Welcome Screen, Usage Question, Addiction Assessment
- Sleep Impact, Without Phone, Idle Check, Age Selection

**Results & Analysis (4 screens):**
- Results Loading, Results, Addiction Score, Years Lost

**Solution Setup (9 screens):**
- Solution Intro, Screen Time Access, App Selection, Daily Limit
- Shield Frequency, Focus Window, Character Intro, Lifecycle Carousel, Commitment

#### 3. Home/Dashboard Screen
- Real-Time Dashboard with Cat Health states (Healthy -> Concerned -> Tired -> Weak -> Dead)
- Health Percentage with lazy refresh on app foreground
- Color-Coded Progress Bar (Green -> Orange -> Red)
- Midnight Reset (lazy, checked on app open)

#### 4. Timeline View (AI-Powered)
- Vertical timeline with blue line and cat icons, date-grouped
- AI-generated messages using Apple Foundation Models
- Gentle, supportive companion personality that reflects daily patterns
- Event triggers: health band drops, daily summary, daily welcome
- Tone system: Playful -> Concerned -> Strained -> Faint (based on energy level)

#### 5. Daily Summary Notification System
- 11 PM local notification triggers daily summary
- Timezone-aware scheduling with explicit `TimeZone.current`
- Atomic duplicate prevention using date-based UserDefaults keys
- Proper actor isolation with `nonisolated` methods where appropriate
- Permission denial feedback via `NotificationCenter`

#### 6. AI Debug Logger
- Logs all AI prompts, responses, errors, and generation options
- Exportable as text for debugging
- Debug UI button in Dashboard (DEBUG builds only)

---

## Recent Session Accomplishments (Dec 2025)

### Gentle Companion Personality
Designed the AI as a **supportive, awareness-focused companion** that helps users notice patterns without judgment:

**System Prompt Principles:**
```
You are ScrollKitty, a small companion whose energy reflects the tone of the day.
You write short diary-style reflections that help the human notice patterns
without blame, shame, or judgment.

CORE PRINCIPLES:
- Do not criticize, insult, or guilt the human
- Do not reference phone use, scrolling, or habits directly
- Describe YOUR internal physical or emotional state
- Support awareness, not behavior correction
- Use neutral, gentle language
```

**Sparse Health Bands:**
Reduced from 10 bands to 5 for less frequent but more impactful triggers:
- 100 (silent) -> 80 -> 60 -> 40 -> 20 -> 10

### Bug Fixes (9 Issues Resolved)

#### High Severity (3 fixed)
| Issue | Fix |
|-------|-----|
| Race condition - daily summary before reset | Notification tap routes through `appBecameActive` ensuring lazy reset completes first |
| Missing threshold logic | Now counts ALL events that crossed health bands, not just those with AI messages |
| Duplicate prevention race condition | Added atomic check-and-set using date-based UserDefaults key |

#### Medium Severity (3 fixed)
| Issue | Fix |
|-------|-----|
| Actor isolation violations | `notificationIdentifier` now `nonisolated let`, proper async methods |
| No permission denial feedback | Posts `notificationPermissionDenied` notification, returns `(granted, deniedByUser)` tuple |
| Midnight reset timing | Fixed via race condition fix - daily summary always runs after reset flow |

#### Low Severity (3 fixed)
| Issue | Fix |
|-------|-----|
| Emoji logs | Replaced with `os.log` structured logging via `Logger` |
| Timezone-agnostic scheduling | Added explicit `dateComponents.timeZone = TimeZone.current` |
| Dependency injection pattern | Verified as valid TCA pattern |

### AI Generation Improvements
- **GenerationOptions:** `temperature: 0.75`, `sampling: .random(top: 60)`, `maxTokens: 80`
- **Removed all fallback messages** - AI-only responses
- **Anti-repetition:** Recent messages passed to AI to avoid duplicate phrases
- **Session persistence:** Reusable `LanguageModelSession` with context summarization

---

## ScrollKitty Behavior (Current State)

### AI Personality & Awareness
ScrollKitty is a **gentle companion** whose energy mirrors the user's day. It writes short diary notes about internal shifts without mentioning phones or scrolling.

**Core Behavior:**
- ✅ **Context-aware** - Knows trigger type (health drop, daily summary, welcome)
- ✅ **Non-repetitive** - References recent messages to vary language
- ✅ **Accurate stats** - Dynamic health band calculation, proper drop counting
- ✅ **Token-efficient** - Sparse bands (20-point intervals) for meaningful milestones

### Message Triggers
| Trigger | Frequency | Example |
|---------|-----------|---------|
| **Health Band Drop** | Every 20 HP (80, 60, 40, 20, 10) | "I felt a gentle dip in energy..." |
| **Daily Welcome** | Once per day (first app open) | "A new day is starting..." |
| **Daily Summary** | 9 PM - 1 AM or 0 HP | "A day with some heavier stretches is ending..." |

### Generation Settings
```swift
GenerationOptions(
    sampling: .random(top: 40),
    temperature: 0.5,
    maximumResponseTokens: 50
)
```

### Recent Fixes (Dec 2025)
- Fixed daily summary trigger window (9 PM - 1 AM instead of exact 11 PM)
- Simplified health drop counting (no duplicates)
- Added trigger-specific context to AI prompts
- Base summary descriptions on final health (not drop count)
- Calculate health bands dynamically (not hardcoded)

---

## Planned Features

### Next Priority: Onboarding Schedule Screen
Add a new onboarding screen to configure when screen blocking is active:

**Time of Day Settings:**
- Start time (e.g., 9 AM)
- End time (e.g., 11 PM)
- Active hours display

**Days of Week Settings:**
- Individual day toggles (Mon-Sun)
- Weekday/Weekend presets
- Visual weekly calendar

**Implementation Notes:**
- New `ScheduleSetupView` in onboarding flow
- Store in `UserOnboardingProfile`
- Pass to Monitor Extension via App Group UserDefaults
- Shield only applies during configured windows

### Other Planned Features
- [ ] Focus Window enforcement (time-based blocking)
- [ ] Streaks & achievements
- [ ] Analytics dashboard
- [ ] Widget for quick health check
- [ ] Apple Watch companion

---

## Technical Implementation

### File Structure
```
ScrollKitty/
├── Features/
│   ├── App/AppFeature.swift
│   └── Onboarding/OnboardingFeature.swift
├── Views/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── HomeFeature (in HomeView.swift)
│   │   ├── TimelineView.swift
│   │   └── TimelineFeature.swift
│   └── Onboarding/
│       └── ... (21 Onboarding Views)
├── Services/
│   ├── TimelineAIService.swift
│   ├── TimelineManager.swift
│   ├── DailySummaryNotificationService.swift
│   ├── UserSettingsManager.swift
│   ├── CatHealthManager.swift
│   └── AIDebugLogger.swift
├── Models/
│   ├── TimelineAIModels.swift
│   └── TimelineEvent.swift
├── ScrollKittyMonitor/
│   └── DeviceActivityMonitorExtension.swift
├── ScrollKittyShield/
│   └── ShieldConfigurationExtension.swift
└── ScrollKittyAction/
    └── ShieldActionExtension.swift
```

### Key TCA Patterns
- **Simplified root navigation** - AppFeature manages only 2 destinations (onboarding/home)
- **Stack-based child navigation** - OnboardingFeature uses `StackState<Path.State>` for 21 screens
- **Delegate pattern** - Child features communicate via delegate actions
- **Dependency injection** - `@Dependency` for all services
- **App Group sharing** - UserDefaults for main app <-> extension communication

### AI Architecture
- **TimelineAIService** - TCA dependency wrapping Apple Foundation Models
- **TimelineAISessionManager** - Actor managing persistent `LanguageModelSession`
- **CatTimelineMessage** - `@Generable` struct for structured AI output
- **AIDebugLogger** - Actor for debugging AI interactions

---

## Status Summary (Dec 2025)

| Area | Status |
|------|--------|
| Core Shielding System | Complete |
| Onboarding Flow | Complete |
| Timeline AI | Working (tuning in progress) |
| Daily Summary Notifications | Complete |
| Structured Logging | Complete |
| Schedule Configuration | Planned |

---

## Development Notes

### Clearing Test Data
```bash
# Clear all app group UserDefaults (for testing)
defaults delete group.com.scrollkitty.app
```

### Testing 11 PM Notification
Temporarily change `DailySummaryNotificationService.swift` line 69:
```swift
dateComponents.hour = 23  // Change to current hour + 1 for testing
```

### Debug AI Responses
In DEBUG builds, tap the magnifying glass icon on the Dashboard to view AI debug logs.
