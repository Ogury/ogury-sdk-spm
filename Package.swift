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
            url: "https://binaries.ogury.co/internal/prod/OgurySdk/OgurySdk-Prod-5.1.0-beta.cocoapod.1.zip",
            checksum: "4d21a7bae79711c7f5537f7631ce4e2c23036e8aa08d57fba4c1d7b796943bfa"
        ),
        .binaryTarget(
            name: "OguryAds",
            url: "https://binaries.ogury.co/internal/prod/OguryAds/OguryAds-Prod-4.1.0-beta.cocoapod.1.zip",
            checksum: "a439f8f5eb278f046e02c9be5e0049d9bd2a2df6033561efdddce2fc07974bb7"
        ),
        .binaryTarget(
            name: "OguryCore",
            url: "https://binaries.ogury.co/internal/prod/OguryCore/OguryCore-Prod-2.1.0-beta.cocoapod.1.zip",
            checksum: "8b3df0e05de8cc846712738e1c90b8324553fde61597cc9f644427104b4891e9"
        ),
        .binaryTarget(
            name: "OMSDK",
            url: "https://binaries.ogury.co/internal/prod/OMSDK_Ogury/OMSDK_Ogury-Prod-4.1.0-beta.cocoapod.1.zip",
            checksum: "9282081e270361b43d87dc222f8ad94cee5062df3ab248bfeeea40394361fe5e"
        )
    ]
)
