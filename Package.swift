// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OgurySdk",
    platforms: [
        // Align with Xcode 27's new minimum requirements
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "OgurySdk",
            targets: ["OguryWrapper", "OguryAds", "OguryCore", "OMSDK"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "OguryWrapper",
            url: "https://binaries.ogury.co/release/ios/5.3.1/OgurySdk-5.3.1.zip",
            checksum: "54b98f723e578975c45d780ce7298355280bb6e6c0018121d1d335a2950828f6"
        ),
        .binaryTarget(
            name: "OguryAds",
            url: "https://binaries.ogury.co/release/ads-ios/4.3.1/OguryAds-4.3.1.zip",
            checksum: "2d4430b2dae5eba4c7f7c8f970970adfa94a9a9eb800dd45a9c0fde84cb52d0a"
        ),
        .binaryTarget(
            name: "OguryCore",
            url: "https://binaries.ogury.co/release/core-ios/2.3.1/OguryCore-2.3.1.zip",
            checksum: "e19759437ed847e5f0a09b5ec70422e5d274641e47677162834f193f09a4e00c"
        ),
        .binaryTarget(
            name: "OMSDK",
            url: "https://binaries.ogury.co/release/omsdk-ios/1.6.10/OMSDK_Ogury-1.6.10.zip",
            checksum: "71f5ec13afbddda2bd2d20686b21b5753d57623bd83a27b26369b18e7f8c067a"
        )
    ]
)
