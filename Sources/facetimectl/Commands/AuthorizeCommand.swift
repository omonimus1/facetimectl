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
          if runtime.outputFormat == .standard {
            Console.printError("")
            Console.printError("⚠️  Authorization dialog could not be displayed.")
            Console.printError("   CLI tools require manual permission grant.")
            Console.printError("")
            Console.printError("To grant Contacts access:")
            Console.printError("   1. Open System Settings")
            Console.printError("   2. Go to Privacy & Security → Contacts")
            Console.printError("   3. Click the [+] button")
            Console.printError("   4. Add 'Terminal' (or your terminal app)")
            Console.printError("   5. Try running this command again")
            Console.printError("")
          }
          throw FaceTimeCoreError.contactsAccessDenied
        }
      } else {
        OutputRenderer.printAuthorizationStatus(currentStatus, format: runtime.outputFormat)
        
        if runtime.outputFormat == .standard {
          if currentStatus == .denied || currentStatus == .restricted {
            Console.printError("")
            Console.printError("⚠️  Contacts access is \(currentStatus.displayName.lowercased()).")
            Console.printError("")
            Console.printError("To enable access:")
            Console.printError("   1. Open System Settings")
            Console.printError("   2. Go to Privacy & Security → Contacts")
            Console.printError("   3. Find 'Terminal' in the list")
            Console.printError("   4. Enable the checkbox")
            Console.printError("   5. Try running this command again")
            Console.printError("")
          }
        }
        
        if currentStatus != .authorized {
          throw FaceTimeCoreError.contactsAccessDenied
        }
      }
    }
  }
}
