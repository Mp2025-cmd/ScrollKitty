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

#### 4. Timeline View (Template Messages)
- Vertical timeline with blue line and cat icons, date-grouped
- Prebuilt template messages (120 curated messages)
- Gentle, supportive companion personality that reflects daily patterns
- Event triggers: health band drops, daily summary, daily welcome
- Tone system: Playful -> Concerned -> Strained -> Faint -> Dead (based on energy level)
- Smart selection avoids repetition within same day

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
    temperature: 0.6,
    maximumResponseTokens: 50
)
```

### Recent Fixes (Dec 2025)
- Fixed daily summary trigger window (9 PM - 1 AM instead of exact 11 PM)
- Simplified health drop counting (no duplicates)
- Added trigger-specific context to AI prompts
- Base summary descriptions on final health (not drop count)
- Calculate health bands dynamically (not hardcoded)
- Fixed AI message repetition issues (see below)

---

## AI Repetition Fix (Dec 2025)

### Problem
Debug logs revealed three critical issues with AI message generation:

1. **Repeated Messages**: Same exact phrase "I'm running very low, like most of my spark has dimmed. Every moment feels slower." generated for multiple health drops (25→20, 15→10, 5→0)
2. **Duplicate Entries**: Same event processed twice, generating identical messages at the same timestamp
3. **Session Concurrency Error**: Daily summary failed with error "Attempted to call respond(to:) a second time before the model finished responding" when triggered immediately after a health drop

### Root Causes

1. **System Prompt Examples**: The system instructions contained verbatim example phrases (lines 279-284 in `TimelineAIService.swift`) that the AI was copying directly:
   ```swift
   faint: "I'm running very low, like most of my spark has dimmed. Every moment feels slower."
   ```

2. **Temperature Too Low**: Temperature 0.5 was too deterministic, causing the AI to converge on the same phrases, especially at faint tone

3. **Passive Anti-Repetition**: Prompt showed "Recent entries today:" but didn't explicitly instruct the AI to avoid them

4. **Race Condition**: `waitForSession()` checked `isResponding` but two concurrent calls could both see `false` before either started generating, leading to simultaneous `respond()` calls

### Solution

**1. Removed Example Phrases from System Instructions**
- Removed all verbatim example messages
- Kept tone descriptions (playful, concerned, strained, faint) without examples
- Added explicit rule: "Never repeat previous entries"

**2. Increased Temperature to 0.6**
- Changed from 0.5 to 0.6 for more variety while maintaining personality
- Balances creativity with consistency

**3. Explicit Anti-Repetition Instruction**
- Changed prompt from "Recent entries today:" to "DO NOT repeat these phrases:"
- Makes it explicit that the AI should avoid repeating, not just reference

**4. Fixed Session Concurrency with Task Tracking**
- Added `currentTask: Task<Void, Never>?` to `TimelineAISessionManager`
- `waitForSession()` now waits for `currentTask?.value` to complete
- Generation wrapped in Task and tracked before execution
- Ensures only one generation happens at a time

### Files Modified
- `ScrollKitty/Services/TimelineAIService.swift`: Removed examples, increased temp, explicit anti-repetition
- `ScrollKitty/Services/TimelineAISessionManager.swift`: Added task tracking for concurrency control

### Expected Results
- ✅ More varied messages (temperature 0.6)
- ✅ No verbatim copying of example phrases
- ✅ Explicit avoidance of recent messages
- ✅ No concurrent session errors
- ✅ Personality maintained (gentle, supportive tone)

---

## Switch to Prebuilt Template Messages

### Why We're Switching from AI to Templates

**Problems with AI:**
- **Device Requirements**: Apple Foundation Models require iPhone 15 Pro+/M1+ and Apple Intelligence enabled, creating inconsistent UX
- **Tone Drift**: Despite prompt engineering, AI occasionally drifts from desired "gentle, supportive" persona
- **Repetition**: Even with anti-repetition measures, identical messages still occur
- **Performance**: Token costs, context management, and generation delays

**Benefits of Templates:**
- ✅ **100% Consistent Tone**: Every message curated to match exact persona
- ✅ **Always Available**: No device requirements, instant selection
- ✅ **Zero Repetition**: 20 messages per band with smart selection
- ✅ **Performance**: Instant selection, no AI overhead
- ✅ **Full Control**: Every message intentional and matches desired voice

### Implementation Plan

**Step 1: Create Template Service**
- New file: `ScrollKitty/Services/TimelineTemplateMessages.swift`
- Store 120 prewritten messages organized by health band (80, 60, 40, 20, 10, 0) and trigger (dailyWelcome, dailySummary)
- Implement smart random selection avoiding recent messages

**Step 2: Update TimelineAIService**
- Modify `generateMessage()` to use templates instead of AI
- Keep same function signature for drop-in replacement
- Use `context.currentHealthBand` for health band messages
- Use `context.trigger` for dailyWelcome/dailySummary

**Step 3: Update Integration Points**
- `TimelineManager.checkForDailySummary()` (line 113) - Remove guard, templates always available
- `TimelineManager.getDailyWelcome()` (line 233) - Remove guard
- `TimelineFeature.processRawEvents()` (line 165) - Remove guard

**Step 4: Extract Messages from README**
- Parse messages from README lines 337-338 into Swift arrays
- Messages include emojis as part of text (keep as-is)

**Step 5: Recent Message Avoidance**
- Use existing `AIMessageHistory` for tracking
- Filter recent messages from selection pool
- Reset pool if all messages used (allow repeats)

**Code References:**
- `TimelineAIService.generateMessage()` - Main entry point
- `TimelineAIContext.currentHealthBand` - For band selection
- `TimelineAIContext.trigger` - For dailyWelcome/dailySummary
- `AIMessageHistory` - For recent message tracking

**Message Format:**
- 120 total messages: 20 per health band (80, 60, 40, 20, 10, 0) + 20 dailyWelcome + 20 dailySummary
- Emojis included in message text
- Tone progression: playful → concerned → strained → faint → dead

---

## AI Summary System Refactor (Dec 2025)

### Overview
Implemented modular AI architecture for phone activity summaries using Apple Foundation Models with `@Generable` structured output and post-processing validation.

### Architecture Changes

**Two AI Generators:**
- **NightlyAI** - Emotional reflections at 11 PM (temp 0.5, top-25 sampling)
- **TerminalAI** - Stark messages when HP reaches 0 (temp 0.0, deterministic)

**Session Tracking (4 new UserDefaults keys):**
- `sessionStartTime` - When user first bypassed shield
- `cumulativePhoneUseSeconds` - Total phone usage accumulated
- `firstBypassTime` - First bypass of the day
- `lastBypassTime` - Most recent bypass

**Hybrid Validation Approach:**
- `@Generable` for type-safe structured output
- `ContextBuilder` enriches context with session data
- `CatMessage` enforces exactly 2 sentences
- `OutputValidator` prevents advice, banned words, contradictions

### New Files Created (11 total)

**Core Services:**
- `NightlyAI.swift` - 11 PM emotional summaries
- `TerminalAI.swift` - HP=0 terminal messages
- `ContextBuilder.swift` - Enriched context builder
- `OutputValidator.swift` - Strict output validation

**Models:**
- `CatMessage.swift` - 2-sentence enforcement
- `TerminalNightlyContext.swift` - Extended with LimitStatus, DayPart enums

**AIUtils (6 helpers):**
- `SentenceUtils.swift` - Sentence splitting/cleanup
- `TimeParsing.swift` - Hours parsing, limit calculations
- `DayPartDeriver.swift` - Time → DayPart conversion
- `EmotionMapper.swift` - Health band → emotion descriptions
- `HoursFormatter.swift` - Natural language time formatting
- `TerminalVariations.swift` - Phrase variations for terminal messages
- `StableHash.swift` - Deterministic hashing for seeds
- `Format.swift` - Clean number formatting

### Key Features

**Output Enforcement:**
- ✅ Exactly 2 sentences (enforced by CatMessage)
- ✅ Natural language hours ("almost 4 hours" vs "3.8 hours")
- ✅ No advice phrases ("you should", "try to")
- ✅ Terminal bans (never mention "health", "HP", "zero")
- ✅ Validates against limitStatus (no contradictions)

**Emotion Mapping:**
- 80-100 HP: Relieved, content, happy
- 60-79 HP: Okay but slightly drained
- 40-59 HP: Worn out, exhausted
- 20-39 HP: Really drained, barely holding on
- 0-19 HP: Completely wiped, empty

### Updated Services

- **TimelineManager** - Routes to TerminalAI or NightlyAI based on trigger
- **ShieldActionExtension** - Tracks session start and bypass times
- **DeviceActivityMonitorExtension** - Accumulates phone usage time
- **CatHealthManager** - Clears session tracking at midnight reset

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
│   ├── NightlyAI.swift
│   ├── TerminalAI.swift
│   ├── ContextBuilder.swift
│   ├── OutputValidator.swift
│   ├── DailySummaryNotificationService.swift
│   ├── UserSettingsManager.swift
│   ├── CatHealthManager.swift
│   └── AIUtils/
│       ├── SentenceUtils.swift
│       ├── TimeParsing.swift
│       ├── DayPartDeriver.swift
│       ├── EmotionMapper.swift
│       ├── HoursFormatter.swift
│       ├── TerminalVariations.swift
│       ├── StableHash.swift
│       └── Format.swift
├── Models/
│   ├── TimelineAIModels.swift
│   ├── TimelineEvent.swift
│   ├── CatMessage.swift
│   └── TerminalNightlyContext.swift
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

### Message System Architecture
- **TimelineAIService** - TCA dependency for message generation (currently using templates)
- **TimelineTemplateMessages** - Service storing 120 prebuilt messages organized by health band and trigger
- **AIMessageHistory** - Tracks recent messages for repetition avoidance
- **TimelineAISessionManager** - (Deprecated) Previously managed AI sessions

---

## Status Summary (Dec 2025)

| Area | Status |
|------|--------|
| Core Shielding System | Complete |
| Onboarding Flow | Complete |
| Timeline Messages | Template system (120 prebuilt) + AI summaries (modular architecture) |
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


### Template Message System

ScrollKitty includes 120 curated template messages organized by health band (80, 60, 40, 20, 10, 0 HP) and special triggers (daily welcome, daily summary). Messages feature:

- **Tone Progression**: Playful → Concerned → Strained → Faint → Dead (matches energy level)
- **Smart Selection**: Anti-repetition logic avoids repeating recent messages
- **Personality Consistency**: Every message curated to match gentle, supportive companion voice
- **Always Available**: No device requirements, instant selection
