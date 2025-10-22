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
            url: "https://binaries.ogury.co/internal/prod/OgurySdk/OgurySdk-Prod-5.2.0-rc.3.zip",
            checksum: "e8f121cf9775ded60784d24a7bf5f0d2d1bcfa917e1cdb5478fa054d03560fd2"
        ),
        .binaryTarget(
            name: "OguryAds",
            url: "https://binaries.ogury.co/internal/prod/OguryAds/OguryAds-Prod-4.2.0-rc.3.zip",
            checksum: "b2fdd41198d663fdf6a385bc07825135f7a2f4633c283b3b82426ecc2de545f8"
        ),
        .binaryTarget(
            name: "OguryCore",
            url: "https://binaries.ogury.co/internal/prod/OguryCore/OguryCore-Prod-2.2.0-rc.1.zip",
            checksum: "b1dcadcd4c6be799cae470f49a47ca9df4ec00071edb2e25ca2f78d2206af7e0"
        ),
        .binaryTarget(
            name: "OMSDK",
            url: "https://binaries.ogury.co/internal/prod/OMSDK_Ogury/OMSDK_Ogury-Prod-4.1.0-beta.cocoapod.1.zip",
            checksum: "9282081e270361b43d87dc222f8ad94cee5062df3ab248bfeeea40394361fe5e"
        )
    ]
)
