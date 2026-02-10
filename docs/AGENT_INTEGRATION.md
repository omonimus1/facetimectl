# Agent Integration Guide for facetimectl

## Current Status

As an AI agent attempting to use facetimectl, here's what I discovered:

### Authorization Status
```bash
$ facetimectl status
FaceTime CLI Status
═══════════════════
Contacts authorization: Not determined
No active calls
```

### Authorization Challenges

**Issue**: macOS Contacts authorization requires a TCC (Transparency, Consent, and Control) prompt that must be accepted by the user through a system dialog. CLI tools running in Terminal need special handling.

## Agent Workflow for Making FaceTime Calls

### Step 1: Check Authorization Status

```python
import subprocess
import json

def check_authorization():
    """Check if facetimectl has Contacts access"""
    result = subprocess.run(
        ['facetimectl', 'status', '--json'],
        capture_output=True,
        text=True
    )
    status = json.loads(result.stdout)
    return status['authorized']

# Example
authorized = check_authorization()
print(f"Authorization status: {authorized}")
```

### Step 2: Request Authorization (User Interaction Required)

```python
def request_authorization():
    """
    Request Contacts authorization.
    Note: This will show a macOS system dialog that the USER must approve.
    """
    result = subprocess.run(['facetimectl', 'authorize'], capture_output=True)
    
    if result.returncode == 0:
        print("✓ Authorization granted")
        return True
    else:
        print("✗ Authorization denied or pending")
        print("→ User must grant access in System Settings > Privacy & Security > Contacts")
        return False
```

### Step 3: Search for Contact

```python
def find_contact(name):
    """Search for a contact by name"""
    result = subprocess.run(
        ['facetimectl', 'contacts', '--json'],
        capture_output=True,
        text=True
    )
    
    if result.returncode != 0:
        raise Exception("Contacts access denied")
    
    contacts = json.loads(result.stdout)
    
    # Search for matching contact
    matches = [c for c in contacts if name.lower() in c.get('name', '').lower()]
    return matches

# Example
contacts = find_contact("John")
for contact in contacts:
    print(f"Found: {contact['name']}")
    for number in contact.get('phoneNumbers', []):
        print(f"  Phone: {number}")
    for email in contact.get('emails', []):
        print(f"  Email: {email}")
```

### Step 4: Initiate FaceTime Call

```python
def make_facetime_call(identifier, audio_only=False):
    """
    Make a FaceTime call to a phone number or email.
    
    Args:
        identifier: Phone number (e.g., "+1234567890") or email
        audio_only: If True, makes an audio-only call
    """
    cmd = ['facetimectl', 'call', identifier]
    if audio_only:
        cmd.append('--audio')
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode == 0:
        print(f"✓ Call initiated to {identifier}")
        return True
    else:
        print(f"✗ Failed to call {identifier}")
        print(result.stderr)
        return False

# Example usage
make_facetime_call("user@example.com")
make_facetime_call("+1234567890", audio_only=True)
```

### Step 5: Monitor Call Status

```python
def check_call_status():
    """Check if there's an active FaceTime call"""
    result = subprocess.run(
        ['facetimectl', 'status', '--json'],
        capture_output=True,
        text=True
    )
    status = json.loads(result.stdout)
    
    # Note: Call detection via AppleScript may have limitations
    return status.get('hasActiveCall', False)

# Example
if check_call_status():
    print("📞 Active call detected")
else:
    print("No active calls")
```

### Step 6: End Call

```python
def end_call():
    """End the active FaceTime call"""
    result = subprocess.run(['facetimectl', 'end'], capture_output=True)
    if result.returncode == 0:
        print("✓ Call ended")
        return True
    return False
```

## Complete Agent Example

```python
#!/usr/bin/env python3
"""
FaceTime Agent - Automated calling assistant
"""

import subprocess
import json
import sys
import time

class FaceTimeAgent:
    def __init__(self):
        self.authorized = False
    
    def check_setup(self):
        """Verify facetimectl is installed and authorized"""
        try:
            result = subprocess.run(
                ['facetimectl', 'status', '--json'],
                capture_output=True,
                text=True,
                check=True
            )
            status = json.loads(result.stdout)
            self.authorized = status['authorized']
            
            if not self.authorized:
                print("⚠️  Contacts access not granted")
                print("Run: facetimectl authorize")
                print("Then approve in System Settings > Privacy & Security > Contacts")
                return False
            
            return True
            
        except FileNotFoundError:
            print("❌ facetimectl not found. Install with:")
            print("   brew tap omonimus1/facetimectl")
            print("   brew install facetimectl")
            return False
    
    def find_contact(self, query):
        """Search for contacts by name"""
        result = subprocess.run(
            ['facetimectl', 'contacts', '--json'],
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            raise Exception("Failed to access contacts")
        
        contacts = json.loads(result.stdout)
        matches = [
            c for c in contacts 
            if query.lower() in c.get('name', '').lower()
        ]
        
        return matches
    
    def call(self, identifier, audio_only=False):
        """Initiate a FaceTime call"""
        cmd = ['facetimectl', 'call', identifier]
        if audio_only:
            cmd.append('--audio')
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.returncode == 0
    
    def make_call_by_name(self, name, audio_only=False):
        """
        Find a contact by name and call them.
        
        Returns:
            bool: True if call was initiated successfully
        """
        if not self.check_setup():
            return False
        
        # Search for contact
        print(f"🔍 Searching for '{name}'...")
        contacts = self.find_contact(name)
        
        if not contacts:
            print(f"❌ No contacts found matching '{name}'")
            return False
        
        if len(contacts) > 1:
            print(f"📋 Multiple contacts found:")
            for i, contact in enumerate(contacts, 1):
                print(f"  {i}. {contact['name']}")
            print("Please be more specific.")
            return False
        
        contact = contacts[0]
        print(f"✓ Found: {contact['name']}")
        
        # Get preferred identifier (email or phone)
        identifier = None
        if contact.get('emails'):
            identifier = contact['emails'][0]
            print(f"📧 Using email: {identifier}")
        elif contact.get('phoneNumbers'):
            identifier = contact['phoneNumbers'][0]
            print(f"📱 Using phone: {identifier}")
        else:
            print("❌ No contact method (email/phone) available")
            return False
        
        # Make the call
        call_type = "audio" if audio_only else "video"
        print(f"📞 Initiating {call_type} call...")
        
        if self.call(identifier, audio_only):
            print(f"✓ Call started to {contact['name']}")
            return True
        else:
            print(f"✗ Failed to call {contact['name']}")
            return False

# Usage Examples
if __name__ == "__main__":
    agent = FaceTimeAgent()
    
    # Example 1: Call by name
    agent.make_call_by_name("John Doe")
    
    # Example 2: Audio-only call
    agent.make_call_by_name("Jane Smith", audio_only=True)
    
    # Example 3: Direct call by identifier
    if agent.check_setup():
        agent.call("user@example.com")
```

## Shell Script Alternative

```bash
#!/bin/bash
# facetime-agent.sh - Shell-based FaceTime agent

check_authorization() {
    local status=$(facetimectl status --json | jq -r '.authorized')
    if [ "$status" != "true" ]; then
        echo "⚠️  Authorization required"
        echo "Run: facetimectl authorize"
        return 1
    fi
    return 0
}

call_by_name() {
    local name="$1"
    local audio_flag="${2:-}"
    
    if ! check_authorization; then
        return 1
    fi
    
    echo "🔍 Searching for '$name'..."
    
    # Get contacts and find match
    local contacts=$(facetimectl contacts --json)
    local match=$(echo "$contacts" | jq -r --arg name "$name" \
        '.[] | select(.name | ascii_downcase | contains($name | ascii_downcase))')
    
    if [ -z "$match" ]; then
        echo "❌ No contact found: $name"
        return 1
    fi
    
    local contact_name=$(echo "$match" | jq -r '.name')
    local identifier=$(echo "$match" | jq -r '.emails[0] // .phoneNumbers[0]')
    
    if [ -z "$identifier" ] || [ "$identifier" = "null" ]; then
        echo "❌ No contact method available for $contact_name"
        return 1
    fi
    
    echo "✓ Found: $contact_name"
    echo "📞 Calling $identifier..."
    
    if [ -n "$audio_flag" ]; then
        facetimectl call "$identifier" --audio
    else
        facetimectl call "$identifier"
    fi
}

# Usage
call_by_name "John Doe"
call_by_name "Jane" "--audio"
```

## Current Limitations & Solutions

### Issue 1: Authorization Not Working in Terminal

**Problem**: Running from a terminal may not trigger the TCC prompt properly.

**Solution**:
1. Build the app with proper code signing
2. Add the app to Full Disk Access in System Settings
3. Or manually grant Terminal access to Contacts:
   ```bash
   # Check current permissions
   open "x-apple.systempreferences:com.apple.preference.security?Privacy_Contacts"
   ```

### Issue 2: Call Status Detection

**Current**: Uses AppleScript to detect active calls, which may have limitations.

**Enhancement Needed**: Check the implementation in FaceTimeController.swift

### Issue 3: No OAuth/API Authentication

**Note**: FaceTime uses macOS's built-in authentication. No separate OAuth or API keys needed. The app inherits the user's FaceTime authentication.

## Recommended Setup for Agents

1. **Install facetimectl**:
   ```bash
   brew tap omonimus1/facetimectl
   brew install facetimectl
   ```

2. **Grant Contacts Permission**:
   - Run `facetimectl authorize`
   - Approve in System Settings > Privacy & Security > Contacts
   - Add Terminal/your app to the allowed list

3. **Verify Setup**:
   ```bash
   facetimectl status
   facetimectl contacts --json | jq '.[0]'
   ```

4. **Test Call**:
   ```bash
   facetimectl call user@example.com
   ```

## Authentication Summary

✅ **No API Keys Required** - Uses macOS FaceTime  
✅ **No OAuth Flow** - Uses system authentication  
⚠️ **Contacts Permission Required** - One-time TCC prompt  
⚠️ **User Must Be Logged into FaceTime** - Uses active account  

The main "authentication" is simply ensuring the user has:
1. Granted Contacts access to facetimectl
2. Is logged into FaceTime on their Mac

Once these are satisfied, agents can automate calls programmatically!
