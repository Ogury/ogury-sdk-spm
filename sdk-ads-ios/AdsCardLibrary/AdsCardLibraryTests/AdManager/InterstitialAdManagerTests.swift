//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import XCTest
@testable import AdsCardLibrary
import OguryAds
////import Mockingbird
import Combine

final class InterstitialAdManagerTests: XCTestCase {
    var storables: [AnyCancellable] = []
    
    //MARK: - Max
    func testWhenMaxInterstitialIsUsedThenMaxBiddableIsCalled() {
        let retriever = MaxRetriever(adMarkUpToReturn: "")
        let inter: AdType<InterstitialAdManager> = .maxHeaderBidding(adType: .interstitial, adMarkUpRetriever: retriever)
        let adManager = InterstitialAdManager(adType: inter)
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
   
    func testWhenDTFairBidInterstitialIsUsedThenDTFairBidBiddableIsCalled() {
        let retriever = BTFairBidRetriever(adMarkUpToReturn: "")
        let inter: AdType<InterstitialAdManager> = .dtFairBidHeaderBidding(adType: .interstitial, adMarkUpRetriever: retriever)
        let adManager = InterstitialAdManager(adType: inter)
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
    
    func testWhenMaxInterstitialIsUsedAndBidderReturnNilThenErrorIsDispatched() {
        let retriever = MaxRetriever(adMarkUpToReturn: nil)
        let inter: AdType<InterstitialAdManager> = .maxHeaderBidding(adType: .interstitial, adMarkUpRetriever: retriever)
        let adManager = InterstitialAdManager(adType: inter)
        adManager.options = AdManagerOptions(viewController: UIViewController(), adDisplayName: "", adUnitId: "")
        let ex = XCTestExpectation(description: "The ad did not load")
        adManager.events.sink { event in
            if event == .adDidFail(AdManagerError.adMarkUpRetrievalFailed("adMarkUp not found")) {
                ex.fulfill()
            }
        }
        .store(in: &storables)
        try? adManager.loadAd(from: adManager.options.baseOptions)
        wait(for: [ex], timeout: 2)
    }
   
    func testWhenDTFairBidInterstitialIsUsedAndBidderReturnNilThenErrorIsDispatched() {
        let retriever = BTFairBidRetriever(adMarkUpToReturn: nil)
        let inter: AdType<InterstitialAdManager> = .dtFairBidHeaderBidding(adType: .interstitial, adMarkUpRetriever: retriever)
        let adManager = InterstitialAdManager(adType: inter)
        adManager.options = AdManagerOptions(viewController: UIViewController(), adDisplayName: "", adUnitId: "")
        let ex = XCTestExpectation(description: "The ad did not load")
        adManager.events.sink { event in
            if event == .adDidFail(AdManagerError.adMarkUpRetrievalFailed("adMarkUp not found")) {
                ex.fulfill()
            }
        }
        .store(in: &storables)
        try? adManager.loadAd(from: adManager.options.baseOptions)
        wait(for: [ex], timeout: 2)
    }
    
    func testWhenInstanciatingInterstitialAdManagerThenAllPropertiesAreSet() {
        let inter: AdType<InterstitialAdManager> = .interstitial
        let adManager = InterstitialAdManager(adType: inter)
        XCTAssertTrue(adManager.adType == inter)
        XCTAssertNotNil(adManager.proxyDelegate)
    }
    
    func testWhenSettingNewAdDelegateThenProxyIsUpdated() {
        let inter: AdType<InterstitialAdManager> = .interstitial
        
        let adManager = InterstitialAdManager(adType: inter)
        let newDelegate = mock(AdLifeCycleDelegate.self)
        adManager.adDelegate = newDelegate
        XCTAssertTrue(adManager.adDelegate as? AdLifeCycleDelegateMock === newDelegate)
        XCTAssertTrue(adManager.proxyDelegate.adDelegate as? AdLifeCycleDelegateMock === newDelegate)
    }
    
    func testWhenCallingLoadWithOptionsThenAdObjectIsInstanciated() {
        let inter: AdType<InterstitialAdManager> = .interstitial
        
        let adManager = InterstitialAdManager(adType: inter)
        adManager.options = AdManagerOptions(viewController: UIViewController(), adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        XCTAssertNotNil(adManager.ad)
        XCTAssertTrue(adManager.ad.delegate === adManager.proxyDelegate)
    }
    
    func testWhenCallingShowWithoutAnyOptionsThenErrorIsThrown() {
        let inter: AdType<InterstitialAdManager> = .interstitial
        
        let adManager = InterstitialAdManager(adType: inter)
        XCTAssertThrowsError(try adManager.showAd())
    }
    
    func testWhenCallingShowWithOptionsThenNoErrorIsThrown() {
        let inter: AdType<InterstitialAdManager> = .interstitial
        let adManager = InterstitialAdManager(adType: inter)
        let vc = UIViewController()
        adManager.options = AdManagerOptions(viewController: vc, adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        XCTAssertNoThrow(try adManager.showAd())
    }
    
    //MARK: Delegates
    func testWhenAdLoadedDelegateIsCalledThenItIsForwardedToProxy() {
        let inter: AdType<InterstitialAdManager> = .interstitial
        let adManager = InterstitialAdManager(adType: inter)
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
        adManager.ad?.delegate?.didLoad?(OguryInterstitialAd())
        wait(for: [ex], timeout: 0.5)
    }
    
    func testWhenAdClickedDelegateIsCalledThenItIsForwardedToProxy() {
        let inter: AdType<InterstitialAdManager> = .interstitial
        
        let adManager = InterstitialAdManager(adType: inter)
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
        adManager.ad?.delegate?.didClick?(OguryInterstitialAd())
        wait(for: [ex], timeout: 0.5)
    }
    
    func testWhenAdDidTriggerImpressionDelegateIsCalledThenItIsForwardedToProxy() {
        let inter: AdType<InterstitialAdManager> = .interstitial
        
        let adManager = InterstitialAdManager(adType: inter)
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
        adManager.ad?.delegate?.didTriggerImpressionOguryInterstitialAd?(OguryInterstitialAd())
        wait(for: [ex], timeout: 0.5)
    }
    
    func testWhenAdDidFailDelegateIsCalledThenItIsForwardedToProxy() {
        let inter: AdType<InterstitialAdManager> = .interstitial
        
        let adManager = InterstitialAdManager(adType: inter)
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
        adManager.ad?.delegate?.didFailOguryInterstitialAdWithError?(error, for: OguryInterstitialAd())
        wait(for: [ex], timeout: 0.5)
    }
    
    func testWhenReceivingLoadingErrorsThenProperDelegateShouldBeCalled() {
        [OguryAdsErrorType.profigNotSyncedError.rawValue,
         OguryAdsErrorType.notLoadedError.rawValue].forEach { errorCode in
           let inter: AdType<InterstitialAdManager> = .interstitial
           var adManager = InterstitialAdManager(adType: inter)
           let vc = UIViewController()
           adManager.options = AdManagerOptions(viewController: vc, adDisplayName: "", adUnitId: "")
           try? adManager.loadAd(from: adManager.options.baseOptions)
            let error = OguryError.createOguryError(withCode: errorCode)
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
            adManager.ad?.delegate?.didFailOguryInterstitialAdWithError?(error, for: OguryInterstitialAd())
            self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 0.5)
        }
    }
    
    func testWhenReceivingDisplayErrorsThenProperDelegateShouldBeCalled() {
        [OguryAdsErrorType.adExpiredError.rawValue,
         OguryAdsErrorType.anotherAdAlreadyDisplayedError.rawValue,
         OguryAdsErrorType.cantShowAdsInPresentingViewControllerError.rawValue].forEach { errorCode in
           let inter: AdType<InterstitialAdManager> = .interstitial
           let adManager = InterstitialAdManager(adType: inter)
           let vc = UIViewController()
           adManager.options = AdManagerOptions(viewController: vc, adDisplayName: "", adUnitId: "")
           try? adManager.loadAd(from: adManager.options.baseOptions)
            let error = OguryError.createOguryError(withCode: errorCode)
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
            adManager.ad?.delegate?.didFailOguryInterstitialAdWithError?(error, for: OguryInterstitialAd())
            self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 0.5)
        }
    }
    
    func testWhenReceivingGenericErrorsThenProperDelegateShouldBeCalled() {
        [OguryAdsErrorType.adDisabledError.rawValue,
         OguryAdsErrorType.assetKeyNotValidError.rawValue,
         OguryAdsErrorType.notAvailableError.rawValue,
         OguryAdsErrorType.sdkInitNotCalledError.rawValue,
         OguryAdsErrorType.unknownError.rawValue].forEach { errorCode in
           let inter: AdType<InterstitialAdManager> = .interstitial
           
           let adManager = InterstitialAdManager(adType: inter)
           let vc = UIViewController()
           adManager.options = AdManagerOptions(viewController: vc, adDisplayName: "", adUnitId: "")
           try? adManager.loadAd(from: adManager.options.baseOptions)
            let error = OguryError.createOguryError(withCode: errorCode)
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
            adManager.ad?.delegate?.didFailOguryInterstitialAdWithError?(error, for: OguryInterstitialAd())
            self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 0.5)
        }
    }
    
    func testWhenNonOguryErrorIsForwardedToTheProxyThenGenericCallbackIsCalled() {
        let inter: AdType<InterstitialAdManager> = .interstitial
        let adManager = InterstitialAdManager(adType: inter)
        let proxy = InterstitialProxyDelegate()
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
        proxy.handle(AdManagerError.loadNotCalledBeforeShow, for: OguryInterstitialAd())
        self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 0.5)
    }
}
