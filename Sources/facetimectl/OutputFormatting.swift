import FaceTimeCore
import Foundation

enum OutputRenderer {
  static func printContacts(_ contacts: [Contact], format: OutputFormat) {
    switch format {
    case .json:
      if let data = try? JSONEncoder().encode(contacts),
         let json = String(data: data, encoding: .utf8) {
        Swift.print(json)
      }
    case .plain:
      for contact in contacts {
        Swift.print("\(contact.id)\t\(contact.name)")
      }
    case .quiet:
      Swift.print(contacts.count)
    case .standard:
      if contacts.isEmpty {
        Swift.print("No contacts found")
      } else {
        for contact in contacts {
          Swift.print("📇 \(contact.name)")
          if !contact.phoneNumbers.isEmpty {
            Swift.print("   Phone: \(contact.phoneNumbers.joined(separator: ", "))")
          }
          if !contact.emailAddresses.isEmpty {
            Swift.print("   Email: \(contact.emailAddresses.joined(separator: ", "))")
          }
        }
      }
    }
  }
  
  static func printAuthorizationStatus(_ status: ContactsAuthorizationStatus, format: OutputFormat) {
    switch format {
    case .json:
      let dict: [String: Any] = ["status": status.rawValue, "authorized": status.isAuthorized]
      if let data = try? JSONSerialization.data(withJSONObject: dict),
         let json = String(data: data, encoding: .utf8) {
        Swift.print(json)
      }
    case .plain, .quiet:
      Swift.print(status.rawValue)
    case .standard:
      Swift.print("Contacts authorization: \(status.displayName)")
    }
  }
  
  static func printCallStatus(_ status: CallStatus, format: OutputFormat) {
    switch format {
    case .json:
      if let data = try? JSONEncoder().encode(status),
         let json = String(data: data, encoding: .utf8) {
        Swift.print(json)
      }
    case .plain:
      Swift.print(status.isActive ? "active" : "inactive")
    case .quiet:
      Swift.print(status.isActive ? "1" : "0")
    case .standard:
      if status.isActive {
        Swift.print("📞 Active call")
        if let participant = status.participant {
          Swift.print("   Participant: \(participant)")
        }
      } else {
        Swift.print("No active calls")
      }
    }
  }
}
