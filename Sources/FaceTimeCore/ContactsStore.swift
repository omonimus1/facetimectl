import Contacts
import Foundation

public actor ContactsStore {
  private let store = CNContactStore()
  
  public init() {}
  
  public func requestAccess() async throws {
    let status = Self.authorizationStatus()
    switch status {
    case .notDetermined:
      let granted = try await requestAuthorization()
      if !granted {
        throw FaceTimeCoreError.contactsAccessDenied
      }
    case .denied, .restricted:
      throw FaceTimeCoreError.contactsAccessDenied
    case .authorized:
      break
    }
  }
  
  public static func authorizationStatus() -> ContactsAuthorizationStatus {
    ContactsAuthorizationStatus(cnStatus: CNContactStore.authorizationStatus(for: .contacts))
  }
  
  public func requestAuthorization() async throws -> Bool {
    try await store.requestAccess(for: .contacts)
  }
  
  public func searchContacts(query: String) async throws -> [Contact] {
    let keysToFetch: [CNKeyDescriptor] = [
      CNContactIdentifierKey as CNKeyDescriptor,
      CNContactGivenNameKey as CNKeyDescriptor,
      CNContactFamilyNameKey as CNKeyDescriptor,
      CNContactPhoneNumbersKey as CNKeyDescriptor,
      CNContactEmailAddressesKey as CNKeyDescriptor,
    ]
    
    let predicate = CNContact.predicateForContacts(matchingName: query)
    let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
    
    return contacts.map { cnContact in
      Contact(
        id: cnContact.identifier,
        name: "\(cnContact.givenName) \(cnContact.familyName)".trimmingCharacters(in: .whitespaces),
        phoneNumbers: cnContact.phoneNumbers.map { $0.value.stringValue },
        emailAddresses: cnContact.emailAddresses.map { $0.value as String }
      )
    }
  }
  
  public func allContacts() async throws -> [Contact] {
    let keysToFetch: [CNKeyDescriptor] = [
      CNContactIdentifierKey as CNKeyDescriptor,
      CNContactGivenNameKey as CNKeyDescriptor,
      CNContactFamilyNameKey as CNKeyDescriptor,
      CNContactPhoneNumbersKey as CNKeyDescriptor,
      CNContactEmailAddressesKey as CNKeyDescriptor,
    ]
    
    var allContacts: [CNContact] = []
    let request = CNContactFetchRequest(keysToFetch: keysToFetch)
    
    try store.enumerateContacts(with: request) { contact, _ in
      allContacts.append(contact)
    }
    
    return allContacts.map { cnContact in
      Contact(
        id: cnContact.identifier,
        name: "\(cnContact.givenName) \(cnContact.familyName)".trimmingCharacters(in: .whitespaces),
        phoneNumbers: cnContact.phoneNumbers.map { $0.value.stringValue },
        emailAddresses: cnContact.emailAddresses.map { $0.value as String }
      )
    }
  }
}
