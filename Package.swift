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
            url: "https://binaries.ogury.co/internal/prod/OgurySdk/OgurySdk-Prod-5.2.0-rc.5.zip",
            checksum: "da4a2361d0c8a87c1d5a04466b814a4a9196deb5542b3cff6a6cc38f2a34e957"
        ),
        .binaryTarget(
            name: "OguryAds",
            url: "https://binaries.ogury.co/internal/prod/OguryAds/OguryAds-Prod-4.2.0-rc.5.zip",
            checksum: "ebba8fdf30ca65570bf7e68036257b40d41f361831bd180677fa58e6f0f75948"
        ),
        .binaryTarget(
            name: "OguryCore",
            url: "https://binaries.ogury.co/internal/prod/OguryCore/OguryCore-Prod-2.2.0-rc.2.zip",
            checksum: "b3b3bb3ccaebb0a54cc23bf868e30641337ee10b106777f8684cf6a2b6ecb421"
        ),
        .binaryTarget(
            name: "OMSDK",
            url: "https://binaries.ogury.co/internal/prod/OMSDK_Ogury/OMSDK_Ogury-Prod-4.1.0-beta.cocoapod.1.zip",
            checksum: "9282081e270361b43d87dc222f8ad94cee5062df3ab248bfeeea40394361fe5e"
        )
    ]
)
