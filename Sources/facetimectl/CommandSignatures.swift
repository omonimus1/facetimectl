import Commander

enum CommandSignatures {
  static func runtimeFlags() -> [FlagDefinition] {
    [
      .make(
        label: "jsonOutput",
        names: [.short("j"), .long("json")],
        help: "Emit machine-readable JSON output"
      ),
      .make(
        label: "plainOutput",
        names: [.long("plain")],
        help: "Emit stable line-based output"
      ),
      .make(
        label: "quiet",
        names: [.short("q"), .long("quiet")],
        help: "Only emit minimal output"
      ),
    ]
  }

  static func withRuntimeFlags(_ signature: CommandSignature) -> CommandSignature {
    CommandSignature(
      arguments: signature.arguments,
      options: signature.options,
      flags: signature.flags + runtimeFlags(),
      optionGroups: signature.optionGroups
    )
  }
}
