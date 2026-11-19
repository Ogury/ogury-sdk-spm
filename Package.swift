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
            url: "https://binaries.ogury.co/release/ios/5.4.99/OgurySdk-5.4.99.zip",
            checksum: "5a1af1931093ea67415db13dc0f5489760c3448e257fce4cf0969dc8af6471ac"
        ),
        .binaryTarget(
            name: "OguryAds",
            url: "https://binaries.ogury.co/release/ads-ios/4.4.99/OguryAds-4.4.99.zip",
            checksum: "e33991a0e3097584c6237a8c39ffb78f686a4ac8b3d1de7fb614541900097237"
        ),
        .binaryTarget(
            name: "OguryCore",
            url: "https://binaries.ogury.co/release/core-ios/2.4.99/OguryCore-2.4.99.zip",
            checksum: "b71f2762157b189bd128ef913c824cc469897f40b7931b22326b48b8d343d9e1"
        ),
        .binaryTarget(
            name: "OMSDK",
            url: "https://binaries.ogury.co/release/omsdk-ios/1.6.11/OMSDK_Ogury-1.6.11.zip",
            checksum: "089f8afea96be2605116d64699c5b7c72b20567e59adb5c340aa5d3ee118f0cc"
        )
    ]
)
