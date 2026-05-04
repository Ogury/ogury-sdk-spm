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
            url: "https://binaries.ogury.co/release/ios/5.2.3/OgurySdk-5.2.3.zip",
            checksum: "f9411c03065b9aa6fc03ac6ecef0e1c4be39e9bcada492c8be4bde569011b39a"
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
            checksum: "7adb6caa6359e5cf3efe5cd929628f4e67463179105e7e878db13761e40c7307"
        )
    ]
)
