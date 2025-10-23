# ScrollKitty 🐱

**A Screen Time Management App with Personality**

ScrollKitty is a SwiftUI app built with The Composable Architecture (TCA) that helps users understand and manage their phone addiction through a personalized, cat-themed experience.

## 🎯 Project Overview

ScrollKitty takes users on a journey of self-discovery about their phone usage habits. The app uses a friendly cat mascot to deliver personalized insights about screen time addiction, making the often uncomfortable topic of digital wellness more approachable and engaging.

## 🏗️ Architecture

- **Framework:** SwiftUI + The Composable Architecture (TCA)
- **Navigation:** Stack-based navigation with `NavigationStack`
- **State Management:** TCA reducers with `@ObservableState`
- **Design System:** Centralized design tokens in `DesignSystem.swift`
- **Font:** Sofia Pro (Bold, Medium, Regular variants)

## 📱 Current Implementation

### ✅ Completed Features

#### 1. **Onboarding Flow (8 Screens)**
- **Splash Screen** - Auto-advance after 2 seconds
- **Welcome Screen** - Introduction with cat mascot
- **Usage Question** - Daily phone hours selection
- **Addiction Assessment** - "Do you feel addicted to your phone?"
- **Sleep Impact** - "Does phone use interfere with your sleep?"
- **Without Phone** - "How do you feel without your phone?"
- **Idle Check** - "How often do you check your phone when idle?"
- **Age Selection** - User age range

#### 2. **Navigation System**
- EmptyView root pattern to prevent back button flickering
- Stack-based navigation with proper state management
- Progress indicator (2/5 to 5/5) showing user journey
- Back button functionality on all screens except splash

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

#### 4. **Design System**
- **Colors:** Primary blue (#015AD7), light blue (#BBDBFF), grays, black/white
- **Typography:** Sofia Pro font family with proper weight variants
- **Components:** Reusable buttons, progress indicators, option selectors
- **Spacing:** Consistent padding and margins throughout

#### 5. **User Data Collection**
- Hour selection (3hrs or less → 12hrs+)
- Addiction level (Not at all → Yes)
- Sleep interference (Never → Always)
- Phone dependency (Totally fine → Panic)
- Idle checking frequency (Rarely → Constantly)
- Age range (Under 18 → 30+)

## 🔮 Planned Features (Post-Results Screen)

### 1. **Results Screen**
- **Personalized Score** - Based on user's onboarding responses
- **Comparison Data** - Against Gen Z/Millennial averages (8 hours/day)
- **Cat Reactions** - Different cat emotions based on severity
- **Visual Breakdown** - Charts showing usage patterns

### 2. **Bad News Delivery**
- **Honest Assessment** - Direct feedback about phone addiction
- **Gen Z Language** - "You're chronically online" messaging
- **Visual Impact** - Bold, attention-grabbing design
- **Cat Personality** - Cat mascot reactions to user's score

### 3. **Solution Recommendations**
- **Personalized Tips** - Based on specific user patterns
- **App Blocking** - Integration with Screen Time API
- **Focus Modes** - Custom focus sessions
- **Progress Tracking** - Daily/weekly usage monitoring

### 4. **Main App Features**
- **Dashboard** - Daily usage overview
- **Cat Mood** - Cat's emotional state based on usage
- **Streaks** - Consecutive days of healthy usage
- **Challenges** - Gamified reduction goals
- **Social Features** - Share progress with friends

### 5. **Advanced Features**
- **AI Insights** - Machine learning for usage patterns
- **Custom Notifications** - Smart reminders
- **Integration** - Calendar, productivity apps
- **Analytics** - Detailed usage breakdowns

## 🛠️ Technical Implementation

### File Structure
```
ScrollKitty/
├── Features/
│   ├── App/AppFeature.swift
│   └── Onboarding/OnboardingFeature.swift
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
│   │   └── OnboardingView.swift
│   ├── Results/
│   │   └── ResultsLoadingView.swift
│   └── Components/
│       ├── PrimaryButton.swift
│       ├── ProgressIndicator.swift
│       └── OptionSelector.swift
├── DesignSystem.swift
├── ContentView.swift
└── ScrollKittyApp.swift
```

### Key TCA Patterns
- **Feature + View** combined in single files
- **Delegate pattern** for inter-reducer communication
- **Stack-based navigation** with proper state management
- **Dependency injection** for clock/timer effects
- **Observable state** for SwiftUI integration

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

1. **Results Screen Implementation** - Show calculated addiction score
2. **Bad News Delivery** - Honest assessment with cat reactions
3. **Solution Recommendations** - Personalized tips and strategies
4. **Main App Dashboard** - Daily usage tracking and cat mood
5. **Screen Time Integration** - Native iOS Screen Time API
6. **Gamification** - Streaks, challenges, and achievements

---

*ScrollKitty: Because sometimes you need a cat to tell you you're chronically online* 🐱📱
