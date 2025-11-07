# 📱 Screen Time Setup Guide

## ✅ What's Implemented

### Infrastructure (Backend)
- ✅ `ScreenTimeManager` - TCA-compliant dependency
- ✅ Data models: `AppUsage`, `DailyScreenTimeData`
- ✅ Permission handling via `AuthorizationCenter`
- ✅ Mock data for testing

### UI
- ✅ `ScreenTimeAccessView` - Matches Figma design
- ✅ Face ID permission prompt
- ✅ "Don't Allow" option

---

## 🔧 Required Setup (Manual Steps)

### 1. Add Screen Time Capability in Xcode

```
1. Open ScrollKitty.xcodeproj in Xcode
2. Select "ScrollKitty" target
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability" button
5. Search for "Screen Time"
6. Click to add it
```

This adds the `com.apple.developer.family-controls` entitlement.

---

### 2. Update Info.plist

Add this key-value pair to `Info.plist`:

**Key:** `NSScreenTimeAPIUsageDescription`  
**Value:** `We need access to your screen time to help you manage your phone usage and keep Scroll Kitty healthy!`

**How to add:**
```
1. Open Info.plist in Xcode
2. Right-click → Add Row
3. Type: "Privacy - Screen Time Usage Description"
4. Value: (paste the text above)
```

---

## 📊 Current Data Flow

```
User taps "Allow with Face ID"
    ↓
ScreenTimeAccessFeature.requestAccessTapped
    ↓
AuthorizationCenter.shared.requestAuthorization(for: .individual)
    ↓
System shows Face ID prompt
    ↓
User approves → accessGranted = true
    ↓
User can continue to app
```

---

## ⚠️ Important Notes

### Testing Requirements
- **Simulator:** UI only (no real data)
- **Physical Device:** Required for full functionality

### Data Access Limitations
The current `parseScreenTimeReport()` function returns **empty data**. To get real screen time data, you need to implement:

1. **DeviceActivityMonitor Extension** (separate target)
2. **DeviceActivityReport parsing logic**
3. **Background data collection**

This requires more advanced setup beyond the current scope.

---

## 🎯 What Works Now

✅ Permission request flow  
✅ UI matches Figma design  
✅ TCA-compliant architecture  
✅ Face ID integration  
✅ Mock data for testing  

⏳ Real screen time data (needs DeviceActivity implementation)

---

## 🚀 Next Steps (Optional - Advanced)

To get **real screen time data**, you'll need to:

### 1. Create DeviceActivity Extension
```
File → New → Target → DeviceActivity Extension
```

### 2. Implement DeviceActivityMonitor
```swift
class MyDeviceActivityMonitor: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        // Start monitoring
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        // Collect and save data
    }
}
```

### 3. Parse Real Data
Update `parseScreenTimeReport()` in `ScreenTimeManager.swift` to parse actual DeviceActivityReport data.

---

## 📖 Resources

- [Apple DeviceActivity Documentation](https://developer.apple.com/documentation/deviceactivity)
- [WWDC21: Meet the Screen Time API](https://developer.apple.com/videos/play/wwdc2021/10123/)
- [FamilyControls Framework](https://developer.apple.com/documentation/familycontrols)

---

*Last Updated: November 2025*

