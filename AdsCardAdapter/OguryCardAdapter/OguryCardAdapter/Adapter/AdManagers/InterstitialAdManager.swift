//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import OguryAds
import OguryAds.Private
import Combine
import AdsCardLibrary

public final class InterstitialAdManager: OguryAdManager {
    public func encode() -> AdCardContainer {
        AdCardContainer(name: cardName,
                        adType: adType.rawValue,
                        adInformations: .init(adUnitId: adUnitId,
                                              campaignId: adConfiguration.campaignId,
                                              creativeId: adConfiguration.creativeId,
                                              dspCreativeId: adConfiguration.dspCreativeId,
                                              dspRegion: adConfiguration.dspRegion,
                                              settings: .init(oguryTestModeEnabled: cardConfiguration.oguryTestModeEnabled,
                                                              rtbTestModeEnabled: cardConfiguration.rtbTestModeEnabled,
                                                              qaLabel: qaLabel)))
    }
    public static func decode(from container: AdCardContainer) throws(AdCardContainerError) -> any AdManager {
        guard let adType = AdType(rawValue: container.adType) else { throw .invalidAdType }
        return InterstitialAdManager(adType: adType,
                                     adConfiguration: .init(adUnitId: container.adInformations.adUnitId,
                                                            campaignId: container.adInformations.campaignId,
                                                            creativeId: container.adInformations.creativeId,
                                                            dspCreativeId: container.adInformations.dspCreativeId,
                                                            dspRegion: container.adInformations.dspRegion),
                                     cardConfiguration: .init(oguryTestModeEnabled: container.adInformations.settings.oguryTestModeEnabled,
                                                              rtbTestModeEnabled: container.adInformations.settings.rtbTestModeEnabled,
                                                              qaLabel: container.adInformations.settings.qaLabel),
                                     viewController: nil,
                                     adDelegate: nil)
    }
    public var adFormat: AdFormat
    public var adConfiguration: AdConfiguration!
    public var cardConfiguration: CardConfiguration!
    public var viewController: UIViewController?

    public func update(_ adConfiguration: AdConfiguration) {
        if adConfiguration.adUnitId != self.adConfiguration.adUnitId {
            ad = nil
        }
        self.adConfiguration = adConfiguration
    }
    
    public func load() async {
        if (ad == nil) {
            ad = OguryInterstitialAd(adUnitId: adUnitId)
        }
        ad.delegate = proxyDelegate
        ad.setLogOrigin(qaLabel)
        append(.adLoading)
        
        guard let bidder else {
            loadAd()
            return
        }
        do {
            let adMakUp = try await bidder.adMarkUp(adUnitId: adUnitId,
                                                    campaignId: campaignId,
                                                    creativeId: creativeId,
                                                    dspCreative: dspCreativeId,
                                                    dspRegion: dspRegion,
                                                    rtbTestModeEnabled: cardConfiguration.rtbTestModeEnabled)
            guard let adMakUp else {
                append(.adDidFail(AdManagerError.adMarkUpRetrievalFailed("adMarkUp not found")))
                return
            }
            load(from: adMakUp)
        } catch {
            append(.adDidFail(AdManagerError.adMarkUpRetrievalFailed(bidder.description(for: error))))
            return
        }
    }
    
    public func show() {
        if ad == nil {
            ad = OguryInterstitialAd(adUnitId: adUnitId)
            ad.delegate = proxyDelegate
        }
        append(.adDisplaying)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.ad?.show(in: self.viewController!)
        }
    }
    
    public func close() {
        //n/a
    }
    
    public static func == (lhs: InterstitialAdManager, rhs: InterstitialAdManager) -> Bool {
        return lhs.adType == rhs.adType && lhs.ad == rhs.ad
    }
    
    public var events: PassthroughSubject<AdLifeCycleEvent, Never>
    public private(set) var ad: OguryInterstitialAd!
    public private(set) var adType: AdType
    public var adView: AdView {
        var wself: (any AdManager)? = self
        return AdsCardManager().card(for: &wself!)
    }
    public var adDelegate: AdLifeCycleDelegate?  {
        set {
            proxyDelegate.adDelegate = newValue
        }
        
        get {
            proxyDelegate.adDelegate
        }
    }
    internal let proxyDelegate: InterstitialProxyDelegate!
    public var lifeCycleEvents: [AdLifeCycleEventHistory] = []
    public var bidder: HeaderBidable?
    public let id: UUID = UUID()
    
    public convenience init(adType: AdType, viewController: UIViewController?, adDelegate: (any AdsCardLibrary.AdLifeCycleDelegate)?) {
        self.init(adType: adType, adConfiguration: .init(adUnitId: ""), cardConfiguration: .init(), viewController: viewController, adDelegate: adDelegate)
    }
    
    //MARK: Initializer
    public init(adType: AdType,
                adConfiguration: AdConfiguration,
                cardConfiguration: CardConfiguration,
                viewController: UIViewController?,
                adDelegate: AdLifeCycleDelegate? = nil) {
        events = PassthroughSubject<AdLifeCycleEvent, Never>()
        self.adType = adType
        self.adFormat = .interstitial
        self.adConfiguration = adConfiguration
        self.cardConfiguration = cardConfiguration
        self.viewController = viewController
        proxyDelegate = InterstitialProxyDelegate(adDelegate: adDelegate)
        proxyDelegate.adManager = self
        switch adType {
            case .maxHeaderBidding: bidder = MaxBidder(configuration: OguryAdsCardAdapter.configuration)
            case .dtFairBidHeaderBidding: bidder = DTFairBidBidder(configuration: OguryAdsCardAdapter.configuration)
            case .unityLevelPlayHeaderBidding: bidder = UnityLevelPlayBidder(configuration: OguryAdsCardAdapter.configuration)
            default: ()
        }
    }
    
    private func load(from adMarkUp: String) {
        ad.load(withAdMarkup: adMarkUp)
    }
    
    private func loadAd() {
        // if test mode is enabled, then we don't send any other information
        guard !adUnitId.isTestModeOn else {
            ad.load()
            return
        }
        
        if let dspCreativeId, !dspCreativeId.isEmpty,
           let campaignId, !campaignId.isEmpty,
           let creativeId,
           let dspRegion = dspRegion?.displayName, !dspRegion.isEmpty {
            let obj = ad as OguryInterstitialAd
            let sel = NSSelectorFromString("loadWithCampaignId:creativeId:dspCreativeId:dspRegion:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String, String?, String, String) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId, creativeId, dspCreativeId, dspRegion)
        } else if let campaignId, !campaignId.isEmpty,
                  let creativeId, !creativeId.isEmpty {
            let obj = ad as OguryInterstitialAd
            let sel = NSSelectorFromString("loadWithCampaignId:creativeId:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String, String) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId, creativeId)
        } else if let campaignId, !campaignId.isEmpty {
            let obj = ad as OguryInterstitialAd
            let sel = NSSelectorFromString("loadWithCampaignId:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId)
        } else {
            ad.load()
        }
    }
    
    public func showAd() throws {
        guard let viewController else { throw AdManagerError.viewControllerMissing }
        if ad == nil {
            ad = OguryInterstitialAd(adUnitId: adUnitId)
            ad.delegate = proxyDelegate
        }
        append(.adDisplaying)
        DispatchQueue.main.async {
            self.ad?.show(in: viewController)
        }
    }
    
    internal func update(ad: OguryInterstitialAd) {
        self.ad = ad
        ad.delegate = self.proxyDelegate
    }
    
    public func append(_ event: AdLifeCycleEvent) {
        lifeCycleEvents.append(AdLifeCycleEventHistory(event: event))
        events.send(event)
    }
    
    public func killWebview(_ killMode: KillWebviewMode) {
        guard let ad else { return }
        switch killMode {
            case .none: ()
            case .simulate:
                ad.simulateWebviewTerminated()
                
            case .saturate:
                guard let webView = ad.adWebview() else { return }
                kill(webView)
            
            @unknown default:
                fatalError()
        }
    }
}

// We have to use a proxy object because otherwise, we would have to make InterstitialAdManager a final class that inherits from NSObject
// and for some reasons, that leads to unexpected compilation fail
// To overcome easily this, we use a proxy object
internal class InterstitialProxyDelegate: AdDelegateProxy<InterstitialAdManager>, OguryInterstitialAdDelegate {
    func interstitialAdDidLoad(_ interstitialAd: OguryInterstitialAd) {
        guard let adManager else { return }
        adManager.append(.adLoaded(canShow: true))
    }
    
    func interstitialAdDidClick(_ interstitialAd: OguryInterstitialAd) {
        guard let adManager else { return }
        adManager.append(.adClicked)
    }
    
    func interstitialAdDidClose(_ interstitialAd: OguryInterstitialAd) {
        guard let adManager else { return }
        adManager.append(.adClosed)
    }
    
    
    func interstitialAd(_ interstitialAd: OguryInterstitialAd, didFailWithError error: OguryAdError) {
        handle(error)
    }
    
    func interstitialAdDidTriggerImpression(_ interstitialAd: OguryInterstitialAd) {
        guard let adManager else { return }
        adManager.append(.adDidTriggerImpression)
    }
}
