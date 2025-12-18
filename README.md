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
- Template-based summaries (120 curated messages)
- Gentle, supportive companion personality that reflects daily patterns
- Event triggers: health band drops, daily summary, daily welcome
- Tone system: Playful -> Concerned -> Strained -> Faint -> Dead (based on energy level)
- Smart selection avoids repetition within same day

#### 5. Terminal & Nightly Summary System
- **Terminal Messages** - 40 supportive templates for HP=0 (collaborative "we" language)
- **Nightly Messages** - 80 templates (40 good day, 40 mixed day) for 11 PM reflections
- **Session Tracking** - Records shield dismissal → re-application time
- **Data Interpolation** - Real usage data (times, hours, limits) inserted into templates
- **Anti-Repetition** - Core structure matching prevents consecutive duplicates
- **AI Infrastructure Preserved** - `@Generable` types kept for future shield dialogue feature

#### 6. Daily Summary Notification System
- 11 PM local notification triggers daily summary
- Timezone-aware scheduling with explicit `TimeZone.current`
- Atomic duplicate prevention using date-based UserDefaults keys
- Proper actor isolation with `nonisolated` methods where appropriate
- Permission denial feedback via `NotificationCenter`

#### 7. AI Debug Tools (DEBUG builds only)
- `AIDebugLogger` - Logs all AI prompts, responses, errors, generation options
- `TerminalDebugHelper` - Test scenarios for rapid AI testing
- Exportable logs for debugging

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

## Terminal & Nightly Summary System (Dec 2025) ✅ Production Ready

### Overview
Template-based message system for Terminal (HP=0) and Nightly (11 PM) summaries. Provides consistent, supportive messages with real usage data interpolation. AI infrastructure preserved for future shield dialogue feature.

### Architecture

**Template Pools:**
- **Terminal (HP=0)**: 40 supportive messages with collaborative "we" language
- **Nightly Good Day (HP ≥40)**: 40 positive templates for within/under limit
- **Nightly Mixed Day (HP 20-39)**: 40 tired-tone templates for over limit

**Session Tracking System:**
- **ShieldActionExtension** records `sessionStartTime` on each shield bypass
- **DeviceActivityMonitorExtension** calculates elapsed time when shield re-applies
- **Accumulates** total usage in `cumulativePhoneUseSeconds` throughout the day
- **Tracks** `firstBypassTime` and `lastBypassTime` for context
- **Resets** all session data at midnight via `CatHealthManager`

**Template Selection:**
- Routes by health band and limit status
- Anti-repetition via core structure matching
- Random selection from available pool
- Falls back to full pool if all recently used

### Implementation

**Core Services:**
- `NightlyTerminalTemplates.swift` - 120 curated templates with interpolation
- `ContextBuilder.swift` - Enriched context with session data, limit status, day part
- `TerminalNightlyContext.swift` - Data model with `LimitStatus`, `DayPart` enums

**AIUtils (5 helpers):**
- `DayPartDeriver.swift` - Time → DayPart conversion
- `EmotionMapper.swift` - Health band → emotion descriptions (for health drops)
- `HoursFormatter.swift` - Natural language time formatting
- `StableHash.swift` - Deterministic hashing for variation seeds
- `Format.swift` - Clean number formatting

**AI Infrastructure (Preserved for Future):**
- `NightlyAI.swift` - Marked PRESERVED for shield dialogue
- `TerminalAI.swift` - Marked PRESERVED for shield dialogue
- `TimelineAIModels.swift` - `@Generable` types for future AI features

**Testing:**
- `NightlyTerminalTemplatesTests.swift` - 5 TCA integration tests using TestStore
- Tests assert exact template messages with interpolated data
- Deterministic template selection (`selectNightlyDeterministic`) for reproducible tests
- Validates TCA state flow, anti-duplication, natural language formatting

### Data Placeholders

Templates interpolate real usage data:
- `{{firstUseTime}}` - "9:30 AM"
- `{{lastUseTime}}` - "10:45 PM"
- `{{terminalAtLocalTime}}` - "4:15 PM" (terminal only)
- `{{phoneUseHours}}` - "3.5"
- `{{goalHours}}` - "4"
- `{{overByHours}}` - "2.5"
- `{{underByHours}}` - "0.5"
- `{{currentHealthBand}}` - "90"
- `{{dayPart}}` - "morning/afternoon/evening/night"

### Message Examples

**Terminal (HP=0):**
> "You started scrolling at 9:30 AM and we hit my limit by 4:15 PM. You clocked 6 hours—2 past your 4 goal—and now I'm in coffin mode at 0 health in the afternoon. I felt the drain build, but it's okay—we can reflect and do better tomorrow. 😼🔄"

**Good Day (HP ≥40, Within Limit):**
> "You started scrolling at 9:30 AM and wrapped up by 5:45 PM. You kept it to just 3.5 hours—under your 4 goal by 0.5—so I'm still full energy at 90. My paws stayed light all day, no cap. 😼✨"

**Mixed Day (HP 20-39, Over Limit):**
> "You started scrolling at 8:15 AM and dragged to 10:20 PM. You went 1.5 over the 4 goal with 5.5 total, so I'm feeling the sludge at 30. My paws got heavier, but reset tomorrow—better luck next time. 😾"

### Integration

- **TimelineManager** - Routes to `selectTerminal()` or `selectNightly()`, prevents duplicates
- **ShieldActionExtension** - Tracks session start times and bypass counts
- **DeviceActivityMonitorExtension** - Accumulates phone usage time
- **CatHealthManager** - Clears all session tracking keys at midnight reset

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
│   ├── NightlyTerminalTemplates.swift
│   ├── NightlyAI.swift (PRESERVED for future AI)
│   ├── TerminalAI.swift (PRESERVED for future AI)
│   ├── ContextBuilder.swift
│   ├── DailySummaryNotificationService.swift
│   ├── UserSettingsManager.swift
│   ├── CatHealthManager.swift
│   └── AIUtils/
│       ├── DayPartDeriver.swift
│       ├── EmotionMapper.swift
│       ├── HoursFormatter.swift
│       ├── StableHash.swift
│       └── Format.swift
├── Models/
│   ├── TimelineAIModels.swift (PRESERVED for future AI)
│   ├── TimelineEvent.swift
│   └── TerminalNightlyContext.swift
├── ScrollKittyTests/
│   └── NightlyTerminalTemplatesTests.swift
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
- **NightlyTerminalTemplates** - 120 curated templates (40 terminal + 80 nightly)
- **ContextBuilder** - Enriches context with session data, limit status, day part
- **AIMessageHistory** - Tracks recent messages for anti-repetition
- **TimelineAIService** - (Health band drops only) Still uses AI for HP drop messages
- **TimelineTemplateMessages** - (Legacy) Previously used for all timeline messages

---

## Status Summary (Dec 2025)

| Area | Status |
|------|--------|
| Core Shielding System | Complete |
| Onboarding Flow | Complete |
| Timeline Messages | Template-based (120 curated messages) |
| Terminal/Nightly Summaries | Complete (template system with data interpolation) |
| Session Tracking | Complete (shield dismissal → re-application time accumulation) |
| Daily Summary Notifications | Complete |
| Structured Logging | Complete |
| AI Infrastructure | Preserved for future shield dialogue feature |
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
