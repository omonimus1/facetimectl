import Foundation

enum Console {
  static func printError(_ message: String) {
    let stderr = FileHandle.standardError
    if let data = "\(message)\n".data(using: .utf8) {
      stderr.write(data)
    }
  }
}
