import Commander
import Foundation

struct RuntimeOptions {
  let outputFormat: OutputFormat
  
  init(parsedValues: ParsedValues) {
    if parsedValues.flag("jsonOutput") {
      self.outputFormat = .json
    } else if parsedValues.flag("plainOutput") {
      self.outputFormat = .plain
    } else if parsedValues.flag("quiet") {
      self.outputFormat = .quiet
    } else {
      self.outputFormat = .standard
    }
  }
}

enum OutputFormat {
  case json
  case plain
  case quiet
  case standard
}
