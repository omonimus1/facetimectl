// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "facetimectl",
  platforms: [.macOS(.v14)],
  products: [
    .library(name: "FaceTimeCore", targets: ["FaceTimeCore"]),
    .executable(name: "facetimectl", targets: ["facetimectl"]),
  ],
  dependencies: [
    .package(url: "https://github.com/steipete/Commander.git", from: "0.2.0"),
  ],
  targets: [
    .target(
      name: "FaceTimeCore",
      dependencies: [],
      linkerSettings: [
        .linkedFramework("Contacts"),
        .linkedFramework("EventKit"),
        .linkedFramework("AppKit"),
      ]
    ),
    .executableTarget(
      name: "facetimectl",
      dependencies: [
        "FaceTimeCore",
        .product(name: "Commander", package: "Commander"),
      ],
      exclude: [
        "Resources/Info.plist",
      ],
      linkerSettings: [
        .unsafeFlags([
          "-Xlinker", "-sectcreate",
          "-Xlinker", "__TEXT",
          "-Xlinker", "__info_plist",
          "-Xlinker", "Sources/facetimectl/Resources/Info.plist",
        ]),
      ]
    ),
    .testTarget(
      name: "FaceTimeCoreTests",
      dependencies: [
        "FaceTimeCore",
      ]
    ),
    .testTarget(
      name: "facetimectlTests",
      dependencies: [
        "facetimectl",
        "FaceTimeCore",
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)
