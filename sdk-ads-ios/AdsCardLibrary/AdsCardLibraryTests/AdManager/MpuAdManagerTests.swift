//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import XCTest
@testable import AdsCardLibrary
import OguryAds.OguryThumbnailAd
import Mockingbird
import CwlPreconditionTesting
import Combine

final class MpuAdManagerTests: XCTestCase {
    var storables: [AnyCancellable] = []
    func testWhenInstanciatingInterstitialAdManagerThenAllPropertiesAreSet() {
        let ad: AdType<BannerAdManager> = .mpu
        let adManager = BannerAdManager(adType: ad)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(adManager.adType == ad)
            XCTAssertNotNil(adManager.proxyDelegate)
        }
    }
    
    func testWhenSettingNewAdDelegateThenProxyIsUpdated() {
        let ad: AdType<BannerAdManager> = .mpu
        
        let adManager = BannerAdManager(adType: ad)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let newDelegate = mock(AdLifeCycleDelegate.self)
            adManager.adDelegate = newDelegate
            XCTAssertTrue(adManager.adDelegate as? AdLifeCycleDelegateMock === newDelegate)
            XCTAssertTrue(adManager.proxyDelegate.adDelegate as? AdLifeCycleDelegateMock === newDelegate)
        }
    }
    
    func testWhenCallingLoadWithOptionsThenAdObjectIsInstanciated() {
        let ad: AdType<BannerAdManager> = .mpu
        
        let adManager = BannerAdManager(adType: ad)
        adManager.options = BannerAdManagerOptions(view: UIView(), adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertNotNil(adManager.ad)
            XCTAssertTrue(adManager.ad.delegate === adManager.proxyDelegate)
        }
    }
    
    func testWhenCallingShowWithoutAnyOptionsThenErrorIsThrown() {
        let ad: AdType<BannerAdManager> = .mpu
        
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
        let ad: AdType<BannerAdManager> = .mpu
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
        let ad: AdType<BannerAdManager> = .mpu
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
            adManager.ad?.delegate?.didLoad?(OguryBannerAdView())
            self.wait(for: [ex], timeout: 0.5)
        }
    }
    
    func testWhenAdClickedDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<BannerAdManager> = .mpu
        
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
            adManager.ad?.delegate?.didClick?(OguryBannerAdView())
            self.wait(for: [ex], timeout: 0.5)
        }
    }
    
    func testWhenAdClosedDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<BannerAdManager> = .mpu
        
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
            adManager.ad?.delegate?.didClose?(OguryBannerAdView())
            self.wait(for: [ex], timeout: 0.5)
        }
    }
    
    func testWhenAdDidTriggerImpressionDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<BannerAdManager> = .mpu
        
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
            adManager.ad?.delegate?.didTriggerImpressionOguryBannerAdView?(OguryBannerAdView())
            self.wait(for: [ex], timeout: 0.5)
        }
    }
    
    func testWhenAdDidFailDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<BannerAdManager> = .mpu
        
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
            adManager.ad?.delegate?.didFailOguryBannerAdWithError?(error, for: OguryBannerAdView())
            self.wait(for: [ex], timeout: 0.5)
        }
    }
    
    func testWhenReceivingLoadingErrorsThenProperDelegateShouldBeCalled() {
            [OguryAdsErrorType.profigNotSyncedError.rawValue,
             OguryAdsErrorType.notLoadedError.rawValue].forEach { errorCode in
               let ad: AdType<BannerAdManager> = .mpu
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
                adManager.ad?.delegate?.didFailOguryBannerAdWithError?(error, for: OguryBannerAdView())
                self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 0.5)
            }
        }
    }
    
    func testWhenReceivingDisplayErrorsThenProperDelegateShouldBeCalled() {
            [OguryAdsErrorType.adExpiredError.rawValue,
             OguryAdsErrorType.anotherAdAlreadyDisplayedError.rawValue,
             OguryAdsErrorType.cantShowAdsInPresentingViewControllerError.rawValue].forEach { errorCode in
               let ad: AdType<BannerAdManager> = .mpu
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
                adManager.ad?.delegate?.didFailOguryBannerAdWithError?(error, for: OguryBannerAdView())
                self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 0.5)
            }
        }
    }
    
    func testWhenReceivingGenericErrorsThenProperDelegateShouldBeCalled() {
            [OguryAdsErrorType.adDisabledError.rawValue,
             OguryAdsErrorType.assetKeyNotValidError.rawValue,
             OguryAdsErrorType.notAvailableError.rawValue,
             OguryAdsErrorType.sdkInitNotCalledError.rawValue,
             OguryAdsErrorType.unknownError.rawValue].forEach { errorCode in
               let ad: AdType<BannerAdManager> = .mpu
               
               let adManager = BannerAdManager(adType: ad)
               let vc = UIView()
               adManager.options = BannerAdManagerOptions(view: vc, adDisplayName: "", adUnitId: "")
               try? adManager.loadAd(from: adManager.options.baseOptions)
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                adManager.ad?.delegate?.didFailOguryBannerAdWithError?(error, for: OguryBannerAdView())
                self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 0.5)
            }
        }
    }
    
    func testWhenNonOguryErrorIsForwardedToTheProxyThenGenericCallbackIsCalled() {
        let ad: AdType<BannerAdManager> = .mpu
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
            proxy.handle(AdManagerError.loadNotCalledBeforeShow, for: OguryBannerAdView())
            self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 0.5)
        }
    }
}
