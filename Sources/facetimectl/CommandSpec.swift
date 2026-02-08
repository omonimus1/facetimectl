import Commander
import Foundation

struct CommandSpec {
  let name: String
  let abstract: String
  let discussion: String?
  let signature: CommandSignature
  let usageExamples: [String]
  let run: (ParsedValues, RuntimeOptions) async throws -> Void
  
  var descriptor: CommandDescriptor {
    CommandDescriptor(
      name: name,
      abstract: abstract,
      discussion: discussion,
      signature: signature,
      subcommands: []
    )
  }
}
