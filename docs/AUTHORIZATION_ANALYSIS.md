# Authorization Failure Analysis for facetimectl

## Problem Statement
Agents (or users) running `facetimectl authorize` get "Access Denied" even on first run, preventing any Contacts access.

## Root Cause Analysis

### Issue 1: CLI Apps Can't Trigger TCC Prompts Reliably

**Location**: `ContactsStore.swift` line 17-22

```swift
public func requestAuthorization() async throws -> Bool {
  try await store.requestAccess(for: .contacts)
}
```

**Problem**: 
- `CNContactStore.requestAccess(for:)` requires a **GUI application context** to show the TCC prompt
- CLI tools running in Terminal **inherit Terminal's permissions**, not their own
- The system dialog needs a **bundle identifier** and **Info.plist** to show properly
- When run as a CLI binary, the prompt may not appear at all

**Why It Fails**:
1. Terminal itself must have Contacts access to pass it to child processes
2. The CLI binary doesn't have a proper app bundle structure
3. macOS TCC (Transparency, Consent, Control) doesn't trust unsigned CLI tools
4. The authorization request silently fails without showing a dialog

### Issue 2: Info.plist Not Embedded in CLI Binary

**Location**: `Sources/facetimectl/Resources/Info.plist`

```xml
<key>NSContactsUsageDescription</key>
<string>Access your contacts to initiate FaceTime calls.</string>
```

**Problem**:
- The Info.plist exists but may not be properly embedded in the final binary
- The linker flags attempt to embed it, but this doesn't work the same as a proper app bundle
- Without a valid Info.plist at runtime, TCC won't show the authorization dialog

**From Package.swift**:
```swift
linkerSettings: [
  .unsafeFlags([
    "-Xlinker", "-sectcreate",
    "-Xlinker", "__TEXT",
    "-Xlinker", "__info_plist",
    "-Xlinker", "Sources/facetimectl/Resources/Info.plist",
  ]),
]
```

This embeds the plist in a `__TEXT` section, but macOS TCC looks for it in a **proper app bundle** structure.

### Issue 3: Authorization Check Returns False Immediately

**Location**: `ContactsStore.swift` line 9-19

```swift
public func requestAccess() async throws {
  let status = Self.authorizationStatus()
  switch status {
  case .notDetermined:
    let granted = try await requestAuthorization()
    if !granted {
      throw FaceTimeCoreError.contactsAccessDenied  // ← Throws here
    }
  case .denied, .restricted:
    throw FaceTimeCoreError.contactsAccessDenied
  case .authorized:
    break
  }
}
```

**Flow**:
1. Status is `.notDetermined` (correct)
2. Calls `requestAuthorization()` 
3. Authorization request fails silently (no dialog shown)
4. Returns `false`
5. Immediately throws `contactsAccessDenied`
6. User sees "Access Denied" before ever seeing a prompt

### Issue 4: No App Bundle Structure

**Current Structure**:
```
.build/release/facetimectl     ← Single binary file
```

**What TCC Expects**:
```
facetimectl.app/
  Contents/
    MacOS/
      facetimectl              ← Binary
    Info.plist                 ← Here!
    Resources/
```

Without this structure, TCC treats it as an **unsigned CLI tool** and refuses to show authorization dialogs.

## Why Authorization Cannot Work for Agents

### Technical Barriers:

1. **No GUI Context**: Agents run headless - can't show system dialogs
2. **Terminal Sandboxing**: Agents running in Terminal inherit Terminal's restricted permissions
3. **Code Signing Required**: TCC requires code-signed apps with valid entitlements
4. **Bundle Structure Required**: Must be a proper .app bundle, not a CLI binary
5. **User Interaction Required**: macOS **by design** requires user to click "Allow" button

### Current Authorization Flow (Broken):

```
Agent calls facetimectl authorize
  ↓
requestAuthorization() attempts to show dialog
  ↓
macOS TCC checks:
  - Is this a signed app? ❌ No
  - Does it have proper bundle? ❌ No  
  - Is it running in GUI context? ❌ No
  ↓
Request silently fails (returns false)
  ↓
Code throws contactsAccessDenied
  ↓
Agent sees: "Access Denied"
```

## Solutions

### Solution 1: Manual Permission Grant (Current Workaround)

**Have user manually grant Terminal access**:

1. Open **System Settings**
2. Go to **Privacy & Security → Contacts**
3. Click **+** and add **Terminal.app**
4. Now `facetimectl` inherits Terminal's access

**Verification**:
```bash
# After manual grant:
facetimectl status
# Should show: "Contacts authorization: Authorized"
```

**Problem**: Only works if run from Terminal, not from standalone agents.

### Solution 2: Build as Proper macOS App Bundle ⭐ RECOMMENDED

**Create an app bundle structure**:

```bash
# New build target in Package.swift
.product(
  name: "FaceTime.app",
  targets: ["facetimectl"]
)
```

**Post-build script**:
```bash
#!/bin/bash
# Package as .app bundle
mkdir -p FaceTime.app/Contents/MacOS
mkdir -p FaceTime.app/Contents/Resources
cp .build/release/facetimectl FaceTime.app/Contents/MacOS/
cp Sources/facetimectl/Resources/Info.plist FaceTime.app/Contents/
```

**Then**:
- Code sign the app: `codesign --force --sign - FaceTime.app`
- Run from bundle: `FaceTime.app/Contents/MacOS/facetimectl authorize`
- Dialog will appear properly

### Solution 3: Use Helper App Pattern

**Create a separate GUI helper app**:

```swift
// FaceTimeHelper.app - GUI app that requests permissions
// Then facetimectl CLI uses the helper's permissions

// In helper app:
class PermissionManager {
  func requestAllPermissions() {
    CNContactStore().requestAccess(for: .contacts) { granted, _ in
      // Dialog appears because we're a GUI app
    }
  }
}
```

**Flow**:
1. User runs `facetimectl-setup` (GUI app)
2. Setup app requests all permissions with dialogs
3. Creates auth token file
4. CLI reads token and works

### Solution 4: Add Proper Entitlements

**Create entitlements file**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.personal-information.contacts</key>
    <true/>
    <key>com.apple.security.automation.apple-events</key>
    <true/>
</dict>
</plist>
```

**Sign with entitlements**:
```bash
codesign --force --sign - \
  --entitlements facetimectl.entitlements \
  --options runtime \
  .build/release/facetimectl
```

### Solution 5: XPC Service Pattern (Advanced)

**Create an XPC service** that runs as a privileged helper:
- Service runs with proper permissions
- CLI communicates via XPC
- Service makes actual API calls
- Requires more complex setup but most robust

## Recommended Fix for Agent Use

### Short Term: Documentation Update

Update docs to explain:

```markdown
## For Agent Integration

facetimectl requires Contacts access. For automated/agent use:

### Option A: Grant Terminal Access (Simplest)
1. System Settings → Privacy & Security → Contacts
2. Add Terminal.app
3. Agents running in Terminal now work

### Option B: Use API Directly (Bypass CLI)
Instead of calling facetimectl CLI, agents should:
- Import FaceTimeCore as a Swift package
- Request permissions directly with GUI context
- Use FaceTimeController APIs programmatically

### Option C: Pre-authorized System (Production)
- Deploy to Macs with pre-configured PPPC profiles
- Use MDM to grant permissions
- Enterprise deployment only
```

### Long Term: Code Changes

**1. Add proper app bundle build target**:
```swift
// In Package.swift
.product(
  name: "FaceTimeKit.app",
  targets: ["facetimectl"]
)
```

**2. Add setup assistant GUI**:
```swift
// New target: FaceTimeSetup.app
// Requests all permissions with proper dialogs
// Saves authorization state
```

**3. Improve error messages**:
```swift
// In AuthorizeCommand.swift
if currentStatus == .notDetermined {
  print("⚠️  Cannot show authorization dialog from CLI")
  print("")
  print("Please grant access manually:")
  print("1. Open System Settings")
  print("2. Privacy & Security → Contacts")
  print("3. Add Terminal.app (or your app)")
  print("")
  print("Or use the FaceTimeSetup.app GUI helper")
}
```

**4. Provide framework target**:
```swift
// Allow agents to import FaceTimeCore directly
// Avoid CLI authorization issues entirely
```

## Testing the Fix

After implementing proper app bundle:

```bash
# Build as app bundle
make build-app

# Run setup
./FaceTime.app/Contents/MacOS/facetimectl authorize
# ✓ Dialog appears!
# ✓ User clicks "Allow"

# Verify
./FaceTime.app/Contents/MacOS/facetimectl status
# ✓ "Contacts authorization: Authorized"

# Now CLI works too
facetimectl contacts
# ✓ Lists contacts
```

## Summary

**Current State**:
- ❌ CLI binary can't trigger TCC dialogs
- ❌ No app bundle structure
- ❌ No code signing
- ❌ Silent failures confuse users
- ❌ Agents can't get authorization programmatically

**What's Needed**:
- ✅ Proper .app bundle structure
- ✅ Code signing with entitlements
- ✅ GUI helper app for initial setup
- ✅ Better error messages explaining manual grant
- ✅ Framework target for direct API access

**Best Solution for Agents**:
Use FaceTimeCore as a Swift package dependency and call APIs directly, avoiding CLI authorization issues entirely.
