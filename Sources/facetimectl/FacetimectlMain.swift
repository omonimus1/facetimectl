import Foundation

@main
enum FacetimectlMain {
  static func main() async {
    let code = await CommandRouter().run()
    exit(code)
  }
}
