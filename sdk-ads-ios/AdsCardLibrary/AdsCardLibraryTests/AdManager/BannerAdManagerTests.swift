//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import XCTest
@testable import AdsCardLibrary
import OguryAds.OguryThumbnailAd
import Mockingbird
import CwlPreconditionTesting
import Combine

final class BannerAdManagerTests: XCTestCase {
    var storables: [AnyCancellable] = []
    func testWhenInstanciatingInterstitialAdManagerThenAllPropertiesAreSet() {
        let ad: AdType<BannerAdManager> = .banner
        let adManager = BannerAdManager(adType: ad)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(adManager.adType == ad)
            XCTAssertNotNil(adManager.proxyDelegate)
        }
    }
    
    func testWhenSettingNewAdDelegateThenProxyIsUpdated() {
        let ad: AdType<BannerAdManager> = .banner
        
        let adManager = BannerAdManager(adType: ad)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let newDelegate = mock(AdLifeCycleDelegate.self)
            adManager.adDelegate = newDelegate
            XCTAssertTrue(adManager.adDelegate as? AdLifeCycleDelegateMock === newDelegate)
            XCTAssertTrue(adManager.proxyDelegate.adDelegate as? AdLifeCycleDelegateMock === newDelegate)
        }
    }
    
    func testWhenCallingLoadWithOptionsThenAdObjectIsInstanciated() {
        let ad: AdType<BannerAdManager> = .banner
        
        let adManager = BannerAdManager(adType: ad)
        adManager.options = BannerAdManagerOptions(view: UIView(), adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertNotNil(adManager.ad)
            XCTAssertTrue(adManager.ad.delegate === adManager.proxyDelegate)
        }
    }
    
    func testWhenCallingShowWithoutAnyOptionsThenErrorIsThrown() {
        let ad: AdType<BannerAdManager> = .banner
        
        let adManager = BannerAdManager(adType: ad)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let ex = self.expectation(description: "The ad did not load")
            adManager.events.sink { event in
                if event == .adDidFail(AdManagerError.noShowForBanner) {
                    ex.fulfill()
                }
            }
            .store(in: &self.storables)
            try? adManager.showAd()
            self.wait(for: [ex], timeout: 0.5)
        }
    }
    
    func testWhenCallingShowWithOptionsThenNoErrorIsThrown() {
        let ad: AdType<BannerAdManager> = .banner
        let adManager = BannerAdManager(adType: ad)
        let vc = UIView()
        adManager.options = BannerAdManagerOptions(view: vc, adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                try adManager.showAd()
            } catch {
                XCTFail("Did throw")
            }
        }
    }
    
    //MARK: Delegates
    func testWhenAdLoadedDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<BannerAdManager> = .banner
        let adManager = BannerAdManager(adType: ad)
        let vc = UIView()
        adManager.options = BannerAdManagerOptions(view: vc, adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let ex = self.expectation(description: "The ad did not load")
            adManager.events.sink { event in
                if event == .adLoaded(canShow: false) {
                    ex.fulfill()
                }
            }
            .store(in: &self.storables)
            adManager.ad?.delegate?.didLoad?(OguryBannerAd())
            self.wait(for: [ex], timeout: 0.5)
        }
    }
    
    func testWhenAdClickedDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<BannerAdManager> = .banner
        let adManager = BannerAdManager(adType: ad)
        let vc = UIView()
        adManager.options = BannerAdManagerOptions(view: vc, adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let ex = self.expectation(description: "")
            adManager.events.sink { event in
                if event == .adClicked {
                    ex.fulfill()
                }
            }
            .store(in: &self.storables)
            adManager.ad?.delegate?.didClick?(OguryBannerAd())
            self.wait(for: [ex], timeout: 0.5)
        }
    }
    
    func testWhenAdDisplayedDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<BannerAdManager> = .banner
        
        let adManager = BannerAdManager(adType: ad)
        let vc = UIView()
        adManager.options = BannerAdManagerOptions(view: vc, adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let ex = self.expectation(description: "")
            adManager.events.sink { event in
                if event == .adDisplayed {
                    ex.fulfill()
                }
            }
            .store(in: &self.storables)
            adManager.ad?.delegate?.didDisplay?(OguryBannerAd())
            self.wait(for: [ex], timeout: 0.5)
        }
    }
    
    func testWhenAdClosedDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<BannerAdManager> = .banner
        
        let adManager = BannerAdManager(adType: ad)
        let vc = UIView()
        adManager.options = BannerAdManagerOptions(view: vc, adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let ex = self.expectation(description: "")
            adManager.events.sink { event in
                if event == .adClosed {
                    ex.fulfill()
                }
            }
            .store(in: &self.storables)
            adManager.ad?.delegate?.didClose?(OguryBannerAd())
            self.wait(for: [ex], timeout: 0.5)
        }
    }
    
    func testWhenAdDidTriggerImpressionDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<BannerAdManager> = .banner
        
        let adManager = BannerAdManager(adType: ad)
        let vc = UIView()
        adManager.options = BannerAdManagerOptions(view: vc, adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let ex = self.expectation(description: "")
            adManager.events.sink { event in
                if event == .adDidTriggerImpression {
                    ex.fulfill()
                }
            }
            .store(in: &self.storables)
            adManager.ad?.delegate?.didTriggerImpressionOguryBannerAd?(OguryBannerAd())
            self.wait(for: [ex], timeout: 0.5)
        }
    }
    
    func testWhenAdDidFailDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<BannerAdManager> = .banner
        
        let adManager = BannerAdManager(adType: ad)
        let vc = UIView()
        adManager.options = BannerAdManagerOptions(view: vc, adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let error = OguryError.createOguryError(withCode: 666)
            let ex = self.expectation(description: "")
            adManager.events.sink { event in
                if event == .adDidFail(error) {
                    ex.fulfill()
                }
            }
            .store(in: &self.storables)
            adManager.ad?.delegate?.didFailOguryBannerAdWithError?(error, for: OguryBannerAd())
            self.wait(for: [ex], timeout: 0.5)
        }
    }
    
    func testWhenReceivingLoadingErrorsThenProperDelegateShouldBeCalled() {
            [OguryAdsError.profigNotSyncedError.rawValue,
             OguryAdsError.notLoadedError.rawValue].forEach { errorCode in
               let ad: AdType<BannerAdManager> = .banner
               var adManager = BannerAdManager(adType: ad)
               let vc = UIView()
               adManager.options = BannerAdManagerOptions(view: vc, adDisplayName: "", adUnitId: "")
               try? adManager.loadAd(from: adManager.options.baseOptions)
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let error = OguryError.createOguryError(withCode: errorCode)
                let loadFailEx = self.expectation(description: "adDidFailToLoad called")
                let failEx = self.expectation(description: "adDidFail called")
                failEx.isInverted = true
                let displayFailEx = self.expectation(description: "adDidFailToDisplay called")
                displayFailEx.isInverted = true
                adManager.events.sink { event in
                    if event == .adDidFail(error) {
                        failEx.fulfill()
                    }
                    if event == .adDidFailToLoad(error) {
                        loadFailEx.fulfill()
                    }
                    if event == .adDidFailToDisplay(error) {
                        displayFailEx.fulfill()
                    }
                }
                .store(in: &self.storables)
                adManager.ad?.delegate?.didFailOguryBannerAdWithError?(error, for: OguryBannerAd())
                self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 0.5)
            }
        }
    }
    
   func testWhenReceivingDisplayErrorsThenProperDelegateShouldBeCalled() {
      [OguryAdsError.adExpiredError.rawValue,
       OguryAdsError.anotherAdAlreadyDisplayedError.rawValue,
       OguryAdsError.cantShowAdsInPresentingViewControllerError.rawValue].forEach { errorCode in
         let ad: AdType<BannerAdManager> = .banner
         let adManager = BannerAdManager(adType: ad)
         let vc = UIView()
         adManager.options = BannerAdManagerOptions(view: vc, adDisplayName: "", adUnitId: "")
         try? adManager.loadAd(from: adManager.options.baseOptions)
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let error = OguryError.createOguryError(withCode: errorCode)
            let loadFailEx = self.expectation(description: "adDidFailToLoad called")
            loadFailEx.isInverted = true
            let failEx = self.expectation(description: "adDidFail called")
            failEx.isInverted = true
            let displayFailEx = self.expectation(description: "adDidFailToDisplay called")
            adManager.events.sink { event in
               if event == .adDidFail(error) {
                  failEx.fulfill()
               }
               if event == .adDidFailToLoad(error) {
                  loadFailEx.fulfill()
               }
               if event == .adDidFailToDisplay(error) {
                  displayFailEx.fulfill()
               }
            }
            .store(in: &self.storables)
            adManager.ad?.delegate?.didFailOguryBannerAdWithError?(error, for: OguryBannerAd())
            self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 0.5)
         }
      }
    }
    
    func testWhenReceivingGenericErrorsThenProperDelegateShouldBeCalled() {
            [OguryAdsError.adDisabledError.rawValue,
             OguryAdsError.assetKeyNotValidError.rawValue,
             OguryAdsError.notAvailableError.rawValue,
             OguryAdsError.sdkInitNotCalledError.rawValue,
             OguryAdsError.unknownError.rawValue].forEach { errorCode in
               let ad: AdType<BannerAdManager> = .banner
               
               let adManager = BannerAdManager(adType: ad)
               let vc = UIView()
               adManager.options = BannerAdManagerOptions(view: vc, adDisplayName: "", adUnitId: "")
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
               try? adManager.loadAd(from: adManager.options.baseOptions)
                let error = OguryError.createOguryError(withCode: errorCode)
                let loadFailEx = self.expectation(description: "adDidFailToLoad called")
                loadFailEx.isInverted = true
                let failEx = self.expectation(description: "adDidFail called")
                let displayFailEx = self.expectation(description: "adDidFailToDisplay called")
                displayFailEx.isInverted = true
                adManager.events.sink { event in
                    if event == .adDidFail(error) {
                        failEx.fulfill()
                    }
                    if event == .adDidFailToLoad(error) {
                        loadFailEx.fulfill()
                    }
                    if event == .adDidFailToDisplay(error) {
                        displayFailEx.fulfill()
                    }
                }
                .store(in: &self.storables)
                adManager.ad?.delegate?.didFailOguryBannerAdWithError?(error, for: OguryBannerAd())
                self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 0.5)
            }
        }
    }
    
    func testWhenNonOguryErrorIsForwardedToTheProxyThenGenericCallbackIsCalled() {
        let ad: AdType<BannerAdManager> = .banner
        let adManager = BannerAdManager(adType: ad)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let proxy = MrecProxyDelegate()
            proxy.adManager = adManager
            let loadFailEx = self.expectation(description: "adDidFailToLoad called")
            loadFailEx.isInverted = true
            let failEx = self.expectation(description: "adDidFail called")
            let displayFailEx = self.expectation(description: "adDidFailToDisplay called")
            displayFailEx.isInverted = true
            adManager.events.sink { event in
                if event == .adDidFail(AdManagerError.loadNotCalledBeforeShow) {
                    failEx.fulfill()
                }
                if event == .adDidFailToLoad(AdManagerError.loadNotCalledBeforeShow) {
                    loadFailEx.fulfill()
                }
                if event == .adDidFailToDisplay(AdManagerError.loadNotCalledBeforeShow) {
                    displayFailEx.fulfill()
                }
            }
            .store(in: &self.storables)
            proxy.handle(AdManagerError.loadNotCalledBeforeShow, for: OguryBannerAd())
            self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 0.5)
        }
    }
    
    func testWhenMaxBannerIsUsedThenMaxBiddableIsCalled() {
        let retriever = MaxRetriever(adMarkUpToReturn: "")
        let ad: AdType<BannerAdManager> = .maxHeaderBidding(adType: .banner, adMarkUpRetriever: retriever)
        let adManager = BannerAdManager(adType: ad)
        let vc = UIView()
        adManager.options = BannerAdManagerOptions(view: vc, adDisplayName: "", adUnitId: "")
        let ex = XCTestExpectation(description: "The ad did not load")
        adManager.events.sink { event in
            if event == .adLoading {
                ex.fulfill()
            }
        }
        .store(in: &storables)
        try? adManager.loadAd(from: adManager.options.baseOptions)
        wait(for: [ex], timeout: 0.5)
    }
   
    func testWhenDTFairBidBannerIsUsedThenMaxBiddableIsCalled() {
        let retriever = BTFairBidRetriever(adMarkUpToReturn: "")
        let ad: AdType<BannerAdManager> = .dtFairBidHeaderBidding(adType: .banner, adMarkUpRetriever: retriever)
        let adManager = BannerAdManager(adType: ad)
        let vc = UIView()
        adManager.options = BannerAdManagerOptions(view: vc, adDisplayName: "", adUnitId: "")
        let ex = XCTestExpectation(description: "The ad did not load")
        adManager.events.sink { event in
            if event == .adLoading {
                ex.fulfill()
            }
        }
        .store(in: &storables)
        try? adManager.loadAd(from: adManager.options.baseOptions)
        wait(for: [ex], timeout: 0.5)
    }
    
    func testWhenMaxBannerIsUsedAndBidderReturnNilThenErrorIsDispatched() {
        let retriever = MaxRetriever(adMarkUpToReturn: nil)
        let ad: AdType<BannerAdManager> = .maxHeaderBidding(adType: .banner, adMarkUpRetriever: retriever)
        let adManager = BannerAdManager(adType: ad)
        let vc = UIView()
        adManager.options = BannerAdManagerOptions(view: vc, adDisplayName: "", adUnitId: "")
        let ex = XCTestExpectation(description: "The ad did not load")
        adManager.events.sink { event in
            if event == .adDidFail(AdManagerError.adMarkUpRetrievalFailed("adMarkUp not found")) {
                ex.fulfill()
            }
        }
        .store(in: &storables)
        try? adManager.loadAd(from: adManager.options.baseOptions)
        wait(for: [ex], timeout: 1)
    }
   
    func testWhenDTFairBidBannerIsUsedAndBidderReturnNilThenErrorIsDispatched() {
        let retriever = BTFairBidRetriever(adMarkUpToReturn: nil)
        let ad: AdType<BannerAdManager> = .dtFairBidHeaderBidding(adType: .banner, adMarkUpRetriever: retriever)
        let adManager = BannerAdManager(adType: ad)
        let vc = UIView()
        adManager.options = BannerAdManagerOptions(view: vc, adDisplayName: "", adUnitId: "")
        let ex = XCTestExpectation(description: "The ad did not load")
        adManager.events.sink { event in
            if event == .adDidFail(AdManagerError.adMarkUpRetrievalFailed("adMarkUp not found")) {
                ex.fulfill()
            }
        }
        .store(in: &storables)
        try? adManager.loadAd(from: adManager.options.baseOptions)
        wait(for: [ex], timeout: 1)
    }
    
    func testWhenMaxMpuIsUsedThenMaxBiddableIsCalled() {
        let retriever = MaxRetriever(adMarkUpToReturn: "")
        let ad: AdType<BannerAdManager> = .maxHeaderBidding(adType: .mpu, adMarkUpRetriever: retriever)
        let adManager = BannerAdManager(adType: ad)
        let vc = UIView()
        adManager.options = BannerAdManagerOptions(view: vc, adDisplayName: "", adUnitId: "")
        let ex = XCTestExpectation(description: "The ad did not load")
        adManager.events.sink { event in
            if event == .adLoading {
                ex.fulfill()
            }
        }
        .store(in: &storables)
        try? adManager.loadAd(from: adManager.options.baseOptions)
        wait(for: [ex], timeout: 0.5)
    }
   
    func testWhenDTFairBidMpuIsUsedThenMaxBiddableIsCalled() {
        let retriever = BTFairBidRetriever(adMarkUpToReturn: "")
        let ad: AdType<BannerAdManager> = .dtFairBidHeaderBidding(adType: .mpu, adMarkUpRetriever: retriever)
        let adManager = BannerAdManager(adType: ad)
        let vc = UIView()
        adManager.options = BannerAdManagerOptions(view: vc, adDisplayName: "", adUnitId: "")
        let ex = XCTestExpectation(description: "The ad did not load")
        adManager.events.sink { event in
            if event == .adLoading {
                ex.fulfill()
            }
        }
        .store(in: &storables)
        try? adManager.loadAd(from: adManager.options.baseOptions)
        wait(for: [ex], timeout: 0.5)
    }
    
    func testWhenMaxMpuIsUsedAndBidderReturnNilThenErrorIsDispatched() {
        let retriever = MaxRetriever(adMarkUpToReturn: nil)
        let ad: AdType<BannerAdManager> = .maxHeaderBidding(adType: .mpu, adMarkUpRetriever: retriever)
        let adManager = BannerAdManager(adType: ad)
        let vc = UIView()
        adManager.options = BannerAdManagerOptions(view: vc, adDisplayName: "", adUnitId: "")
        let ex = XCTestExpectation(description: "The ad did not load")
        adManager.events.sink { event in
            if event == .adDidFail(AdManagerError.adMarkUpRetrievalFailed("adMarkUp not found")) {
                ex.fulfill()
            }
        }
        .store(in: &storables)
        try? adManager.loadAd(from: adManager.options.baseOptions)
        wait(for: [ex], timeout: 1)
    }
   
    func testWhenDTFairBidMpuIsUsedAndBidderReturnNilThenErrorIsDispatched() {
        let retriever = BTFairBidRetriever(adMarkUpToReturn: nil)
        let ad: AdType<BannerAdManager> = .dtFairBidHeaderBidding(adType: .mpu, adMarkUpRetriever: retriever)
        let adManager = BannerAdManager(adType: ad)
        let vc = UIView()
        adManager.options = BannerAdManagerOptions(view: vc, adDisplayName: "", adUnitId: "")
        let ex = XCTestExpectation(description: "The ad did not load")
        adManager.events.sink { event in
            if event == .adDidFail(AdManagerError.adMarkUpRetrievalFailed("adMarkUp not found")) {
                ex.fulfill()
            }
        }
        .store(in: &storables)
        try? adManager.loadAd(from: adManager.options.baseOptions)
        wait(for: [ex], timeout: 1)
    }
}
