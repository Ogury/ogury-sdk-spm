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
            url: "https://ads-ios-sdk.ogury.co/spm/OgurySdk-5.1.0.zip",
//            checksum: "3ee0a76bc0a483471798db042b47b25a9ee3cc9c6f66741935dbe63d7d870803"
            checksum: "7c1eb3e2c490fabedfa4c58830908ccc7a9ec504fd53efb315d4f05a8a3df6f9"
        ),
        .binaryTarget(
            name: "OguryAds",
            url: "https://ads-ios-sdk.ogury.co/spm/OguryAds-4.1.0.zip",
//            checksum: "ff4ba2e20178c1aab5434bbfeb5742ecdf8fe058afadfa4e0d7b09792b1ab8e6"
            checksum: "b6065d534bb51c0f87ad4a6ce3cd74d679bb254e94deeb91460f7e1e30e7b4c9"
        ),
        .binaryTarget(
            name: "OguryCore",
            url: "https://ads-ios-sdk.ogury.co/spm/OguryCore-2.1.0.zip",
//            checksum: "98fdffab1118a41026cdf1464e4be7ccc3b0c83461a199b8ca3bd60a9bfd1a3d"
            checksum: "45216f2c6d078c5eb20af46c2e94553497e2c2fc00cac378433af62f256c092e"
        ),
        .binaryTarget(
            name: "OMSDK",
            url: "https://ads-ios-sdk.ogury.co/spm/static/OMSDK_Ogury-5.1.0.zip",
            checksum: "0d499b961741aa2b407209276ae666c18b404b2b55f5451f66daefb05b62cf9b"
        )
    ]
)
