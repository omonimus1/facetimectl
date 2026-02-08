import Foundation

enum HelpPrinter {
  static func printRoot(version: String, rootName: String, commands: [CommandSpec]) {
    Swift.print("\(rootName) \(version)")
    Swift.print("Manage FaceTime calls from the terminal\n")
    Swift.print("USAGE:")
    Swift.print("  \(rootName) <command> [options]\n")
    Swift.print("COMMANDS:")
    for cmd in commands {
      Swift.print("  \(cmd.name.padding(toLength: 12, withPad: " ", startingAt: 0)) \(cmd.abstract)")
    }
    Swift.print("\nOPTIONS:")
    Swift.print("  --help, -h       Show help")
    Swift.print("  --version, -V    Show version")
    Swift.print("  --json           Output as JSON")
    Swift.print("  --plain          Output as plain text")
    Swift.print("  --quiet          Minimal output")
  }
  
  static func printCommand(rootName: String, spec: CommandSpec) {
    Swift.print("\(rootName) \(spec.name)")
    Swift.print(spec.abstract)
    if let discussion = spec.discussion {
      Swift.print("\n\(discussion)")
    }
    Swift.print("\nUSAGE:")
    for example in spec.usageExamples {
      Swift.print("  \(example)")
    }
  }
}
