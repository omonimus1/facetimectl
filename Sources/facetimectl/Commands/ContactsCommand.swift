import Commander
import FaceTimeCore
import Foundation

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
      let controller = FaceTimeController()
      
      let contacts: [Contact]
      if let searchQuery = values.option("search") {
        contacts = try await controller.searchContactByName(searchQuery).map { [$0] } ?? []
      } else {
        contacts = try await controller.listContacts()
      }
      
      OutputRenderer.printContacts(contacts, format: runtime.outputFormat)
    }
  }
}
