# Manual tests

## Scope
Run on a local GUI session (not SSH-only) so the Contacts and FaceTime permission prompts can appear.

## Prerequisites
- FaceTime.app must be configured and signed in
- Test device must have at least one contact with FaceTime-enabled phone/email
- Microphone and Camera permissions may be requested by FaceTime.app

## Test data
- Use existing contacts or create a test contact with a known FaceTime-enabled device
- Prepare test phone numbers and emails for calling

## Checklist
- authorize: `facetimectl authorize`
  - Should prompt for Contacts access on first run
  - Verify permission granted in System Settings → Privacy & Security → Contacts
- status: `facetimectl status`
  - Should show authorization status
  - Should show call status (requires Automation permissions)
- contacts: `facetimectl contacts`
  - Should list all contacts with phone numbers and emails
- search: `facetimectl contacts --search "John"`
  - Should filter contacts by name
- call by phone: `facetimectl call +1234567890`
  - Should open FaceTime.app with video call
  - Verify FaceTime window appears
- call by email: `facetimectl call user@example.com`
  - Should open FaceTime.app with video call
- audio call: `facetimectl call --audio +1234567890`
  - Should open FaceTime.app with audio-only call
- call by name: `facetimectl call "John Doe"`
  - Should search contacts and initiate call
  - Should error if contact not found
- end call: `facetimectl end`
  - Should close active FaceTime window
  - Requires Automation permissions for Terminal/facetimectl
- JSON output: `facetimectl contacts --json`
  - Should output valid JSON array
- plain output: `facetimectl contacts --plain`
  - Should output tab-separated values
- quiet mode: `facetimectl contacts --quiet`
  - Should output only count

## Permission flow
1. First run should prompt for Contacts access
2. Call status/end operations require Automation access:
   - System Settings → Privacy & Security → Automation
   - Enable Terminal (or facetimectl) → FaceTime.app

## Results
- Date:
- Machine:
- macOS version:
- Permission state before/after:
  - Contacts: 
  - Automation: 
- FaceTime account signed in: 
- Notes:
