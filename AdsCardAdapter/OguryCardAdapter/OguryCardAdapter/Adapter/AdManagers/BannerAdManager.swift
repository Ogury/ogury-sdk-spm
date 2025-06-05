//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import OguryAds
import OguryAds.Private
import Combine
import AdsCardLibrary

internal class BannerAdManagerSize: BannerSize {
    let internalSize: OguryBannerAdSize!
    init(internalSize: OguryBannerAdSize!, image: Image) {
        self.internalSize = internalSize
        super.init(size: internalSize.getSize(), image: image)
    }
}

public final class BannerAdManager: OguryAdManager {
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
        return BannerAdManager(adType: adType,
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
    public let bannerSizes: [BannerSize]? = [
        BannerAdManagerSize.init(internalSize: OguryBannerAdSize.small_banner_320x50(), image: Image(systemName: "inset.filled.bottomthird.rectangle")),
        BannerAdManagerSize.init(internalSize: OguryBannerAdSize.mrec_300x250(), image: Image(systemName: "inset.filled.rectangle"))
    ]
    public var adConfiguration: AdConfiguration!
    public var cardConfiguration: CardConfiguration!
    public var viewController: UIViewController?
    
    public func update(_ adConfiguration: AdConfiguration) {
        if adConfiguration.adUnitId != self.adUnitId {
            ad = nil
        }
        self.adConfiguration = adConfiguration
    }
    
    public func load() async {
        Task { @MainActor [weak self] in
            guard let self else { return }
            if (self.ad == nil) {
                self.ad = OguryBannerAdView(adUnitId: self.adConfiguration.adUnitId, size: size.internalSize)
            }
            self.ad.delegate = self.proxyDelegate
            self.ad.setLogOrigin(self.cardConfiguration.qaLabel)
            self.append(.adLoading)
            guard let bidder = self.bidder else {
                self.loadAd()
                return
            }
            Task {
                do {
                    let adMakUp = try await bidder.adMarkUp(adUnitId: self.adUnitId,
                                                            campaignId: self.campaignId,
                                                            creativeId: self.creativeId,
                                                            dspCreative: self.dspCreativeId,
                                                            dspRegion: self.dspRegion,
                                                            rtbTestModeEnabled: self.cardConfiguration.rtbTestModeEnabled)
                    guard let adMakUp else {
                        self.append(.adDidFail(AdManagerError.adMarkUpRetrievalFailed("adMarkUp not found")))
                        return
                    }
                    self.load(from: adMakUp)
                } catch {
                    self.append(.adDidFail(AdManagerError.adMarkUpRetrievalFailed(bidder.description(for: error))))
                    return
                }
            }
        }
    }
    
    public func show() {
        if (ad == nil) {
            ad = OguryBannerAdView(adUnitId: adConfiguration.adUnitId, size: size.internalSize)
            ad.delegate = proxyDelegate
        }
        append(.bannerReady(ad!))
    }
    
    public func close() {
        ad?.delegate = nil
        ad?.destroy()
        ad = nil
        append(.adClosed)
    }
    
    public static func == (lhs: BannerAdManager, rhs: BannerAdManager) -> Bool {
        return lhs.adType == rhs.adType && lhs.ad == rhs.ad
    }
    
    public var events: PassthroughSubject<AdLifeCycleEvent, Never>
    public private(set) var ad: OguryBannerAdView!
    public private(set) var adType: AdType
    internal var _adView: AdView?
    public var adView: AdView {
        guard let view = _adView else {
            var wself: (any AdManager)? = self
            _adView = AdsCardManager().card(for: &wself!)
            return _adView!
        }
        return view
    }
    public var adDelegate: AdLifeCycleDelegate? {
        set {
            proxyDelegate.adDelegate = newValue
        }
        
        get {
            proxyDelegate.adDelegate
        }
    }
    internal let proxyDelegate: BannerProxyDelegate!
    public var lifeCycleEvents: [AdLifeCycleEventHistory] = []
    public var bidder: HeaderBidable?
    public let id: UUID = UUID()
    public var actualSize: BannerSize? {
        get { size }
        set { size = newValue as! BannerAdManagerSize }
    }
    internal var size: BannerAdManagerSize!
    public func updateBannerSize(_ size: BannerSize) {
        if size != actualSize {
            actualSize = size
            ad = nil
        }
    }
    
    public convenience init(adType: AdType,
                            viewController: UIViewController?,
                            adDelegate: (any AdsCardLibrary.AdLifeCycleDelegate)?) {
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
        self.adFormat = adType.adFormat
        self.adConfiguration = adConfiguration
        self.cardConfiguration = cardConfiguration
        self.viewController = viewController
        
        proxyDelegate = BannerProxyDelegate(adDelegate: adDelegate)
        proxyDelegate.adManager = self
        switch adType {
            case .maxHeaderBidding: bidder = MaxBidder(configuration: OguryAdsCardAdapter.configuration)
            case .dtFairBidHeaderBidding: bidder = DTFairBidBidder(configuration: OguryAdsCardAdapter.configuration)
            case .unityLevelPlayHeaderBidding: bidder = UnityLevelPlayBidder(configuration: OguryAdsCardAdapter.configuration)
            default: ()
        }
        self.actualSize = self.bannerSizes?.first!
    }
    
    //MARK: Ad Management
    public func cardDidAppear() {
        if let ad, ad.isLoaded {
            append(.bannerReady(ad))
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
            let obj = ad as OguryBannerAdView
            let sel = NSSelectorFromString("loadWithCampaignId:creativeId:dspCreativeId:dspRegion:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String, String?, String, String) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId, creativeId, dspCreativeId, dspRegion)
        } else if let campaignId, !campaignId.isEmpty,
                  let creativeId, !creativeId.isEmpty {
            let obj = ad as OguryBannerAdView
            let sel = NSSelectorFromString("loadWithCampaignId:creativeId:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String, String) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId, creativeId)
        } else if let campaignId, !campaignId.isEmpty {
            let obj = ad as OguryBannerAdView
            let sel = NSSelectorFromString("loadWithCampaignId:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId)
        } else {
            self.ad.load()
        }
    }
    
    public func showAd() throws {
        if ad == nil {
            self.ad = OguryBannerAdView(adUnitId: adConfiguration.adUnitId, size: size.internalSize)
            ad.delegate = proxyDelegate
        }
        append(.bannerReady(ad))
    }
    
    internal func update(ad: OguryBannerAdView) {
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
                
            @unknown default: fatalError()
        }
    }
            
}

// We have to use a proxy object because otherwise, we would have to make InterstitialAdManager a final class that inherits from NSObject
// and for some reasons, that leads to unexpected compilation fail
// To overcome easily this, we use a proxy object
internal class BannerProxyDelegate: AdDelegateProxy<BannerAdManager>, OguryBannerAdViewDelegate {
    func bannerAdViewDidLoad(_ bannerAd: OguryBannerAdView) {
        guard let adManager else { return }
        adManager.append(.adLoaded(canShow:true))
    }
    
    func bannerAdViewDidClick(_ bannerAd: OguryBannerAdView) {
        guard let adManager else { return }
        adManager.append(.adClicked)
    }
    
    func bannerAdViewDidClose(_ bannerAd: OguryBannerAdView) {
        guard let adManager else { return }
        adManager.append(.adClosed)
    }
    
    func bannerAdView(_ bannerAd: OguryBannerAdView, didFailWithError error: OguryAdError) {
        handle(error)
    }
    
    func bannerAdViewDidTriggerImpression(_ bannerAd: OguryBannerAdView) {
        guard let adManager else { return }
        adManager.append(.adDidTriggerImpression)
    }
    
    func presentingViewController(forBannerAdView bannerAd: OguryBannerAdView) -> UIViewController? {
        guard let adManager else { return nil }
        return adDelegate?.viewController(for: adManager)
    }
}
