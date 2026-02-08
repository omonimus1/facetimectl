import Foundation

public struct Contact: Codable, Sendable, Identifiable {
  public let id: String
  public let name: String
  public let phoneNumbers: [String]
  public let emailAddresses: [String]
  
  public init(id: String, name: String, phoneNumbers: [String], emailAddresses: [String]) {
    self.id = id
    self.name = name
    self.phoneNumbers = phoneNumbers
    self.emailAddresses = emailAddresses
  }
}

public struct CallRequest: Sendable {
  public let recipient: String
  public let isVideo: Bool
  public let isAudio: Bool
  
  public init(recipient: String, isVideo: Bool = true, isAudio: Bool = false) {
    self.recipient = recipient
    self.isVideo = isVideo
    self.isAudio = isAudio
  }
}

public struct CallStatus: Codable, Sendable {
  public let isActive: Bool
  public let participant: String?
  public let duration: TimeInterval?
  
  public init(isActive: Bool, participant: String?, duration: TimeInterval?) {
    self.isActive = isActive
    self.participant = participant
    self.duration = duration
  }
}
