import Commander
import FaceTimeCore
import Foundation

enum StatusCommand {
  static var spec: CommandSpec {
    CommandSpec(
      name: "status",
      abstract: "Show FaceTime call status",
      discussion: "Display current call status and authorization status.",
      signature: CommandSignatures.withRuntimeFlags(CommandSignature()),

      usageExamples: [
        "facetimectl status",
        "facetimectl status --json",
      ]
    ) { _, runtime in
      let controller = FaceTimeController()
      let authStatus = await controller.getContactsAuthorizationStatus()
      
      if runtime.outputFormat == .standard {
        Swift.print("FaceTime CLI Status")
        Swift.print("═══════════════════")
        OutputRenderer.printAuthorizationStatus(authStatus, format: .standard)
        
        // Try to get call status (requires automation permissions)
        do {
          let callStatus = try await controller.getActiveCallStatus()
          OutputRenderer.printCallStatus(callStatus, format: .standard)
        } catch {
          Swift.print("Call status: Unable to determine (automation access may be required)")
        }
      } else {
        OutputRenderer.printAuthorizationStatus(authStatus, format: runtime.outputFormat)
      }
    }
  }
}
