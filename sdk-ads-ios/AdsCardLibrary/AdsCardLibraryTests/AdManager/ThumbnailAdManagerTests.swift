//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import XCTest
@testable import AdsCardLibrary
import OguryAds.OguryThumbnailAd
import Mockingbird
import Combine

final class ThumbnailAdManagerTests: XCTestCase {
    var storables: [AnyCancellable] = []
    func testWhenInstanciatingInterstitialAdManagerThenAllPropertiesAreSet() {
        let ad: AdType<ThumbnailAdManager> = .thumbnail
        let adManager = ThumbnailAdManager(adType: ad)
        XCTAssertTrue(adManager.adType == ad)
        XCTAssertNotNil(adManager.proxyDelegate)
    }
    
    func testWhenSettingNewAdDelegateThenProxyIsUpdated() {
        let ad: AdType<ThumbnailAdManager> = .thumbnail
        
        let adManager = ThumbnailAdManager(adType: ad)
        let newDelegate = mock(AdLifeCycleDelegate.self)
        adManager.adDelegate = newDelegate
        XCTAssertTrue(adManager.adDelegate as? AdLifeCycleDelegateMock === newDelegate)
        XCTAssertTrue(adManager.proxyDelegate.adDelegate as? AdLifeCycleDelegateMock === newDelegate)
    }
    
    func testWhenCallingLoadWithOptionsThenAdObjectIsInstanciated() {
        let ad: AdType<ThumbnailAdManager> = .thumbnail
        
        let adManager = ThumbnailAdManager(adType: ad)
        adManager.options = ThumbnailAdManagerOptions(viewController: UIViewController(), thumbnailOptions: .init(), adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertNotNil(adManager.ad)
            XCTAssertTrue(adManager.ad.delegate === adManager.proxyDelegate)
        }
    }
    
    func testWhenCallingShowWithoutAnyOptionsThenErrorIsThrown() {
        let ad: AdType<ThumbnailAdManager> = .thumbnail
        
        let adManager = ThumbnailAdManager(adType: ad)
        XCTAssertThrowsError(try adManager.showAd())
    }
    
    func testWhenCallingShowWithOptionsThenNoErrorIsThrown() {
        let ad: AdType<ThumbnailAdManager> = .thumbnail
        let adManager = ThumbnailAdManager(adType: ad)
        let vc = UIViewController()
        adManager.options = ThumbnailAdManagerOptions(viewController: vc, thumbnailOptions: .init(), adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                try adManager.showAd()
            } catch {
                XCTFail("Thorw while should not have")
            }
        }
    }
    
    //MARK: Delegates
    func testWhenAdLoadedDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<ThumbnailAdManager> = .thumbnail
        let adManager = ThumbnailAdManager(adType: ad)
        
        let vc = UIViewController()
        adManager.options = ThumbnailAdManagerOptions(viewController: vc, thumbnailOptions: .init(), adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let ex = XCTestExpectation(description: "The ad did not load")
            adManager.events.sink { event in
                if event == .adLoaded(canShow: true) {
                    ex.fulfill()
                }
            }
            .store(in: &self.storables)
            adManager.ad?.delegate?.didLoad?(OguryThumbnailAd())
            self.wait(for: [ex], timeout: 0.5)
        }
    }
    
    func testWhenAdClickedDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<ThumbnailAdManager> = .thumbnail
        let adManager = ThumbnailAdManager(adType: ad)
        
        let vc = UIViewController()
        adManager.options = ThumbnailAdManagerOptions(viewController: vc, thumbnailOptions: .init(), adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let ex = self.expectation(description: "")
            adManager.events.sink { event in
                if event == .adClicked {
                    ex.fulfill()
                }
            }
            .store(in: &self.storables)
            adManager.ad?.delegate?.didClick?(OguryThumbnailAd())
            self.wait(for: [ex], timeout: 0.5)
        }
    }
    
    func testWhenAdClosedDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<ThumbnailAdManager> = .thumbnail
        
        let adManager = ThumbnailAdManager(adType: ad)
        
        
        let vc = UIViewController()
        adManager.options = ThumbnailAdManagerOptions(viewController: vc, thumbnailOptions: .init(), adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let ex = self.expectation(description: "")
            adManager.events.sink { event in
                if event == .adClosed {
                    ex.fulfill()
                }
            }
            .store(in: &self.storables)
            adManager.ad?.delegate?.didClose?(OguryThumbnailAd())
            self.wait(for: [ex], timeout: 0.5)
        }
    }
    
    func testWhenAdDidTriggerImpressionDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<ThumbnailAdManager> = .thumbnail
        
        let adManager = ThumbnailAdManager(adType: ad)
        
        let vc = UIViewController()
        adManager.options = ThumbnailAdManagerOptions(viewController: vc, thumbnailOptions: .init(), adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let ex = self.expectation(description: "")
            adManager.events.sink { event in
                if event == .adDidTriggerImpression {
                    ex.fulfill()
                }
            }
            .store(in: &self.storables)
            adManager.ad?.delegate?.didTriggerImpressionOguryThumbnailAd?(OguryThumbnailAd())
            self.wait(for: [ex], timeout: 0.5)
        }
    }
    
    func testWhenAdDidFailDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<ThumbnailAdManager> = .thumbnail
        
        let adManager = ThumbnailAdManager(adType: ad)
        
        let vc = UIViewController()
        adManager.options = ThumbnailAdManagerOptions(viewController: vc, thumbnailOptions: .init(), adDisplayName: "", adUnitId: "")
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
            adManager.ad?.delegate?.didFailOguryThumbnailAdWithError?(error, for: OguryThumbnailAd())
            self.wait(for: [ex], timeout: 0.5)
        }
    }
    
    func testWhenReceivingLoadingErrorsThenProperDelegateShouldBeCalled() {
            [OguryAdsError.profigNotSyncedError.rawValue,
             OguryAdsError.notLoadedError.rawValue].forEach { errorCode in
               let ad: AdType<ThumbnailAdManager> = .thumbnail
               let adManager = ThumbnailAdManager(adType: ad)
               
               let vc = UIViewController()
               adManager.options = ThumbnailAdManagerOptions(viewController: vc, thumbnailOptions: .init(), adDisplayName: "", adUnitId: "")
               try? adManager.loadAd(from: adManager.options.baseOptions)
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let error = OguryError.createOguryError(withCode: errorCode )
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
                adManager.ad?.delegate?.didFailOguryThumbnailAdWithError?(error, for: OguryThumbnailAd())
                self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 0.5)
            }
        }
    }
    
    func testWhenReceivingDisplayErrorsThenProperDelegateShouldBeCalled() {
            [OguryAdsError.adExpiredError.rawValue,
             OguryAdsError.anotherAdAlreadyDisplayedError.rawValue,
             OguryAdsError.cantShowAdsInPresentingViewControllerError.rawValue].forEach { errorCode in
               let ad: AdType<ThumbnailAdManager> = .thumbnail
               let adManager = ThumbnailAdManager(adType: ad)
               
               let vc = UIViewController()
               adManager.options = ThumbnailAdManagerOptions(viewController: vc, thumbnailOptions: .init(), adDisplayName: "", adUnitId: "")
               try? adManager.loadAd(from: adManager.options.baseOptions)
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let error = OguryError.createOguryError(withCode: errorCode )
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
                adManager.ad?.delegate?.didFailOguryThumbnailAdWithError?(error, for: OguryThumbnailAd())
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
               let ad: AdType<ThumbnailAdManager> = .thumbnail
               
               let adManager = ThumbnailAdManager(adType: ad)
               
               let vc = UIViewController()
               adManager.options = ThumbnailAdManagerOptions(viewController: vc, thumbnailOptions: .init(), adDisplayName: "", adUnitId: "")
               try? adManager.loadAd(from: adManager.options.baseOptions)
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let error = OguryError.createOguryError(withCode: errorCode )
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
                adManager.ad?.delegate?.didFailOguryThumbnailAdWithError?(error, for: OguryThumbnailAd())
                self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 0.5)
            }
        }
    }
    
    func testWhenNonOguryErrorIsForwardedToTheProxyThenGenericCallbackIsCalled() {
        let ad: AdType<ThumbnailAdManager> = .thumbnail
        let adManager = ThumbnailAdManager(adType: ad)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let proxy = ThumbnailProxyDelegate()
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
            proxy.handle(AdManagerError.loadNotCalledBeforeShow, for: OguryThumbnailAd())
            self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 0.5)
        }
    }
}
