import Commander
import FaceTimeCore
import Foundation

enum CallCommand {
  static var spec: CommandSpec {
    CommandSpec(
      name: "call",
      abstract: "Initiate a FaceTime call",
      discussion: "Start a FaceTime video or audio call to a phone number or email address.",
      signature: CommandSignatures.withRuntimeFlags(
        CommandSignature(
          arguments: [
            .make(label: "recipient", help: "Phone number, email, or contact name", isOptional: false)
          ],
          options: [],
          flags: [
            .make(label: "audio", names: [.short("a"), .long("audio")], help: "Audio-only call"),
            .make(label: "video", names: [.short("v"), .long("video")], help: "Video call (default)"),
          ]
        )
      ),
      usageExamples: [
        "facetimectl call +1234567890",
        "facetimectl call user@example.com",
        "facetimectl call --audio +1234567890",
        "facetimectl call \"John Doe\"",
      ]
    ) { values, runtime in
      guard let recipient = values.argument(0) else {
        throw FaceTimeCoreError.invalidRecipient("")
      }
      
      let isAudio = values.flag("audio")
      let controller = FaceTimeController()
      
      // Check if recipient is a name - search contacts
      var finalRecipient = recipient
      if !recipient.contains("@") && !recipient.hasPrefix("+") && !recipient.allSatisfy({ $0.isNumber }) {
        if let contact = try await controller.searchContactByName(recipient) {
          if !contact.phoneNumbers.isEmpty {
            finalRecipient = contact.phoneNumbers[0]
          } else if !contact.emailAddresses.isEmpty {
            finalRecipient = contact.emailAddresses[0]
          }
          if runtime.outputFormat == .standard {
            Swift.print("📞 Calling \(contact.name) at \(finalRecipient)...")
          }
        } else {
          throw FaceTimeCoreError.contactNotFound(recipient)
        }
      }
      
      let request = CallRequest(recipient: finalRecipient, isVideo: !isAudio, isAudio: isAudio)
      try await controller.makeCall(request)
      
      if runtime.outputFormat == .standard {
        if isAudio {
          Swift.print("📞 Initiating audio call to \(finalRecipient)")
        } else {
          Swift.print("📹 Initiating video call to \(finalRecipient)")
        }
      } else if runtime.outputFormat == .quiet {
        // Silent
      }
    }
  }
}
