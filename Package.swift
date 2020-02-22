// swift-tools-version:5.1

import PackageDescription
import Foundation

var packageDependencies: [Package.Dependency] = [  
    .package(url: "https://github.com/kylef/Commander.git", .upToNextMinor(from: "0.8.0")),
     // GRPC dependencies:
    // Main SwiftNIO package
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.13.0"),
    // HTTP2 via SwiftNIO
    .package(url: "https://github.com/apple/swift-nio-http2.git", from: "1.8.0"),
    // TLS via SwiftNIO
    .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.6.0"),
    // Support for Network.framework where possible.
    .package(url: "https://github.com/apple/swift-nio-transport-services.git", from: "1.3.0"),

    // Official SwiftProtobuf library, for [de]serializing data to send on the wire.
    .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.8.0"),

    // Logging API.
    .package(url: "https://github.com/apple/swift-log", from: "1.0.0"),
]

var cGRPCDependencies: [Target.Dependency] = []

#if os(Linux)
let isLinux = true
#else
let isLinux = false
#endif

if isLinux || ProcessInfo.processInfo.environment.keys.contains("GRPC_USE_OPENSSL") {
  packageDependencies.append(.package(url: "https://github.com/apple/swift-nio-ssl-support.git", from: "1.0.0"))
} else {
  cGRPCDependencies.append("BoringSSL")
}

let package = Package(
    name: "SwiftGRPC",
    products: [
        .library(name: "SwiftGRPC", targets: ["SwiftGRPC"])
    ],
    dependencies: packageDependencies,
    targets: [
        .target(name: "SwiftGRPC",
                dependencies: ["CgRPC", "SwiftProtobuf"]),
        .target(name: "CgRPC",
                dependencies: cGRPCDependencies,
                cSettings: [
                    .headerSearchPath("../BoringSSL/include", .when(platforms: [.iOS, .macOS, .tvOS, .watchOS])),
                    .unsafeFlags(["-Wno-module-import-in-extern-c"])],
                linkerSettings: [.linkedLibrary("z")]),
        .target(name: "protoc-gen-swiftgrpc",
                dependencies: [
                    "SwiftProtobuf",
                    "SwiftProtobufPluginLibrary",
                    "protoc-gen-swift"]),
        .target(name: "BoringSSL"),
        .testTarget(name: "SwiftGRPCTests", dependencies: ["SwiftGRPC"]),
    ],
    swiftLanguageVersions: [.v4, .v4_2, .version("5")],
    cLanguageStandard: .gnu11,
    cxxLanguageStandard: .cxx11)
