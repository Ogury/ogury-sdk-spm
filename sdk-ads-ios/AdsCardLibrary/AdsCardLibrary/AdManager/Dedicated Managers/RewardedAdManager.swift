//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import OguryAds
import OguryAds.Private
import ComposableArchitecture
import Combine

public final class RewardedAdManager: AdManager {
    public static func == (lhs: RewardedAdManager, rhs: RewardedAdManager) -> Bool {
        return lhs.adType == rhs.adType && lhs.ad == rhs.ad
    }
    
    public var events: PassthroughSubject<AdLifeCycleEvent, Never>
   lazy var store = Store(initialState: AdViewFeature.State(from: self.options,
                                                            adType: AnyAdType(self.adType),
                                                            rewardedOptions: RewardedOptions()), reducer: {
        AdViewFeature(adManager: self)
    })
    public typealias Ad = OguryRewardedAd
    public typealias Options = AdManagerOptions
    public var adOptionView: (any View)? { nil }
    //MARK: Variables
    public var options: AdManagerOptions!
    public private(set) var ad: OguryRewardedAd!
    public private(set) var adType: AdType<RewardedAdManager>
    public var adView: AdView { AdView(store: self.store) }
    public var adDelegate: AdLifeCycleDelegate? {
        set {
            proxyDelegate.adDelegate = newValue
        }
        
        get {
            proxyDelegate.adDelegate
        }
    }
    internal let proxyDelegate: RewardedProxyDelegate!
    public var lifeCycleEvents: [AdLifeCycleEventHistory] = []
    internal var bidder: HeaderBidable?
    public let id: UUID = UUID()
    
    //MARK: Initializer
    public init(adType: AdType<RewardedAdManager>, adDelegate: AdLifeCycleDelegate? = nil) {
        events = PassthroughSubject<AdLifeCycleEvent, Never>()
        self.adType = adType
        proxyDelegate = RewardedProxyDelegate(adDelegate: adDelegate)
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
            ad = OguryRewardedAd(adUnitId: options.adUnitId, mediation: OguryMediation(name: "AdsTestApp", version: .sdkVersion))
        }
        ad.delegate = proxyDelegate
        ad.setLogOrigin(options.qaLabel)
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
                                                        dspRegion: options.dspRegion,
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
            let obj = ad as OguryRewardedAd
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
            let obj = ad as OguryRewardedAd
            let sel = NSSelectorFromString("loadWithCampaignId:creativeId:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String, String) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId, creativeId)
        } else if let campaignId = options.baseOptions.campaignId,
                  !campaignId.isEmpty {
            let obj = ad as OguryRewardedAd
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
            ad = OguryRewardedAd(adUnitId: options.baseOptions.adUnitId)
            ad.delegate = proxyDelegate
        }
        DispatchQueue.main.async {
            self.ad?.show(in: options.viewController)
        }
        append(.adDisplaying)
    }
    
    internal func update(ad: OguryRewardedAd) {
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
    
    public func killWebview(_ killMode: KillWebviewMode) {
        guard let ad else { return }
        switch killMode {
            case .none: ()
            case .simulate:
                ad.simulateWebviewTerminated()
                
            case .saturate:
                guard let webView = ad.adWebview() else { return }
                kill(webView)
        }
    }
}

// We have to use a proxy object because otherwise, we would have to make InterstitialAdManager a final class that inherits from NSObject
// and for some reasons, that leads to unexpected compilation fail
// To overcome easily this, we use a proxy object
internal class RewardedProxyDelegate: AdDelegateProxy<RewardedAdManager>, OguryRewardedAdDelegate {
    func rewardedAdDidLoad(_ rewardedAd: OguryRewardedAd) {
        guard let adManager else { return }
        adManager.append(.adLoaded(canShow: true))
    }
    
    func rewardedAdDidClick(_ rewardedAd: OguryRewardedAd) {
        guard let adManager else { return }
        adManager.append(.adClicked)
    }
    
    func rewardedAdDidClose(_ rewardedAd: OguryRewardedAd) {
        guard let adManager else { return }
        adManager.append(.adClosed)
    }
    
    func rewardedAd(_ rewardedAd: OguryRewardedAd, didFailWithError error: OguryAdError) {
        handle(error, for: rewardedAd)
    }
    
    func rewardedAdDidTriggerImpression(_ rewardedAd: OguryRewardedAd) {
        guard let adManager else { return }
        adManager.append(.adDidTriggerImpression)
    }
    
    func rewardedAd(_ rewardedAd: OguryRewardedAd, didReceive item: OguryReward) {
        guard let adManager else { return }
        adManager.append(.rewardReady(item))
    }
}

extension RewardedAdManager: Storable {
    public convenience init(from data: StorableAdManager) {
        fatalError()
    }
    
    public func encode() -> StorableAdManager {
        StorableAdManager(rawAdType: adType.innerType,
                          options: options,
                          thumbnailOptions: nil)
    }
}
