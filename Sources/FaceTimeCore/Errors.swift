import Foundation

public enum FaceTimeCoreError: LocalizedError, Sendable {
  case accessDenied
  case contactsAccessDenied
  case appleEventsAccessDenied
  case invalidRecipient(String)
  case contactNotFound(String)
  case faceTimeNotAvailable
  case callFailed(String)
  case operationFailed(String)
  
  public var errorDescription: String? {
    switch self {
    case .accessDenied:
      return "Access to FaceTime is denied. Please grant permissions in System Settings."
    case .contactsAccessDenied:
      return "Access to Contacts is denied. Please grant permissions in System Settings → Privacy & Security → Contacts."
    case .appleEventsAccessDenied:
      return "Automation access is denied. Please grant permissions in System Settings → Privacy & Security → Automation."
    case .invalidRecipient(let recipient):
      return "Invalid recipient: \(recipient). Use phone number or email address."
    case .contactNotFound(let name):
      return "Contact not found: \(name)"
    case .faceTimeNotAvailable:
      return "FaceTime is not available on this system."
    case .callFailed(let reason):
      return "Call failed: \(reason)"
    case .operationFailed(let reason):
      return "Operation failed: \(reason)"
    }
  }
}
