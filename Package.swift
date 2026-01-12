// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OgurySdk",
    products: [
        .library(
            name: "OgurySdk",
            targets: ["OguryWrapper", "OguryAds", "OguryCore", "OMSDK"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "OguryWrapper",
            url: "https://binaries.ogury.co/release/ios/5.2.0/OgurySdk-5.2.0.zip",
            checksum: "f9182da5915d175e4e0b7933802968cdcaef8a46427afb58d6945149bbdcb65a"
        ),
        .binaryTarget(
            name: "OguryAds",
            url: "https://binaries.ogury.co/release/ads-ios/4.2.0/OguryAds-4.2.0.zip",
            checksum: "93865c7c13f05cdc98865be5ca888ae7df3ef7a6c02192a0e50c1c2ade211970"
        ),
        .binaryTarget(
            name: "OguryCore",
            url: "https://binaries.ogury.co/release/core-ios/2.2.0/OguryCore-2.2.0.zip",
            checksum: "3dcfdb1f4d74cd2aa1bcf9da970f45e9a557f7f3a0f5ffbe3ce6a37849b342a9"
        ),
        .binaryTarget(
            name: "OMSDK",
            url: "https://binaries.ogury.co/release/omid-ios/4.2.0/OMSDK_Ogury-4.2.0.zip",
            checksum: "7fc6d112a26b55f473dd8e512f49dbf9d37aeae3590b956419eb92235610302d"
        )
    ]
)
