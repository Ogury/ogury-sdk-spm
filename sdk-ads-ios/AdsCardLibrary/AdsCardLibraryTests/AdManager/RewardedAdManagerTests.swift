//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import XCTest
@testable import AdsCardLibrary
import OguryAds
import Combine

final class RewardedAdManagerTests: XCTestCase {
    var storables: [AnyCancellable] = []
    
    func testWhenReceivingDisplayErrorsThenProperDelegateShouldBeCalled() {
        [OguryShowErrorCode.adExpired.rawValue,
         OguryShowErrorCode.anotherAdAlreadyDisplayed.rawValue,
         OguryShowErrorCode.viewControllerPreventsAdFromBeingDisplayed.rawValue].forEach { errorCode in
           let ad: AdType<RewardedAdManager> = .rewarded
           let adManager = RewardedAdManager(adType: ad)
           let vc = UIViewController()
           adManager.options = AdManagerOptions(viewController: vc, adDisplayName: "", adUnitId: "")
           try? adManager.loadAd(from: adManager.options.baseOptions)
            let error = OguryAdError(domain: "", code: errorCode as! Int)
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
            adManager.ad?.delegate?.rewardedAd?(OguryRewardedAd(), didFailWithError: error)
            self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 0.5)
        }
    }
    
    func testWhenReceivingGenericErrorsThenProperDelegateShouldBeCalled() {
        [OguryLoadErrorCode.adDisabledConsentDenied.rawValue,
         OguryLoadErrorCode.sdkNotStarted.rawValue,
         OguryLoadErrorCode.invalidConfiguration.rawValue,
         OguryLoadErrorCode.adDisabledConsentMissing.rawValue,
         OguryLoadErrorCode.adDisabledCountryNotOpened.rawValue,
         OguryLoadErrorCode.adDisabledUnspecifiedReason.rawValue].forEach { errorCode in
           let ad: AdType<RewardedAdManager> = .rewarded
           let adManager = RewardedAdManager(adType: ad)
           let vc = UIViewController()
           adManager.options = AdManagerOptions(viewController: vc, adDisplayName: "", adUnitId: "")
           try? adManager.loadAd(from: adManager.options.baseOptions)
            let error = OguryAdError(domain: "", code: errorCode as! Int)
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
            adManager.ad?.delegate?.rewardedAd?(OguryRewardedAd(), didFailWithError: error)
            self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 0.5)
        }
    }
    
    func testWhenNonOguryErrorIsForwardedToTheProxyThenGenericCallbackIsCalled() {
        let ad: AdType<RewardedAdManager> = .rewarded
        let adManager = RewardedAdManager(adType: ad)
        let proxy = RewardedProxyDelegate()
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
        proxy.handle(AdManagerError.loadNotCalledBeforeShow, for: OguryRewardedAd())
        self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 2)
    }
    
    func testWhenInstanciatingInterstitialAdManagerThenAllPropertiesAreSet() {
        let ad: AdType<RewardedAdManager> = .rewarded
        let adManager = RewardedAdManager(adType: ad)
        XCTAssertTrue(adManager.adType == ad)
        XCTAssertNotNil(adManager.proxyDelegate)
    }
    
    func testWhenSettingNewAdDelegateThenProxyIsUpdated() {
        let ad: AdType<RewardedAdManager> = .rewarded
        
        let adManager = RewardedAdManager(adType: ad)
        let newDelegate = MockAdLifeCycleDelegate()
        adManager.adDelegate = newDelegate
        XCTAssertTrue(adManager.adDelegate as? MockAdLifeCycleDelegate === newDelegate)
        XCTAssertTrue(adManager.proxyDelegate.adDelegate as? MockAdLifeCycleDelegate === newDelegate)
    }
    
    func testWhenCallingLoadWithOptionsThenAdObjectIsInstanciated() {
        let ad: AdType<RewardedAdManager> = .rewarded
        
        let adManager = RewardedAdManager(adType: ad)
        adManager.options = AdManagerOptions(viewController: UIViewController(), adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        XCTAssertNotNil(adManager.ad)
        XCTAssertTrue(adManager.ad.delegate === adManager.proxyDelegate)
    }
    
    func testWhenCallingShowWithoutAnyOptionsThenErrorIsThrown() {
        let ad: AdType<RewardedAdManager> = .rewarded
        
        let adManager = RewardedAdManager(adType: ad)
        XCTAssertThrowsError(try adManager.showAd())
    }
    
    func testWhenCallingShowWithOptionsThenNoErrorIsThrown() {
        let ad: AdType<RewardedAdManager> = .rewarded
        let adManager = RewardedAdManager(adType: ad)
        let vc = UIViewController()
        adManager.options = AdManagerOptions(viewController: vc, adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        XCTAssertNoThrow(try adManager.showAd())
    }
    
    //MARK: Delegates
    func testWhenAdLoadedDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<RewardedAdManager> = .rewarded
        let adManager = RewardedAdManager(adType: ad)
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
        adManager.ad?.delegate?.rewardedAdDidLoad?(OguryRewardedAd())
        wait(for: [ex], timeout: 0.5)
    }
    
    func testWhenAdClickedDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<RewardedAdManager> = .rewarded
        
        let adManager = RewardedAdManager(adType: ad)
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
        adManager.ad?.delegate?.rewardedAdDidClick?(OguryRewardedAd())
        wait(for: [ex], timeout: 0.5)
    }
    
    func testWhenAdClosedDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<RewardedAdManager> = .rewarded
        
        let adManager = RewardedAdManager(adType: ad)
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
        adManager.ad?.delegate?.rewardedAdDidClose?(OguryRewardedAd())
        wait(for: [ex], timeout: 0.5)
    }
    
    func testWhenAdDidTriggerImpressionDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<RewardedAdManager> = .rewarded
        
        let adManager = RewardedAdManager(adType: ad)
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
        adManager.ad?.delegate?.rewardedAdDidTriggerImpression?(OguryRewardedAd())
        wait(for: [ex], timeout: 0.5)
    }
    
    func testWhenAdDidFailDelegateIsCalledThenItIsForwardedToProxy() {
        let ad: AdType<RewardedAdManager> = .rewarded
        
        let adManager = RewardedAdManager(adType: ad)
        let vc = UIViewController()
        adManager.options = AdManagerOptions(viewController: vc, adDisplayName: "", adUnitId: "")
        try? adManager.loadAd(from: adManager.options.baseOptions)
        let error = OguryAdError.createOguryError(withCode: 666)
        let ex = expectation(description: "")
        adManager.events.sink { event in
            if event == .adDidFail(error!) {
                ex.fulfill()
            }
        }
        .store(in: &storables)
        adManager.ad?.delegate?.rewardedAd?(OguryRewardedAd(), didFailWithError: error!)
        wait(for: [ex], timeout: 0.5)
    }
    
    func testWhenReceivingLoadingErrorsThenProperDelegateShouldBeCalled() {
        [OguryLoadErrorCode.sdkNotProperlyInitialized.rawValue,
         OguryShowErrorCode.noAdLoaded.rawValue].forEach { errorCode in
           let ad: AdType<RewardedAdManager> = .rewarded
           var adManager = RewardedAdManager(adType: ad)
           let vc = UIViewController()
           adManager.options = AdManagerOptions(viewController: vc, adDisplayName: "", adUnitId: "")
           try? adManager.loadAd(from: adManager.options.baseOptions)
            let error = OguryAdError(domain: "", code: errorCode as! Int)
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
            adManager.ad?.delegate?.rewardedAd?(OguryRewardedAd(), didFailWithError: error)
            self.wait(for: [loadFailEx, failEx, displayFailEx], timeout: 0.5)
        }
    }
    
    func testWhenMaxOptInVideoIsUsedThenMaxBiddableIsCalled() {
        let retriever = MaxRetriever(adMarkUpToReturn: "")
        let ad: AdType<RewardedAdManager> = .maxHeaderBidding(adType: .rewarded, adMarkUpRetriever: retriever)
        let adManager = RewardedAdManager(adType: ad)
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
        let ad: AdType<RewardedAdManager> = .dtFairBidHeaderBidding(adType: .rewarded, adMarkUpRetriever: retriever)
        let adManager = RewardedAdManager(adType: ad)
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
    
    func testWhenUnityLevelPlayOptInVideoIsUsedThenMaxBiddableIsCalled() {
        let retriever = UnityLevelPlayRetriever(adMarkUpToReturn: "")
        let ad: AdType<RewardedAdManager> = .unityLevelPlayHeaderBidding(adType: .rewarded, adMarkUpRetriever: retriever)
        let adManager = RewardedAdManager(adType: ad)
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
        let ad: AdType<RewardedAdManager> = .maxHeaderBidding(adType: .rewarded, adMarkUpRetriever: retriever)
        let adManager = RewardedAdManager(adType: ad)
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
        let ad: AdType<RewardedAdManager> = .dtFairBidHeaderBidding(adType: .rewarded, adMarkUpRetriever: retriever)
        let adManager = RewardedAdManager(adType: ad)
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
    
    func testWhenUnityLevelPlayOptInVideoIsUsedAndBidderReturnNilThenErrorIsDispatched() {
        let retriever = UnityLevelPlayRetriever(adMarkUpToReturn: nil)
        let ad: AdType<RewardedAdManager> = .unityLevelPlayHeaderBidding(adType: .rewarded, adMarkUpRetriever: retriever)
        let adManager = RewardedAdManager(adType: ad)
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
