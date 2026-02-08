import Commander
import FaceTimeCore
import Foundation

struct CommandRouter {
  let rootName = "facetimectl"
  let version = "0.1.0"
  let specs: [CommandSpec]
  let program: Program
  
  init() {
    self.specs = [
      CallCommand.spec,
      ContactsCommand.spec,
      StatusCommand.spec,
      EndCommand.spec,
      AuthorizeCommand.spec,
    ]
    let descriptor = CommandDescriptor(
      name: rootName,
      abstract: "Manage FaceTime calls from the terminal",
      discussion: nil,
      signature: CommandSignature(),
      subcommands: specs.map { $0.descriptor },
      defaultSubcommandName: "status"
    )
    self.program = Program(descriptors: [descriptor])
  }
  
  func run() async -> Int32 {
    await run(argv: CommandLine.arguments)
  }
  
  func run(argv: [String]) async -> Int32 {
    var argv = normalizeArguments(argv)
    
    if argv.contains("--version") || argv.contains("-V") {
      Swift.print(version)
      return 0
    }
    
    if argv.contains("--help") || argv.contains("-h") {
      printHelp(for: argv)
      return 0
    }
    
    do {
      let invocation = try program.resolve(argv: argv)
      guard let commandName = invocation.path.last,
            let spec = specs.first(where: { $0.name == commandName })
      else {
        Console.printError("Unknown command")
        printRootHelp()
        return 1
      }
      let runtime = RuntimeOptions(parsedValues: invocation.parsedValues)
      do {
        try await spec.run(invocation.parsedValues, runtime)
        return 0
      } catch {
        Console.printError(error.localizedDescription)
        return 1
      }
    } catch let error as CommanderProgramError {
      Console.printError(error.description)
      if case .missingSubcommand = error {
        printRootHelp()
      }
      return 1
    } catch {
      Console.printError(error.localizedDescription)
      return 1
    }
  }
  
  private func normalizeArguments(_ argv: [String]) -> [String] {
    guard !argv.isEmpty else { return argv }
    var copy = argv
    copy[0] = URL(fileURLWithPath: argv[0]).lastPathComponent
    return copy
  }
  
  private func printHelp(for argv: [String]) {
    let path = helpPath(from: argv)
    if path.count <= 1 {
      printRootHelp()
      return
    }
    if let spec = specs.first(where: { $0.name == path[1] }) {
      HelpPrinter.printCommand(rootName: rootName, spec: spec)
    } else {
      printRootHelp()
    }
  }
  
  private func printRootHelp() {
    HelpPrinter.printRoot(version: version, rootName: rootName, commands: specs)
  }
  
  private func helpPath(from argv: [String]) -> [String] {
    var path: [String] = []
    for token in argv {
      if token == "--help" || token == "-h" { continue }
      if token.hasPrefix("-") { break }
      path.append(token)
    }
    return path
  }
}
