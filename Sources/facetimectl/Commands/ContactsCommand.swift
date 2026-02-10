import Commander
import FaceTimeCore
import Foundation

func printContactsAccessError() {
  Console.printError("")
  Console.printError("⚠️  Contacts access not granted.")
  Console.printError("")
  Console.printError("To grant access:")
  Console.printError("   1. Open System Settings")
  Console.printError("   2. Go to Privacy & Security → Contacts")
  Console.printError("   3. Click the [+] button and add 'Terminal'")
  Console.printError("   4. Try running this command again")
  Console.printError("")
}

enum ContactsCommand {
  static var spec: CommandSpec {
    CommandSpec(
      name: "contacts",
      abstract: "List or search contacts",
      discussion: "Display contacts available for FaceTime calls.",
      signature: CommandSignatures.withRuntimeFlags(
        CommandSignature(
          options: [
            .make(label: "search", names: [.short("s"), .long("search")], help: "Search contacts by name", parsing: .singleValue),
          ]
        )
      ),
      usageExamples: [
        "facetimectl contacts",
        "facetimectl contacts --search John",
        "facetimectl contacts --json",
      ]
    ) { values, runtime in
      do {
        let controller = FaceTimeController()
        
        let contacts: [Contact]
        if let searchQuery = values.option("search") {
          contacts = try await controller.searchContactByName(searchQuery).map { [$0] } ?? []
        } else {
          contacts = try await controller.listContacts()
        }
        
        OutputRenderer.printContacts(contacts, format: runtime.outputFormat)
      } catch FaceTimeCoreError.contactsAccessDenied {
        printContactsAccessError()
        throw FaceTimeCoreError.contactsAccessDenied
      }
    }
  }
}
