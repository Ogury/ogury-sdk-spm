//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import XCTest
@testable import AdsCardLibrary
import OguryAds
import Mockingbird
import Combine

final class OptinVideoAdManagerTests: XCTestCase {
    var storables: [AnyCancellable] = []
    
    func testWhenReceivingDisplayErrorsThenProperDelegateShouldBeCalled() {
        [OguryAdsError.adExpiredError.rawValue,
         OguryAdsError.anotherAdAlreadyDisplayedError.rawValue,
         OguryAdsError.cantShowAdsInPresentingViewControllerError.rawValue].forEach { errorCode in
           let ad: AdType<OptInAdManager> = .optInVideo
           let adManager = OptInAdManager(adType: ad)
           let vc = UIViewController()
           adManager.options = AdManagerOptions(viewController: vc, adDisplayName: "", adUnitId: "")
           try? adManager.loadAd(from: adManager.options.baseOptions)
            let error = OguryError.createOguryError(withCode: errorCode as! Int)
            let loadFailEx = expectation(description: "adDidFailToLoad called")
            loadFailEx.isInverted = true
            let failEx = expectation(description: "adDidFail called")
            failEx.isInverted = true
            let displayFailEx = expectation(description: "adDidFailToDisplay called")
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
            .store(in: &storables)
            adManager.ad?.delegate?.didFailOguryOptinVideoAdWithError?(error, for: OguryOptinVideoAd())
            self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 0.5)
        }
    }
    
    func testWhenReceivingGenericErrorsThenProperDelegateShouldBeCalled() {
        [OguryAdsError.adDisabledError.rawValue,
         OguryAdsError.assetKeyNotValidError.rawValue,
         OguryAdsError.notAvailableError.rawValue,
         OguryAdsError.sdkInitNotCalledError.rawValue,
         OguryAdsError.unknownError.rawValue].forEach { errorCode in
           let ad: AdType<OptInAdManager> = .optInVideo
           let adManager = OptInAdManager(adType: ad)
           let vc = UIViewController()
           adManager.options = AdManagerOptions(viewController: vc, adDisplayName: "", adUnitId: "")
           try? adManager.loadAd(from: adManager.options.baseOptions)
            let error = OguryError.createOguryError(withCode: errorCode as! Int)
            let loadFailEx = expectation(description: "adDidFailToLoad called")
            loadFailEx.isInverted = true
            let failEx = expectation(description: "adDidFail called")
            let displayFailEx = expectation(description: "adDidFailToDisplay called")
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
            .store(in: &storables)
            adManager.ad?.delegate?.didFailOguryOptinVideoAdWithError?(error, for: OguryOptinVideoAd())
            self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 0.5)
        }
    }
    
    func testWhenNonOguryErrorIsForwardedToTheProxyThenGenericCallbackIsCalled() {
        let ad: AdType<OptInAdManager> = .optInVideo
        let adManager = OptInAdManager(adType: ad)
        let proxy = OptInProxyDelegate()
        proxy.adManager = adManager
        let loadFailEx = expectation(description: "adDidFailToLoad called")
        loadFailEx.isInverted = true
        let failEx = expectation(description: "adDidFail called")
        let displayFailEx = expectation(description: "adDidFailToDisplay called")
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
        .store(in: &storables)
        proxy.handle(AdManagerError.loadNotCalledBeforeShow, for: OguryOptinVideoAd())
        self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 2)
    }
    
    func testWhenInstanciatingInterstitialAdManagerThenAllPropertiesAreSet() {
        let ad: AdType<OptInAdManager> = .optInVideo
        let adManager = OptInAdManager(adType: ad)
        XCTAssertTrue(adManager.adType == ad)
        XCTAssertNotNil(adManager.proxyDelegate)
    }
    
    func testWhenSettingNewAdDelegateThenProxyIsUpdated() {
        let ad: AdType<OptInAdManager> = .optInVideo
        
        let adManager = OptInAdManager(adType: ad)
        let newDelegate = mock(AdLifeCycleDelegate.self)
        adManager.adDelegate = newDelegate
        XCTAssertTrue(adManager.adDelegate as? AdLifeCycleDelegateMock === newDelegate)
        XCTAssertTrue(adManager.proxyDelegate.adDelegate as? AdLifeCycleDelegateMock === newDelegate)
    }
    
    func testWhenCallingLoadWithOptionsThenAdObjectIsInstanciated() {
        let ad: AdType<OptInAdManager> = .optInVideo
        
        let adManager = OptInAdManager(adType: ad)
        adManager.options = AdManagerOptions(viewController: UIViewController(), adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        XCTAssertNotNil(adManager.ad)
        XCTAssertTrue(adManager.ad.delegate === adManager.proxyDelegate)
    }
    
    func testWhenCallingShowWithoutAnyOptionsThenErrorIsThrown() {
        let ad: AdType<OptInAdManager> = .optInVideo
        
        let adManager = OptInAdManager(adType: ad)
        XCTAssertThrowsError(try adManager.showAd())
    }
    
    func testWhenCallingShowWithOptionsThenNoErrorIsThrown() {
        let ad: AdType<OptInAdManager> = .optInVideo
        let adManager = OptInAdManager(adType: ad)
        let vc = UIViewController()
        adManager.options = AdManagerOptions(viewController: vc, adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        XCTAssertNoThrow(try adManager.showAd())
    }
    
    //MARK: Delegates
    func testWhenAdLoadedDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<OptInAdManager> = .optInVideo
        let adManager = OptInAdManager(adType: ad)
        let vc = UIViewController()
        adManager.options = AdManagerOptions(viewController: vc, adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        let ex = XCTestExpectation(description: "The ad did not load")
        adManager.events.sink { event in
            if event == .adLoaded(canShow: true) {
                ex.fulfill()
            }
        }
        .store(in: &storables)
        adManager.ad?.delegate?.didLoad?(OguryOptinVideoAd())
        wait(for: [ex], timeout: 0.5)
    }
    
    func testWhenAdClickedDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<OptInAdManager> = .optInVideo
        
        let adManager = OptInAdManager(adType: ad)
        let vc = UIViewController()
        adManager.options = AdManagerOptions(viewController: vc, adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        let ex = expectation(description: "")
        adManager.events.sink { event in
            if event == .adClicked {
                ex.fulfill()
            }
        }
        .store(in: &storables)
        adManager.ad?.delegate?.didClick?(OguryOptinVideoAd())
        wait(for: [ex], timeout: 0.5)
    }
    
    func testWhenAdDisplayedDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<OptInAdManager> = .optInVideo
        
        let adManager = OptInAdManager(adType: ad)
        let vc = UIViewController()
        adManager.options = AdManagerOptions(viewController: vc, adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        let ex = expectation(description: "")
        adManager.events.sink { event in
            if event == .adDisplayed {
                ex.fulfill()
            }
        }
        .store(in: &storables)
        adManager.ad?.delegate?.didDisplay?(OguryOptinVideoAd())
        wait(for: [ex], timeout: 0.5)
    }
    
    func testWhenAdClosedDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<OptInAdManager> = .optInVideo
        
        let adManager = OptInAdManager(adType: ad)
        let vc = UIViewController()
        adManager.options = AdManagerOptions(viewController: vc, adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        let ex = expectation(description: "")
        adManager.events.sink { event in
            if event == .adClosed {
                ex.fulfill()
            }
        }
        .store(in: &storables)
        adManager.ad?.delegate?.didClose?(OguryOptinVideoAd())
        wait(for: [ex], timeout: 0.5)
    }
    
    func testWhenAdDidTriggerImpressionDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<OptInAdManager> = .optInVideo
        
        let adManager = OptInAdManager(adType: ad)
        let vc = UIViewController()
        adManager.options = AdManagerOptions(viewController: vc, adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        let ex = expectation(description: "")
        adManager.events.sink { event in
            if event == .adDidTriggerImpression {
                ex.fulfill()
            }
        }
        .store(in: &storables)
        adManager.ad?.delegate?.didTriggerImpressionOguryOptinVideoAd?(OguryOptinVideoAd())
        wait(for: [ex], timeout: 0.5)
    }
    
    func testWhenAdDidFailDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<OptInAdManager> = .optInVideo
        
        let adManager = OptInAdManager(adType: ad)
        let vc = UIViewController()
        adManager.options = AdManagerOptions(viewController: vc, adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        let error = OguryError.createOguryError(withCode: 666)
        let ex = expectation(description: "")
        adManager.events.sink { event in
            if event == .adDidFail(error) {
                ex.fulfill()
            }
        }
        .store(in: &storables)
        adManager.ad?.delegate?.didFailOguryOptinVideoAdWithError?(error, for: OguryOptinVideoAd())
        wait(for: [ex], timeout: 0.5)
    }
    
    func testWhenReceivingLoadingErrorsThenProperDelegateShouldBeCalled() {
        [OguryAdsError.profigNotSyncedError.rawValue,
         OguryAdsError.notLoadedError.rawValue].forEach { errorCode in
           let ad: AdType<OptInAdManager> = .optInVideo
           var adManager = OptInAdManager(adType: ad)
           let vc = UIViewController()
           adManager.options = AdManagerOptions(viewController: vc, adDisplayName: "", adUnitId: "")
           try? adManager.loadAd(from: adManager.options.baseOptions)
            let error = OguryError.createOguryError(withCode: errorCode as! Int)
            let loadFailEx = expectation(description: "adDidFailToLoad called")
            let failEx = expectation(description: "adDidFail called")
            failEx.isInverted = true
            let displayFailEx = expectation(description: "adDidFailToDisplay called")
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
            .store(in: &storables)
            adManager.ad?.delegate?.didFailOguryOptinVideoAdWithError?(error, for: OguryOptinVideoAd())
            self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 0.5)
        }
    }
    
    func testWhenMaxOptInVideoIsUsedThenMaxBiddableIsCalled() {
        let retriever = MaxRetriever(adMarkUpToReturn: "")
        let ad: AdType<OptInAdManager> = .maxHeaderBidding(adType: .optInVideo, adMarkUpRetriever: retriever)
        let adManager = OptInAdManager(adType: ad)
        adManager.options = AdManagerOptions(viewController: UIViewController(), adDisplayName: "", adUnitId: "")
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
   
    func testWhenDTFairBidOptInVideoIsUsedThenMaxBiddableIsCalled() {
        let retriever = BTFairBidRetriever(adMarkUpToReturn: "")
        let ad: AdType<OptInAdManager> = .dtFairBidHeaderBidding(adType: .optInVideo, adMarkUpRetriever: retriever)
        let adManager = OptInAdManager(adType: ad)
        adManager.options = AdManagerOptions(viewController: UIViewController(), adDisplayName: "", adUnitId: "")
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
    
    func testWhenMaxOptInVideoIsUsedAndBidderReturnNilThenErrorIsDispatched() {
        let retriever = MaxRetriever(adMarkUpToReturn: nil)
        let ad: AdType<OptInAdManager> = .maxHeaderBidding(adType: .optInVideo, adMarkUpRetriever: retriever)
        let adManager = OptInAdManager(adType: ad)
        adManager.options = AdManagerOptions(viewController: UIViewController(), adDisplayName: "", adUnitId: "")
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
   
    func testWhenDTFairBidOptInVideoIsUsedAndBidderReturnNilThenErrorIsDispatched() {
        let retriever = BTFairBidRetriever(adMarkUpToReturn: nil)
        let ad: AdType<OptInAdManager> = .dtFairBidHeaderBidding(adType: .optInVideo, adMarkUpRetriever: retriever)
        let adManager = OptInAdManager(adType: ad)
        adManager.options = AdManagerOptions(viewController: UIViewController(), adDisplayName: "", adUnitId: "")
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
