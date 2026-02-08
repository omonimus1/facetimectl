import Contacts
import Foundation

public enum ContactsAuthorizationStatus: String, Codable, Sendable, Equatable {
  case notDetermined = "not-determined"
  case restricted = "restricted"
  case denied = "denied"
  case authorized = "authorized"
  
  public init(cnStatus: CNAuthorizationStatus) {
    switch cnStatus {
    case .notDetermined:
      self = .notDetermined
    case .restricted:
      self = .restricted
    case .denied:
      self = .denied
    case .authorized:
      self = .authorized
    @unknown default:
      self = .denied
    }
  }
  
  public var isAuthorized: Bool {
    self == .authorized
  }
  
  public var displayName: String {
    switch self {
    case .notDetermined:
      return "Not determined"
    case .restricted:
      return "Restricted"
    case .denied:
      return "Denied"
    case .authorized:
      return "Authorized"
    }
  }
}
