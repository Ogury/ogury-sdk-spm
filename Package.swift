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
            url: "https://ads-ios-sdk.ogury.co/spm/dynamic/OgurySdk-5.1.0.zip",
            checksum: "f0b42ec77d63fc0010760bc25c78ddf38a89140a757df875bc5139479efa0c39"
        ),
        .binaryTarget(
            name: "OguryAds",
            url: "https://ads-ios-sdk.ogury.co/spm/dynamic/OguryAds-4.1.0.zip",
            checksum: "56831bfa97ccd52969985d6ff03aa598b926b2774a44cd3f2f63059d5a181813"
        ),
        .binaryTarget(
            name: "OguryCore",
            url: "https://ads-ios-sdk.ogury.co/spm/dynamic/OguryCore-2.1.0.zip",
            checksum: "39e68b290085b702222536763259e8a5fdd060f6256127c00a6fdd693df59a8b"
        ),
        .binaryTarget(
            name: "OMSDK",
            url: "https://ads-ios-sdk.ogury.co/spm/dynamic/OMSDK-5.1.0.zip",
            checksum: "874475a25bbc8d6354263cf0d0a1d79b42af7c39931946317d717faa9ff8a6ba"
        )
    ]
)
