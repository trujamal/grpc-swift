// swift-tools-version:5.1
/*
 * Copyright 2017, gRPC Authors All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import PackageDescription
import Foundation

let package = Package(
  name: "GRPC",
  platforms: [
    // We can't use `.watchOS(.v6)` since it isn't available with `swift-tools-version:5.0`.
    .macOS(.v10_12), .iOS(.v10), .tvOS(.v10), .watchOS("6.0")
  ],
  products: [
    .library(name: "GRPC", targets: ["GRPC"]),
    .executable(name: "protoc-gen-grpc-swift", targets: ["protoc-gen-grpc-swift"]),
  ],
  dependencies: [
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

    // Command line argument parser for our auxiliary command line tools.
    .package(url: "https://github.com/kylef/Commander.git", .upToNextMinor(from: "0.9.1")),
    
    // Swiftgrpc Dependecy
    .package(url: "https://github.com/grpc/grpc-swift.git", from: "0.10.0"),
  ],
  targets: [
    // The main GRPC module.
    .target(
      name: "GRPC",
      dependencies: [
        "NIO",
        "NIOFoundationCompat",
        "NIOTransportServices",
        "NIOHTTP1",
        "NIOHTTP2",
        "NIOSSL",
        "CGRPCZlib",
        "SwiftProtobuf",
        "Logging"
      ]
    ),  // and its tests.
    .testTarget(
      name: "GRPCTests",
      dependencies: [
        "GRPC",
        "EchoModel",
        "EchoImplementation",
        "GRPCSampleData",
        "GRPCInteroperabilityTestsImplementation"
      ]
    ),
    .target(
      name: "CGRPCZlib",
      linkerSettings: [
        .linkedLibrary("z")
      ]
    ),

    // The `protoc` plugin.
    .target(
      name: "protoc-gen-grpc-swift",
      dependencies: [
        "SwiftProtobuf",
        "SwiftProtobufPluginLibrary",
        "protoc-gen-swift"
      ]
    ),

    // Interoperability tests implementation.
    .target(
      name: "GRPCInteroperabilityTestsImplementation",
      dependencies: [
        "GRPC",
        "GRPCInteroperabilityTestModels"
      ]
    ),

    // Generated interoperability test models.
    .target(
      name: "GRPCInteroperabilityTestModels",
      dependencies: [
        "GRPC",
        "NIO",
        "NIOHTTP1",
        "SwiftProtobuf"
      ]
    ),

    // The CLI for the interoperability tests.
    .target(
      name: "GRPCInteroperabilityTests",
      dependencies: [
        "GRPCInteroperabilityTestsImplementation",
        "Logging",
      ]
    ),

    // The connection backoff interoperability test.
    .target(
      name: "GRPCConnectionBackoffInteropTest",
      dependencies: [
        "GRPC",
        "GRPCInteroperabilityTestModels",
        "Logging",
      ]
    ),

    // Performance tests implementation and CLI.
    .target(
      name: "GRPCPerformanceTests",
      dependencies: [
        "GRPC",
        "EchoModel",
        "EchoImplementation",
        "NIO",
        "NIOSSL",
      ]
    ),

    // Sample data, used in examples and tests.
    .target(
      name: "GRPCSampleData",
      dependencies: ["NIOSSL"]
    ),

    // Echo example CLI.
    .target(
      name: "Echo",
      dependencies: [
        "EchoModel",
        "EchoImplementation",
        "GRPC",
        "GRPCSampleData",
        "SwiftProtobuf",
      ],
      path: "Sources/Examples/Echo/Runtime"
    ),

    // Echo example service implementation.
    .target(
      name: "EchoImplementation",
      dependencies: [
        "EchoModel",
        "GRPC",
        "SwiftProtobuf"
      ],
      path: "Sources/Examples/Echo/Implementation"
    ),

    // Model for Echo example.
    .target(
      name: "EchoModel",
      dependencies: [
        "GRPC",
        "NIO",
        "NIOHTTP1",
        "SwiftProtobuf"
      ],
      path: "Sources/Examples/Echo/Model"
    ),

    // Model for the HelloWorld example
    .target(
      name: "HelloWorldModel",
      dependencies: [
        "GRPC",
        "NIO",
        "NIOHTTP1",
        "SwiftProtobuf"
      ],
      path: "Sources/Examples/HelloWorld/Model"
    ),

    // Client for the HelloWorld example
    .target(
      name: "HelloWorldClient",
      dependencies: [
        "GRPC",
        "HelloWorldModel",
      ],
      path: "Sources/Examples/HelloWorld/Client"
    ),

    // Server for the HelloWorld example
    .target(
      name: "HelloWorldServer",
      dependencies: [
        "GRPC",
        "NIO",
        "HelloWorldModel",
      ],
      path: "Sources/Examples/HelloWorld/Server"
    ),

    // Model for the RouteGuide example
    .target(
      name: "RouteGuideModel",
      dependencies: [
        "GRPC",
        "NIO",
        "NIOHTTP1",
        "SwiftProtobuf"
      ],
      path: "Sources/Examples/RouteGuide/Model"
    ),

    // Client for the RouteGuide example
    .target(
      name: "RouteGuideClient",
      dependencies: [
        "GRPC",
        "RouteGuideModel",
      ],
      path: "Sources/Examples/RouteGuide/Client"
    ),

    // Server for the RouteGuide example
    .target(
      name: "RouteGuideServer",
      dependencies: [
        "GRPC",
        "NIO",
        "RouteGuideModel",
      ],
      path: "Sources/Examples/RouteGuide/Server"
    ),

    // Adding New Clients
    .target(name: "SwiftGRPC",
      dependencies: ["CgRPC", "SwiftProtobuf"]
    ),
    .target(name: "CgRPC",
      dependencies: ["BoringSSL"],
      cSettings: [
        .headerSearchPath("../BoringSSL/include"),
        .unsafeFlags(["-Wno-module-import-in-extern-c"])
      ],
      linkerSettings: [.linkedLibrary("z")]
    ),
    .target(name: "RootsEncoder"),
    .target(name: "protoc-gen-swiftgrpc",
      dependencies: [
        "SwiftProtobuf",
        "SwiftProtobufPluginLibrary",
        "protoc-gen-swift"]
    ),
    .target(name: "BoringSSL"),
  ]
)
