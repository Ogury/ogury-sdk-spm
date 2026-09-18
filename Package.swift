// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OgurySdk",
    platforms: [
        // Matches the frameworks' own IPHONEOS_DEPLOYMENT_TARGET (15.0 since
        // OgurySdk 5.3.1) and the "ios": "15.0" floor in the CocoaPods podspecs.
        // Without this, SwiftPM resolves the package for any deployment target
        // and the mismatch only surfaces later as an opaque link-time error.
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
            url: "https://binaries.ogury.co/release/ios/5.3.0/OgurySdk-5.3.0.zip",
            checksum: "6c8537a733c4bd28d96a1f4c11fcc993552fbbf8747520939f6620b13b4ae7a5"
        ),
        .binaryTarget(
            name: "OguryAds",
            url: "https://binaries.ogury.co/release/ads-ios/4.3.0/OguryAds-4.3.0.zip",
            checksum: "426edcef1ca2ed29ad1759e37fd810ea87d5ab40f6cdea01369d96526775abb4"
        ),
        .binaryTarget(
            name: "OguryCore",
            url: "https://binaries.ogury.co/release/core-ios/2.3.0/OguryCore-2.3.0.zip",
            checksum: "b7b569bad910f5db6fcde3c2dddae67aba0264068307d73bc2d924af4f62de74"
        ),
        .binaryTarget(
            name: "OMSDK",
            url: "https://binaries.ogury.co/release/omsdk-ios/1.6.6/OMSDK_Ogury-1.6.6.zip",
            checksum: "b11f03198d1155b644e325a6260558ec6531b85e7e470bd32834debc77dd6977"
        )
    ]
)
