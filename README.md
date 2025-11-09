# ScrollKitty 🐱

**A Screen Time Management App with Personality**

ScrollKitty is a SwiftUI app built with The Composable Architecture (TCA) that helps users understand and manage their phone addiction through a personalized, cat-themed experience.

## 🎯 Project Overview

ScrollKitty takes users on a journey of self-discovery about their phone usage habits. The app uses a friendly cat mascot to deliver personalized insights about screen time addiction, making the often uncomfortable topic of digital wellness more approachable and engaging.

## 🏗️ Architecture

- **Framework:** SwiftUI + The Composable Architecture (TCA)
- **Navigation:** Enum-based destination pattern with type-safe state machine
- **State Management:** TCA reducers with `@ObservableState`
- **Design System:** Centralized design tokens in `DesignSystem.swift`
- **Font:** Sofia Pro (Bold, Medium, Regular variants)
- **Screen Time API:** DeviceActivity, FamilyControls, ManagedSettings frameworks

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

#### 7. **Screen Time Integration**
- **Screen Time Access Screen** - Placeholder for requesting Screen Time API access

#### 8. **Home/Dashboard Screen**
- **Scroll Kitty Title** - Centered app name
- **Cat Display** - Shows current Scroll Kitty health state with shadow
- **Usage Stats** - 36% score with progress bar and "1 hour 25 minutes" display
- **TCA-Compliant TabBar** - Dashboard and Timeline tabs with proper state management
  - `HomeFeature` reducer co-located in `HomeView.swift`
  - `BindableAction` with `BindingReducer` for tab selection
  - `HomeTab` enum (dashboard/timeline) for type safety
  - Explicit `tabSelected` actions

#### 9. **Timeline View**
- **Vertical Timeline** - Blue line (#BBDBFF) with cat dashboard icons
- **Chat-Style Cards** - Messages from Scroll Kitty about app usage
- **Cat State Integration** - Uses `CatState` enum for images and colors
- **Color-Coded Backgrounds** - Progressively darker blues as cat gets sicker
- **Date Headers** - "Jan 1 • Monday" format with blue dots
- **AttributedString Messages** - Colored highlights for time amounts (cyan, orange, red)
- **Cat Images** - Positioned on right side of cards (133x120)
- **Timestamps** - Light blue (#BBDBFF) time labels

#### 10. **CatState Enum**
- **Centralized Cat Management** - Single source of truth for all cat states
- **5 Health States**: healthy, concerned, tired, sick, dead
- **Properties**: images, colors, display names, health levels
- **Helper Methods**: `from(screenTimeHours:)`, `from(percentage:)`
- **Nested HealthLevel Enum** - Descriptions for each state
- **Timeline Integration** - Background colors, time colors, icon colors

#### 11. **Design System**
- **Colors:** Primary blue (#015AD7), light blue (#BBDBFF), grays, black/white
- **Typography:** Sofia Pro font family with proper weight variants
- **Components:** Reusable buttons, progress indicators, option selectors, back buttons
- **Spacing:** Consistent padding and margins throughout

#### 10. **User Data Collection**
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
- **Feature + View co-location** - `HomeFeature` embedded in `HomeView.swift` for simple features
- **Coordinator pattern** - Separate coordinator features (AppFeature, OnboardingFeature) manage navigation
- **Delegate pattern** - Child features communicate with parents via `.delegate(Delegate)` actions
- **TabBar navigation** - `BindableAction` with `BindingReducer` for tab selection (HomeView)
- **Type-safe tabs** - Enum-based tab selection (`HomeTab`) instead of Int
- **Stack-based navigation** - `StackState<Path.State>` and `StackAction` for navigation flows
- **Path enum reducers** - `@Reducer(state: .equatable, action: .equatable)` for navigation destinations
- **Dependency injection** - `@Dependency(\.continuousClock)` for timer effects
- **Observable state** - `@ObservableState` for SwiftUI integration
- **Bindable state** - `BindableAction` with `@Bindable` for two-way bindings (CommitmentView, HomeView)
- **Effect.run** - Explicit `Effect<Action>` type annotations for async work
- **Cancellable effects** - Using `CancelID` for cancellable timers and tasks
- **Haptic feedback** - TCA-compliant haptic feedback using `.run` effects

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
