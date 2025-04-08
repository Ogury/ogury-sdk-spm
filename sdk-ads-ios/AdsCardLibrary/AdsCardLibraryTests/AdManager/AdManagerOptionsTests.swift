//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import XCTest
@testable import AdsCardLibrary

final class AdManagerOptionsTests: XCTestCase {
    func testWhenInitializingSUTWithOptionsThenAllOptionsAreSet() {
        let options = ThumbnailAdManagerOptions(showCampaignId: true,
                                                showCreativeId: false,
                                                showDspFields: false,
                                                showSpecificOptions: false,
                                                viewController: UIViewController(),
                                                thumbnailOptions: ThumbnailOptions(position: CGPoint(x: 10, y: 10),
                                                                                   size: CGSize(width: 100, height: 100),
                                                                                   offset: OguryOffset(x: 20, y: 20),
                                                                                   corner: .topLeft),
                                                adDisplayName: "",
                                                adUnitId: "adUnitId",
                                                campaignId: "campaignId",
                                                creativeId: "creativeId")
        XCTAssertTrue(options.showCampaignId)
        XCTAssertFalse(options.showCreativeId)
        XCTAssertFalse(options.showDspFields)
        XCTAssertFalse(options.showSpecificOptions)
        XCTAssertEqual(options.baseOptions.adDisplayName, "")
        XCTAssertEqual(options.baseOptions.adUnitId, "adUnitId")
        XCTAssertEqual(options.baseOptions.campaignId, "campaignId")
        XCTAssertEqual(options.baseOptions.creativeId, "creativeId")
        XCTAssertNotNil(options.thumbnailOptions)
        XCTAssertEqual(options.thumbnailOptions?.position, CGPoint(x: 10, y: 10))
        XCTAssertEqual(options.thumbnailOptions?.size, CGSize(width: 100, height: 100))
        XCTAssertEqual(options.thumbnailOptions?.offset, OguryOffset(x: 20, y: 20))
        XCTAssertEqual(options.thumbnailOptions?.corner, .topLeft)
    }
    
    func testWhenUsingDefaultInitializerThenAllOptionsAreSet() {
        let options = AdManagerOptions(viewController: UIViewController(), adDisplayName: "", adUnitId: "adUnitId")
        XCTAssertFalse(options.showCampaignId)
        XCTAssertFalse(options.showCreativeId)
        XCTAssertTrue(options.showDspFields)
        XCTAssertTrue(options.showSpecificOptions)
        XCTAssertEqual(options.baseOptions.adUnitId, "adUnitId")
        XCTAssertNil(options.baseOptions.campaignId)
        XCTAssertNil(options.baseOptions.creativeId)
    }
    
    func testWwhenSerializingThumbnailOptionsThenAllDataArePreserved() {
        let vc = UIViewController()
        let options = ThumbnailAdManagerOptions(showCampaignId: true,
                                                showCreativeId: false,
                                                showSpecificOptions: false,
                                                viewController: vc,
                                                thumbnailOptions: ThumbnailOptions(position: CGPoint(x: 10, y: 10),
                                                                                   size: CGSize(width: 100, height: 100),
                                                                                   offset: OguryOffset(x: 20, y: 20),
                                                                                   corner: .topLeft),
                                                adDisplayName: "",
                                                adUnitId: "adUnitId",
                                                campaignId: "campaignId",
                                                creativeId: "creativeId")
        let data = try? JSONEncoder().encode(options)
        XCTAssertNotNil(data)
        let decodedOptions = try? JSONDecoder().decode(ThumbnailAdManagerOptions.self, from: data!)
        XCTAssertNotNil(decodedOptions)
        decodedOptions?.viewController = vc
        XCTAssertEqual(options, decodedOptions)
    }
    
    func testWwhenSerializingAdOptionsThenAllDataArePreserved() {
        let vc = UIViewController()
        let options = AdManagerOptions(showCampaignId: true,
                                       showCreativeId: false,
                                       showSpecificOptions: false,
                                       viewController: vc,
                                       adDisplayName: "",
                                       adUnitId: "adUnitId",
                                       campaignId: "campaignId",
                                       creativeId: "creativeId")
        let data = try? JSONEncoder().encode(options)
        XCTAssertNotNil(data)
        let decodedOptions = try? JSONDecoder().decode(AdManagerOptions.self, from: data!)
        XCTAssertNotNil(decodedOptions)
        decodedOptions?.viewController = vc
        XCTAssertEqual(options, decodedOptions)
    }
    
    func testWwhenSerializingBannerOptionsThenAllDataArePreserved() {
        let view = UIView()
        let options = BannerAdManagerOptions(showCampaignId: true,
                                             showCreativeId: false,
                                             showSpecificOptions: false,
                                             view: view,
                                             adDisplayName: "",
                                             adUnitId: "adUnitId",
                                             campaignId: "campaignId",
                                             creativeId: "creativeId")
        let data = try? JSONEncoder().encode(options)
        XCTAssertNotNil(data)
        let decodedOptions = try? JSONDecoder().decode(BannerAdManagerOptions.self, from: data!)
        XCTAssertNotNil(decodedOptions)
        decodedOptions?.view = view
        XCTAssertEqual(options, decodedOptions)
    }
}
