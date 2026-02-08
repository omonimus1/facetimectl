import Commander
import FaceTimeCore
import Foundation

enum AuthorizeCommand {
  static var spec: CommandSpec {
    CommandSpec(
      name: "authorize",
      abstract: "Request Contacts access",
      discussion: "Triggers the Contacts permission prompt when available.",
      signature: CommandSignatures.withRuntimeFlags(CommandSignature()),

      usageExamples: [
        "facetimectl authorize",
        "facetimectl authorize --json",
      ]
    ) { _, runtime in
      let controller = FaceTimeController()
      let currentStatus = await controller.getContactsAuthorizationStatus()
      
      if currentStatus == .notDetermined {
        let store = ContactsStore()
        let granted = try await store.requestAuthorization()
        let newStatus = await controller.getContactsAuthorizationStatus()
        OutputRenderer.printAuthorizationStatus(newStatus, format: runtime.outputFormat)
        
        if !granted {
          throw FaceTimeCoreError.contactsAccessDenied
        }
      } else {
        OutputRenderer.printAuthorizationStatus(currentStatus, format: runtime.outputFormat)
        
        if runtime.outputFormat == .standard {
          if currentStatus == .denied {
            Swift.print("\n⚠️  To enable access:")
            Swift.print("   1. Open System Settings")
            Swift.print("   2. Go to Privacy & Security → Contacts")
            Swift.print("   3. Enable access for Terminal (or facetimectl)")
          }
        }
        
        if currentStatus != .authorized {
          throw FaceTimeCoreError.contactsAccessDenied
        }
      }
    }
  }
}
