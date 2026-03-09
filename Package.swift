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
            url: "https://binaries.ogury.co/release/ios/5.2.1/OgurySdk-5.2.1.zip",
            checksum: "bcd2f524658be66f4749b50f20dc4e7a92a9da5db9ad3d55d45be4a33e866c9e"
        ),
        .binaryTarget(
            name: "OguryAds",
            url: "https://binaries.ogury.co/release/ads-ios/4.2.1/OguryAds-4.2.1.zip",
            checksum: "f47a769e7e33ffe2b2e719a445303c05e921dbecc1e94f8d01cdb5877fd2e8fa"
        ),
        .binaryTarget(
            name: "OguryCore",
            url: "https://binaries.ogury.co/release/core-ios/2.2.0/OguryCore-2.2.0.zip",
            checksum: "3dcfdb1f4d74cd2aa1bcf9da970f45e9a557f7f3a0f5ffbe3ce6a37849b342a9"
        ),
        .binaryTarget(
            name: "OMSDK",
            url: "https://binaries.ogury.co/release/omsdk-ios/1.5.7/OMSDK_Ogury-1.5.7.zip",
            checksum: "249245ac21482405775b2ec9b575755a883aa04e7f7a3e4f56797c5b843679ea"
        )
    ]
)
