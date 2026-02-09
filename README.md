# facetimectl
AI agents meet FaceTime 📞
[![CodeQL](https://github.com/omonimus1/facetimectl/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/omonimus1/facetimectl/actions/workflows/github-code-scanning/codeql)
[![CI](https://github.com/omonimus1/facetimectl/actions/workflows/ci.yml/badge.svg)](https://github.com/omonimus1/facetimectl/actions/workflows/ci.yml)
[![Dependabot Updates](https://github.com/omonimus1/facetimectl/actions/workflows/dependabot/dependabot-updates/badge.svg)](https://github.com/omonimus1/facetimectl/actions/workflows/dependabot/dependabot-updates)

Fast CLI for FaceTime on macOS - make calls from the terminal.

## Features
- 📞 Make FaceTime audio/video calls from command line
- 📇 Search and list contacts
- 📊 Check call status
- 🤖 Perfect for AI agent integrations
- 🔐 Handles permissions automatically

## Install

### Homebrew (Recommended)
```bash
brew tap omonimus1/facetimectl
brew install facetimectl
```

### From source
```bash
git clone https://github.com/omonimus1/facetimectl.git
cd facetimectl
make build
# binary at ./bin/facetimectl
```

> **Note:** See [brew-release.md](brew-release.md) for complete Homebrew publishing instructions.

## Requirements

- macOS 14+ (Sonoma or later)
- Swift 6.0+
- Permissions required:
  - Contacts (System Settings → Privacy & Security → Contacts)
  - Automation for call management (System Settings → Privacy & Security → Automation)

## Usage

### Make Calls
```bash
# Video call by phone number
facetimectl call +1234567890

# Audio call by email
facetimectl call --audio user@example.com

# Call by contact name
facetimectl call "John Doe"
```

### Manage Contacts
```bash
# List all contacts
facetimectl contacts

# Search for contact
facetimectl contacts --search John

# JSON output for parsing
facetimectl contacts --json
```

### Call Management
```bash
# Check status
facetimectl status

# End active call
facetimectl end
```

### Authorization
```bash
# Request permissions
facetimectl authorize

# Check authorization status
facetimectl status
```

## Output Formats

- `--json` - JSON output for parsing
- `--plain` - Tab-separated plain text
- `--quiet` - Minimal output (counts/status only)

## How It Works

### Permission System

The app uses multiple macOS frameworks:

1. **Contacts Framework** (`CNContactStore`) - Access contacts
2. **FaceTime URL Schemes** (`facetime://`, `facetime-audio://`) - Initiate calls
3. **AppleScript** - Monitor/control FaceTime app (optional, requires automation permissions)

### Info.plist Keys

Required for macOS permission dialogs:
- `NSContactsUsageDescription` - Access contacts
- `NSAppleEventsUsageDescription` - Control FaceTime app
- `NSCameraUsageDescription` - Camera access (inherited from FaceTime)
- `NSMicrophoneUsageDescription` - Microphone access (inherited from FaceTime)

### Architecture

```
facetimectl CLI
    ↓
FaceTimeController (actor)
    ↓
┌──────────────────┬────────────────────┐
ContactsStore      FaceTime URLs        AppleScript
(CNContactStore)   (facetime://)        (NSAppleScript)
    ↓                   ↓                     ↓
iOS Contacts       macOS FaceTime       FaceTime.app
```

## For AI Agents

Perfect for agent workflows:

```bash
# Agent initiates call
facetimectl call --audio "+1234567890" --json

# Agent checks if call is active
facetimectl status --json

# Agent ends call after completion
facetimectl end --json
```

All commands support `--json` for easy parsing.

## Development

```bash
# Build and run
make facetimectl ARGS="status"

# Run tests
make test

# Format code
make format

# Full check
make check
```

## Limitations

- FaceTime must be configured on the Mac
- Requires valid Apple ID signed into FaceTime
- Recipient must have FaceTime enabled
- Call status monitoring requires automation permissions
- Cannot answer incoming calls (only initiate outgoing)

## Privacy & Security

- All contact data stays local
- No network requests (except FaceTime calls)
- Permissions requested on first use
- Open source - audit the code yourself

## License

MIT

## Credits

Inspired by [remindctl](https://github.com/steipete/remindctl) by Peter Steinberger
