# TCA Troubleshooting Guide

## Common Issues and Solutions

### 1. TCA Package Not Linked
**Symptom:** "No such module 'ComposableArchitecture'" or macro errors

**Fix:**
- Check Target → General → Frameworks, Libraries, and Embedded Content
- Verify ComposableArchitecture appears in the list
- If missing, add it manually from the project's package dependencies

### 2. Wrong Reducer Body Syntax
**Problem:** Using old TCA patterns with new `@Reducer` macro

```swift
// ❌ WRONG - Old TCA syntax
var body: some ReducerOf<Self> {
    Reduce<State, Action> { state, action in
        // ...
    }
}

// ✅ CORRECT - Modern TCA 1.x syntax
var body: some Reducer<State, Action> {
    Reduce { state, action in
        // ...
    }
}
```

### 3. Missing Equatable Conformances
**Symptom:** "Type does not conform to protocol 'Equatable'"

**Fix:** ALL Actions must be Equatable when using navigation

```swift
@Reducer
struct MyFeature {
    @ObservableState
    struct State: Equatable {
        // ...
    }

    // ✅ Always add Equatable to Action
    enum Action: Equatable {
        case buttonTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case completed
        }
    }
}
```

### 4. Circular Reference in Child Actions
**Symptom:** "Circular reference" error in parent reducer

```swift
// ❌ WRONG - Embeds entire feature
enum Action {
    case child(ChildFeature)  // NEVER DO THIS
}

// ✅ CORRECT - Only reference the Action type
enum Action {
    case child(ChildFeature.Action)
}
```

### 5. Navigation Destination Enum Configuration
**Symptom:** "StackState does not conform to Equatable"

**Fix:** Use proper @Reducer parameters

```swift
// ✅ CORRECT - Navigation destination enum
@Reducer(state: .equatable, action: .equatable)
enum Path {
    case welcome(WelcomeFeature)
    case detail(DetailFeature)
}
```

### 6. Actor Isolation Issues with CancelID
**Symptom:** "main actor-isolated conformance cannot satisfy Sendable requirement"

```swift
// ❌ WRONG - Enum causes actor isolation issues
enum CancelID: Hashable, Sendable {
    case timer
}

// ✅ CORRECT - Use nonisolated struct
nonisolated struct CancelID: Hashable, Sendable {
    static let timer = Self()
}
```

### 7. NavigationStackStore Pattern
**Modern TCA navigation pattern:**

```swift
NavigationStackStore(
    store.scope(state: \.path, action: \.path)
) {
    RootView(store: store.scope(state: \.root, action: \.root))
} destination: { store in
    switch store.case {
    case let .welcome(store):
        WelcomeView(store: store)
    case let .detail(store):
        DetailView(store: store)
    }
}
```

## Standard TCA Feature Template

```swift
import ComposableArchitecture

@Reducer
struct FeatureName {
    @ObservableState
    struct State: Equatable {
        // State properties
    }

    enum Action: Equatable {
        // Actions
        case delegate(Delegate)

        enum Delegate: Equatable {
            // Delegate actions for parent
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .delegate:
                return .none
            }
        }
    }
}
```

## Build Issues Checklist

When TCA build fails, check in this order:

1. ✅ Is ComposableArchitecture linked to target?
2. ✅ All Actions conform to Equatable?
3. ✅ All States conform to Equatable?
4. ✅ Using `Reducer<State, Action>` not `ReducerOf<Self>`?
5. ✅ Using bare `Reduce` not `Reduce<State, Action>`?
6. ✅ Child actions use `ChildFeature.Action` not `ChildFeature`?
7. ✅ Navigation enum has `@Reducer(state: .equatable, action: .equatable)`?
8. ✅ Building without `-sdk` parameter in xcodebuild?

## Useful Commands

```bash
# Clean build (when macros act weird)
rm -rf ~/Library/Developer/Xcode/DerivedData/ScrollKitty-*

# Build without SDK parameter (important for macros)
xcodebuild -project ScrollKitty.xcodeproj -scheme ScrollKitty build

# Check build settings
xcodebuild -project ScrollKitty.xcodeproj -scheme ScrollKitty -showBuildSettings | grep -i macro
```

## Resources

- [TCA GitHub](https://github.com/pointfreeco/swift-composable-architecture)
- [TCA Examples](https://github.com/pointfreeco/swift-composable-architecture/tree/main/Examples)
- [Point-Free Discord](https://www.pointfree.co/discord-invite)
- [Migration Guides](https://github.com/pointfreeco/swift-composable-architecture/discussions)

## Notes from This Build

**Date:** October 22, 2025

**Issues Encountered:**
1. TCA package not linked to target
2. Used `ReducerOf<Self>` instead of `Reducer<State, Action>`
3. Missing `Action: Equatable` on multiple features
4. Circular reference: `case onboarding(OnboardingFeature)` instead of `case onboarding(OnboardingFeature.Action)`
5. CancelID enum caused actor isolation issues
6. Navigation Path enum missing `@Reducer(state: .equatable, action: .equatable)`

**All fixed and building successfully!**
