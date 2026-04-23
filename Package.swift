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
            url: "https://binaries.ogury.co/release/ios/5.2.2/OgurySdk-5.2.2.zip",
            checksum: "ff620e358ca1a8033c6895b3ba71bd4cda0e54498def83442e7d8132b75e851d"
        ),
        .binaryTarget(
            name: "OguryAds",
            url: "https://binaries.ogury.co/release/ads-ios/4.2.2/OguryAds-4.2.2.zip",
            checksum: "c55c4cfddc0230230d3bba39e65c13bae1997b762991cdb09e514c06d8050d92"
        ),
        .binaryTarget(
            name: "OguryCore",
            url: "https://binaries.ogury.co/release/core-ios/2.2.1/OguryCore-2.2.1.zip",
            checksum: "c611cfe91a59e3d4c35d2851ec39907985635af4bcbfd6ccbb70b9821c518a42"
        ),
        .binaryTarget(
            name: "OMSDK",
            url: "https://binaries.ogury.co/release/omsdk-ios/1.5.7/OMSDK_Ogury-1.5.7.zip",
            checksum: "249245ac21482405775b2ec9b575755a883aa04e7f7a3e4f56797c5b843679ea"
        )
    ]
)
