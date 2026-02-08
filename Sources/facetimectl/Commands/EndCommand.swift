import Commander
import FaceTimeCore
import Foundation

enum EndCommand {
  static var spec: CommandSpec {
    CommandSpec(
      name: "end",
      abstract: "End active FaceTime call",
      discussion: "Terminate the currently active FaceTime call. Requires automation permissions.",
      signature: CommandSignatures.withRuntimeFlags(CommandSignature()),

      usageExamples: [
        "facetimectl end",
        "facetimectl end --quiet",
      ]
    ) { _, runtime in
      let controller = FaceTimeController()
      try await controller.endActiveCall()
      
      if runtime.outputFormat == .standard {
        Swift.print("✅ Call ended")
      } else if runtime.outputFormat == .json {
        Swift.print("{\"status\":\"ended\"}")
      }
    }
  }
}
