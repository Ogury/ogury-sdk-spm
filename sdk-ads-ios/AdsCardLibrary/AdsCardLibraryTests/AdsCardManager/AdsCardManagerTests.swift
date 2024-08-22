//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import XCTest
@testable import AdsCardLibrary

final class AdsCardManagerTests: XCTestCase {
    
    struct HBRetriever: MaxHeaderBidable {
        func description(for error: Error) -> String {
            ""
        }
        
       func adMarkUp(adUnitId: String, 
                     campaignId: String?,
                     creativeId: String?,
                     dspCreative: String?,
                     dspRegion: DspRegion?) async -> String? {
            return ""
        }
    }
   
    struct HBDTFairBidRetriever: DTFairBidHeaderBidable {
        func description(for error: Error) -> String {
            ""
        }
       
        func adMarkUp(adUnitId: String,
                    campaignId: String?,
                    creativeId: String?,
                    dspCreative: String?,
                    dspRegion: DspRegion?) async -> String? {
            return ""
        }
   }
    
    //MARK: AdsCardManager init
    func testWhenInstanciatingNewManagerThenObjectIsNotNil() {
        let manager = AdsCardManager()
        XCTAssertNotNil(manager)
    }
    
    //MARK: - AdTypes
    func testGivenInterstitialAdTypesWhenRetrievingAdManagerThenProperManagerIsReturned() {
        let inter: AdType<InterstitialAdManager> = .interstitial
        let manager = try? inter.adManager
        XCTAssertNotNil(manager)
    }
    
    func testWhenInstanciatingInterstitialAdTypeWithWrongManagerThenErrorIsThrown() {
        let inter: AdType<RewardedAdManager> = .interstitial
        let manager = try? inter.adManager
        XCTAssertNil(manager)
        XCTAssertThrowsError(try inter.adManager)
    }
    
    func testGivenOptInAdTypesWhenRetrievingAdManagerThenProperManagerIsReturned() {
        let inter: AdType<RewardedAdManager> = .optInVideo
        let manager = try? inter.adManager
        XCTAssertNotNil(manager)
    }
    
    func testWhenInstanciatingOptInAdTypeWithWrongManagerThenErrorIsThrown() {
        let inter: AdType<InterstitialAdManager> = .optInVideo
        let manager = try? inter.adManager
        XCTAssertNil(manager)
        XCTAssertThrowsError(try inter.adManager)
    }
    
    func testGivenThumbnailAdTypesWhenRetrievingAdManagerThenProperManagerIsReturned() {
        let inter: AdType<ThumbnailAdManager> = .thumbnail
        let manager = try? inter.adManager
        XCTAssertNotNil(manager)
    }
    
    func testWhenInstanciatingThumbnailAdTypeWithWrongManagerThenErrorIsThrown() {
        let inter: AdType<InterstitialAdManager> = .thumbnail
        let manager = try? inter.adManager
        XCTAssertNil(manager)
        XCTAssertThrowsError(try inter.adManager)
    }
    
    func testGivenBannerAdTypesWhenRetrievingAdManagerThenProperManagerIsReturned() {
        let inter: AdType<BannerAdManager> = .banner
        let manager = try? inter.adManager
        XCTAssertNotNil(manager)
    }
    
    func testWhenInstanciatingBannerAdTypeWithWrongManagerThenErrorIsThrown() {
        let inter: AdType<InterstitialAdManager> = .banner
        let manager = try? inter.adManager
        XCTAssertNil(manager)
        XCTAssertThrowsError(try inter.adManager)
    }
    
    func testGivenMpuAdTypesWhenRetrievingAdManagerThenProperManagerIsReturned() {
        let inter: AdType<BannerAdManager> = .mpu
        let manager = try? inter.adManager
        XCTAssertNotNil(manager)
    }
    
    func testWhenInstanciatingMpuAdTypeWithWrongManagerThenErrorIsThrown() {
        let inter: AdType<InterstitialAdManager> = .mpu
        let manager = try? inter.adManager
        XCTAssertNil(manager)
        XCTAssertThrowsError(try inter.adManager)
    }
    
    func testGivenHBInterstitialAdTypesWhenRetrievingAdManagerThenProperManagerIsReturned() {
        let inter: AdType<InterstitialAdManager> = .maxHeaderBidding(adType: .interstitial, adMarkUpRetriever: HBRetriever())
        let manager = try? inter.adManager
        XCTAssertNotNil(manager)
    }
   
    func testGivenHBDTFairBidInterstitialAdTypesWhenRetrievingAdManagerThenProperManagerIsReturned() {
        let inter: AdType<InterstitialAdManager> = .dtFairBidHeaderBidding(adType: .interstitial, adMarkUpRetriever: HBDTFairBidRetriever())
        let manager = try? inter.adManager
        XCTAssertNotNil(manager)
    }
    
    func testWhenInstanciatingHBInterstitialAdTypeWithWrongManagerThenErrorIsThrown() {
        let inter: AdType<RewardedAdManager> = .maxHeaderBidding(adType: .interstitial, adMarkUpRetriever: HBRetriever())
        let manager = try? inter.adManager
        XCTAssertNil(manager)
        XCTAssertThrowsError(try inter.adManager)
    }
   
    func testGivenHBDTFairBidInterstitialAdTypeWithWrongManagerThenErrorIsThrown() {
        let inter: AdType<RewardedAdManager> = .dtFairBidHeaderBidding(adType: .interstitial, adMarkUpRetriever: HBDTFairBidRetriever())
        let manager = try? inter.adManager
       XCTAssertNil(manager)
       XCTAssertThrowsError(try inter.adManager)
    }
    
    func testGivenHBOptInAdTypesWhenRetrievingAdManagerThenProperManagerIsReturned() {
        let inter: AdType<RewardedAdManager> = .maxHeaderBidding(adType: .optInVideo, adMarkUpRetriever: HBRetriever())
        let manager = try? inter.adManager
        XCTAssertNotNil(manager)
    }
   
    func testGivenHBDTFairBidOptInAdTypesWhenRetrievingAdManagerThenProperManagerIsReturned() {
        let inter: AdType<RewardedAdManager> = .dtFairBidHeaderBidding(adType: .optInVideo, adMarkUpRetriever: HBDTFairBidRetriever())
        let manager = try? inter.adManager
        XCTAssertNotNil(manager)
    }
    
    func testWhenInstanciatingHBOptInAdTypeWithWrongManagerThenErrorIsThrown() {
        let inter: AdType<InterstitialAdManager> = .maxHeaderBidding(adType: .optInVideo, adMarkUpRetriever: HBRetriever())
        let manager = try? inter.adManager
        XCTAssertNil(manager)
        XCTAssertThrowsError(try inter.adManager)
    }
   
    func testWhenInstanciatingHBDTFairBidOptInAdTypeWithWrongManagerThenErrorIsThrown() {
        let inter: AdType<InterstitialAdManager> = .dtFairBidHeaderBidding(adType: .optInVideo, adMarkUpRetriever: HBDTFairBidRetriever())
        let manager = try? inter.adManager
        XCTAssertNil(manager)
        XCTAssertThrowsError(try inter.adManager)
    }
    
    func testGivenHBBannerAdTypesWhenRetrievingAdManagerThenProperManagerIsReturned() {
        let inter: AdType<BannerAdManager> = .maxHeaderBidding(adType: .banner, adMarkUpRetriever: HBRetriever())
        let manager = try? inter.adManager
        XCTAssertNotNil(manager)
    }
   
    func testGivenHBDTFairBidBannerAdTypesWhenRetrievingAdManagerThenProperManagerIsReturned() {
        let inter: AdType<BannerAdManager> = .dtFairBidHeaderBidding(adType: .banner, adMarkUpRetriever: HBDTFairBidRetriever())
        let manager = try? inter.adManager
        XCTAssertNotNil(manager)
    }
    
    func testWhenInstanciatingHBBannerAdTypeWithWrongManagerThenErrorIsThrown() {
        let inter: AdType<InterstitialAdManager> = .maxHeaderBidding(adType: .banner, adMarkUpRetriever: HBRetriever())
        let manager = try? inter.adManager
        XCTAssertNil(manager)
        XCTAssertThrowsError(try inter.adManager)
    }
   
    func testWhenInstanciatingHBDTFairBidBannerAdTypeWithWrongManagerThenErrorIsThrown() {
        let inter: AdType<InterstitialAdManager> = .dtFairBidHeaderBidding(adType: .banner, adMarkUpRetriever: HBDTFairBidRetriever())
        let manager = try? inter.adManager
        XCTAssertNil(manager)
        XCTAssertThrowsError(try inter.adManager)
    }
    
    func testGivenHBMpuAdTypesWhenRetrievingAdManagerThenProperManagerIsReturned() {
        let inter: AdType<BannerAdManager> = .maxHeaderBidding(adType: .mpu, adMarkUpRetriever: HBRetriever())
        let manager = try? inter.adManager
        XCTAssertNotNil(manager)
    }
   
    func testGivenHBDTFairBidMpuAdTypesWhenRetrievingAdManagerThenProperManagerIsReturned() {
        let inter: AdType<BannerAdManager> = .dtFairBidHeaderBidding(adType: .mpu, adMarkUpRetriever: HBDTFairBidRetriever())
        let manager = try? inter.adManager
        XCTAssertNotNil(manager)
    }
    
    func testWhenInstanciatingHBMpuAdTypeWithWrongManagerThenErrorIsThrown() {
        let inter: AdType<InterstitialAdManager> = .maxHeaderBidding(adType: .mpu, adMarkUpRetriever: HBRetriever())
        let manager = try? inter.adManager
        XCTAssertNil(manager)
        XCTAssertThrowsError(try inter.adManager)
    }
   
    func testWhenInstanciatingHBDTFairBidMpuAdTypeWithWrongManagerThenErrorIsThrown() {
        let inter: AdType<InterstitialAdManager> = .dtFairBidHeaderBidding(adType: .mpu, adMarkUpRetriever: HBDTFairBidRetriever())
        let manager = try? inter.adManager
        XCTAssertNil(manager)
        XCTAssertThrowsError(try inter.adManager)
    }
    
    //MARK: - Ad Managers
    func testWhenRetrievingInterstitialAdManagerFromSUTThenProperManagerIsReturned() {
        let sut = AdsCardManager()
        let adDelegate = mock(AdLifeCycleDelegate.self)
        let inter: AdType<InterstitialAdManager> = .interstitial
        let vc = UIViewController()
        let manager = try? sut.adManager(for: inter, options: AdManagerOptions(viewController: vc, adDisplayName: "", adUnitId: ""), adDelegate: adDelegate)
        XCTAssertNotNil(manager)
        XCTAssertEqual(manager?.options, AdManagerOptions(viewController: vc, adDisplayName: "", adUnitId: ""))
    }
    
    func testWhenRetrievingThumbnailAdManagerFromSUTThenProperManagerIsReturned() {
        let sut = AdsCardManager()
        let adDelegate = mock(AdLifeCycleDelegate.self)
        let thumb: AdType<ThumbnailAdManager> = .thumbnail
        let vc = UIViewController()
        let manager = try? sut.adManager(for: thumb, options: ThumbnailAdManagerOptions(viewController: vc, thumbnailOptions: ThumbnailOptions(), adDisplayName: "", adUnitId: ""), adDelegate: adDelegate)
        XCTAssertNotNil(manager)
        XCTAssertEqual(manager?.options, ThumbnailAdManagerOptions(viewController: vc, thumbnailOptions: ThumbnailOptions(), adDisplayName: "", adUnitId: ""))
    }
    
    func testWhenRetrievingBannerAdManagerFromSUTThenProperManagerIsReturned() {
        let sut = AdsCardManager()
        let adDelegate = mock(AdLifeCycleDelegate.self)
        let banner: AdType<BannerAdManager> = .banner
        let view = UIView()
        let manager = try? sut.adManager(for: banner, options: BannerAdManagerOptions(view: view, adDisplayName: "", adUnitId: ""), adDelegate: adDelegate)
        XCTAssertNotNil(manager)
        XCTAssertEqual(manager?.options, BannerAdManagerOptions(view: view, adDisplayName: "", adUnitId: ""))
    }
}
