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
            url: "https://binaries.ogury.co/release/ios/5.4.0/OgurySdk-5.4.0.zip",
            checksum: "0c6d9f68e0c7b4221afde421481cf5a43fcbf3889fb8e54543ca4d9bb409eee1"
        ),
        .binaryTarget(
            name: "OguryAds",
            url: "https://binaries.ogury.co/release/ads-ios/4.4.0/OguryAds-4.4.0.zip",
            checksum: "5c505acc41bd44ffa08a9ee6c8fecb346791a3af45a2d0290ef5af7da23503da"
        ),
        .binaryTarget(
            name: "OguryCore",
            url: "https://binaries.ogury.co/release/core-ios/2.4.0/OguryCore-2.4.0.zip",
            checksum: "32090abe0fa2d9f5ca34eddeede513d3de0554e96894267152f8b70bb35b32b5"
        ),
        .binaryTarget(
            name: "OMSDK",
            url: "https://binaries.ogury.co/release/omsdk-ios/1.6.11/OMSDK_Ogury-1.6.11.zip",
            checksum: "089f8afea96be2605116d64699c5b7c72b20567e59adb5c340aa5d3ee118f0cc"
        )
    ]
)
