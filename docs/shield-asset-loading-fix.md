# Shield Extension Asset Loading Issue

## Problem
Cat images failed to load in `ScrollKittyShield` extension despite `UIImage(named:)` working correctly in main app.

**Symptom:** Shield displayed iOS default hourglass icon instead of cat images.

## Root Cause
App extensions have separate bundles. When using Xcode's file synchronization system (`PBXFileSystemSynchronizedRootGroup`), shared asset catalogs in the main app folder aren't automatically copied to extension bundles.

**Initial (broken) code:**
```swift
// ScrollKittyShield/ShieldConfigurationExtension.swift
private func getCatImage(for band: Int) -> UIImage? {
    let imageName: String
    switch band {
    case 3: imageName = "1_Healthy_Cheerful"
    case 2: imageName = "2_Concerned_Anxious"
    case 1: imageName = "3_Tired_Low-Energy"
    default: imageName = "4_Extremely_Sick"
    }
    return UIImage(named: imageName)  // Returns nil - assets not in extension bundle
}
```

**Project configuration issue:**
```
ScrollKitty/Assets.xcassets  → Main app bundle only
ScrollKittyShield/           → Extension bundle (no assets)
```

## Solution
Create dedicated asset catalog for extension target.

**File structure:**
```
ScrollKittyShield/
├── Assets.xcassets/
│   ├── Contents.json
│   ├── 1_Healthy_Cheerful.imageset/
│   │   ├── 1_Healthy_Cheerful.png
│   │   └── Contents.json
│   ├── 2_Concerned_Anxious.imageset/
│   ├── 3_Tired_Low-Energy.imageset/
│   └── 4_Extremely_Sick.imageset/
└── ShieldConfigurationExtension.swift
```

**Shell commands:**
```bash
# Create extension asset catalog
mkdir -p ScrollKittyShield/Assets.xcassets

# Copy cat images
for img in "1_Healthy_Cheerful" "2_Concerned_Anxious" "3_Tired_Low-Energy" "4_Extremely_Sick"; do
  mkdir -p "ScrollKittyShield/Assets.xcassets/${img}.imageset"
  cp "ScrollKitty/Assets.xcassets/${img}.imageset/${img}.png" \
     "ScrollKittyShield/Assets.xcassets/${img}.imageset/"

  # Create Contents.json
  cat > "ScrollKittyShield/Assets.xcassets/${img}.imageset/Contents.json" <<EOF
{
  "images": [{"filename": "${img}.png", "idiom": "universal"}],
  "info": {"author": "xcode", "version": 1}
}
EOF
done
```

**Final (working) code:**
```swift
// ScrollKittyShield/ShieldConfigurationExtension.swift
private func getCatImage(for band: Int) -> UIImage? {
    let imageName: String
    switch band {
    case 3: imageName = "1_Healthy_Cheerful"
    case 2: imageName = "2_Concerned_Anxious"
    case 1: imageName = "3_Tired_Low-Energy"
    default: imageName = "4_Extremely_Sick"
    }
    // Assets now in extension's own Assets.xcassets
    return UIImage(named: imageName)  // ✅ Works
}
```

## Why This Works
Xcode's file synchronization system automatically includes all files in `ScrollKittyShield/` folder as extension resources, including the new `Assets.xcassets`.

## Alternative Approaches (Not Needed)

**Explicit bundle reference (doesn't work with sync system):**
```swift
UIImage(named: imageName, in: Bundle(for: type(of: self)), compatibleWith: nil)
```

**Manual target membership (conflicts with sync system):**
- Checking target membership box in Xcode File Inspector
- Manually editing `project.pbxproj` to remove from `membershipExceptions`

These approaches fail because synchronized folders manage resources automatically.

## Key Takeaway
For app extensions using file synchronization: duplicate assets into extension folder rather than sharing from main app.
