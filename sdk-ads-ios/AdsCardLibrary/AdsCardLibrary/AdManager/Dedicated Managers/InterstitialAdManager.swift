//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import OguryAds
import ComposableArchitecture
import Combine

public final class InterstitialAdManager: AdManager {
    public static func == (lhs: InterstitialAdManager, rhs: InterstitialAdManager) -> Bool {
        return lhs.adType == rhs.adType && lhs.ad == rhs.ad
    }
    
    public var events: PassthroughSubject<AdLifeCycleEvent, Never>
    lazy var store = Store(initialState: AdViewFeature.State(from: self.options), reducer: {
        AdViewFeature(adManager: self)
    })
    public typealias Ad = OguryInterstitialAd
    public typealias Options = AdManagerOptions
    public var adOptionView: (any View)? { nil }
    //MARK: Variables
    public var options: AdManagerOptions!
    public private(set) var ad: OguryInterstitialAd!
    public private(set) var adType: AdType<InterstitialAdManager>
    public var adView: AdView { AdView(store: self.store) }
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
    internal var bidder: HeaderBidable?
    public let id: UUID = UUID()
    
    //MARK: Initializer
    public init(adType: AdType<InterstitialAdManager>, adDelegate: AdLifeCycleDelegate? = nil) {
        events = PassthroughSubject<AdLifeCycleEvent, Never>()
        self.adType = adType
        proxyDelegate = InterstitialProxyDelegate(adDelegate: adDelegate)
        proxyDelegate.adManager = self
        if case let .maxHeaderBidding(_, adMarkUpRetriever) = adType {
            bidder = adMarkUpRetriever
        }
        else if case let .dtFairBidHeaderBidding(_, adMarkUpRetriever) = adType {
            bidder = adMarkUpRetriever
        }
        else if case let .unityLevelPlayHeaderBidding(_, adMarkUpRetriever) = adType {
            bidder = adMarkUpRetriever
        }
    }
    
    public func update(options: BaseAdOptions) {
        if self.options.baseOptions.adUnitId != options.adUnitId {
            ad = nil
        }
        self.options.baseOptions = options
    }
    
    //MARK: Ad Management
    public func loadAd(from options: BaseAdOptions) throws {
        self.options.baseOptions = options
        if (ad == nil) {
            ad = OguryInterstitialAd(adUnitId: options.adUnitId, mediation: OguryMediation(name: "AdsTestApp", version: .sdkVersion))
        }
        ad.delegate = proxyDelegate
        append(.adLoading)
        
        guard let bidder else {
            load()
            return
        }
        Task {
            do {
                let adMakUp = try await bidder.adMarkUp(adUnitId: options.adUnitId,
                                                        campaignId: options.campaignId,
                                                        creativeId: options.creativeId,
                                                        dspCreative: options.dspCreativeId,
                                                        dspRegion: options.dspRegion
                                                        rtbTestModeEnabled: options.rtbTestModeEnabled)
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
    }
    
    private func load(from adMarkUp: String) {
        ad.load(withAdMarkup: adMarkUp)
    }
    
    private func load() {
        if let dspCreativeId = options.baseOptions.dspCreativeId, !dspCreativeId.isEmpty,
           let campaignId = options.baseOptions.campaignId, !campaignId.isEmpty,
           let creativeId = options.baseOptions.creativeId,
           let dspRegion = options.baseOptions.dspRegion?.displayName, !dspRegion.isEmpty {
            let obj = ad as OguryInterstitialAd
            let sel = NSSelectorFromString("loadWithCampaignId:creativeId:dspCreativeId:dspRegion:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String, String?, String, String) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId, creativeId, dspCreativeId, dspRegion)
        } else if let campaignId = options.baseOptions.campaignId,
                  !campaignId.isEmpty,
                  let creativeId = options.baseOptions.creativeId,
                  !creativeId.isEmpty {
            let obj = ad as OguryInterstitialAd
            let sel = NSSelectorFromString("loadWithCampaignId:creativeId:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String, String) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId, creativeId)
        } else if let campaignId = options.baseOptions.campaignId,
                  !campaignId.isEmpty {
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
        guard let options else { throw AdManagerError.noOptions }
        if ad == nil {
            ad = OguryInterstitialAd(adUnitId: options.baseOptions.adUnitId)
            ad.delegate = proxyDelegate
        }
        append(.adDisplaying)
        DispatchQueue.main.async {
            self.ad?.show(in: options.viewController)
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
    
    public func updateCard(events: [AdOptionsEvent]) {
        adView.updateCard(events: events)
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
    
    
    func interstitialAd(_ interstitialAd: OguryInterstitialAd, didFailWithEerror error: OguryAdError) {
        handle(error, for: interstitialAd)
    }
    
    func interstitialAdDidTriggerImpression(_ interstitialAd: OguryInterstitialAd) {
        guard let adManager else { return }
        adManager.append(.adDidTriggerImpression)
    }
}

extension InterstitialAdManager: Storable {
    public convenience init(from data: StorableAdManager) {
        fatalError()
    }
    
    public func encode() -> StorableAdManager {
        StorableAdManager(rawAdType: adType.innerType,
                          options: options,
                          thumbnailOptions: nil)
    }
}
