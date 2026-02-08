import AppKit
import Foundation

public actor FaceTimeController {
  private let contactsStore = ContactsStore()
  
  public init() {}
  
  public func makeCall(_ request: CallRequest) async throws {
    // Ensure contacts access for lookups
    try await contactsStore.requestAccess()
    
    // Validate recipient format
    let recipient = request.recipient.trimmingCharacters(in: .whitespaces)
    guard !recipient.isEmpty else {
      throw FaceTimeCoreError.invalidRecipient(recipient)
    }
    
    // Build FaceTime URL
    let scheme: String
    if request.isAudio {
      scheme = "facetime-audio"
    } else {
      scheme = "facetime"
    }
    
    // Clean phone number or email
    let cleanRecipient = recipient.replacingOccurrences(of: " ", with: "")
      .replacingOccurrences(of: "(", with: "")
      .replacingOccurrences(of: ")", with: "")
      .replacingOccurrences(of: "-", with: "")
    
    guard let url = URL(string: "\(scheme)://\(cleanRecipient)") else {
      throw FaceTimeCoreError.invalidRecipient(recipient)
    }
    
    // Open FaceTime URL
    await MainActor.run {
      NSWorkspace.shared.open(url)
    }
  }
  
  public func searchContactByName(_ name: String) async throws -> Contact? {
    try await contactsStore.requestAccess()
    let contacts = try await contactsStore.searchContacts(query: name)
    return contacts.first
  }
  
  public func listContacts() async throws -> [Contact] {
    try await contactsStore.requestAccess()
    return try await contactsStore.allContacts()
  }
  
  public func getContactsAuthorizationStatus() -> ContactsAuthorizationStatus {
    ContactsStore.authorizationStatus()
  }
  
  // AppleScript-based call status (requires automation permissions)
  public func getActiveCallStatus() async throws -> CallStatus {
    let script = """
    tell application "System Events"
      if exists (process "FaceTime") then
        tell process "FaceTime"
          if exists window 1 then
            return "active"
          else
            return "inactive"
          end if
        end tell
      else
        return "not-running"
      end if
    end tell
    """
    
    let appleScript = NSAppleScript(source: script)
    var error: NSDictionary?
    let result = appleScript?.executeAndReturnError(&error)
    
    if let error = error {
      throw FaceTimeCoreError.operationFailed(error.description)
    }
    
    let status = result?.stringValue ?? "unknown"
    let isActive = status == "active"
    
    return CallStatus(isActive: isActive, participant: nil, duration: nil)
  }
  
  // End active call via AppleScript
  public func endActiveCall() async throws {
    let script = """
    tell application "FaceTime"
      if exists window 1 then
        close window 1
      end if
    end tell
    """
    
    let appleScript = NSAppleScript(source: script)
    var error: NSDictionary?
    appleScript?.executeAndReturnError(&error)
    
    if let error = error {
      throw FaceTimeCoreError.callFailed(error.description)
    }
  }
}
