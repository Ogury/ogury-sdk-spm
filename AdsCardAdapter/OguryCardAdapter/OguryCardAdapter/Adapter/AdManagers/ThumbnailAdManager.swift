//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import OguryAds
import OguryAds.Private
import Combine
import AdsCardLibrary

public final class ThumbnailAdManager: OguryAdManager {
    public static func decode(from container: AdCardContainer) throws(AdCardContainerError) -> any AdManager {
        guard let adType = AdType(rawValue: container.adType) else { throw .invalidAdType }
        return ThumbnailAdManager(adType: adType,
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
    public var bidder: (any HeaderBidable)?
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
    
    public func load() {
        DispatchQueue.main.async {
            if (self.ad == nil) {
                self.ad = OguryThumbnailAd(adUnitId: self.adUnitId)
            }
            self.ad.delegate = self.proxyDelegate
            self.ad.setLogOrigin(self.cardConfiguration.qaLabel)
            self.loadAd()
        }
        append(.adLoading)
    }
    
    public func show() {
        //TODO: implement
    }
    
    public func close() {
        //n/a
    }
    
    public static func == (lhs: ThumbnailAdManager, rhs: ThumbnailAdManager) -> Bool {
        return lhs.adType == rhs.adType && lhs.ad == rhs.ad
    }
    
    public var events: PassthroughSubject<AdLifeCycleEvent, Never>
    public private(set) var ad: OguryThumbnailAd!
    public private(set) var adType: AdType
    public var adView: AdView {
        var wself: (any AdManager)? = self
        return AdsCardManager().card(for: &wself!)
    }
    public var adDelegate: AdLifeCycleDelegate? {
        set {
            proxyDelegate.adDelegate = newValue
        }
        
        get {
            proxyDelegate.adDelegate
        }
    }
    internal let proxyDelegate: ThumbnailProxyDelegate!
    public var lifeCycleEvents: [AdLifeCycleEventHistory] = []
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
        bidder = nil
        adFormat = .thumbnail
        self.adConfiguration = adConfiguration
        self.cardConfiguration = cardConfiguration
        self.viewController = viewController
        proxyDelegate = ThumbnailProxyDelegate(adDelegate: adDelegate)
        proxyDelegate.adManager = self
    }
    
    //MARK: Ad Management
    private func loadAd() {
        // if test mode is enabled, then we don't send any other information
        guard !adUnitId.isTestModeOn else {
            ad.load()
            return
        }
        
        if let dspCreativeId, !dspCreativeId.isEmpty,
           let campaignId, !campaignId.isEmpty,
           let creativeId, !creativeId.isEmpty,
           let dspRegion = dspRegion?.displayName, !dspRegion.isEmpty {
            let obj = ad as OguryThumbnailAd
            let sel = NSSelectorFromString("loadWithCampaignId:creativeId:dspCreativeId:dspRegion:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String, String?, String, String) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId, creativeId, dspCreativeId, dspRegion)
        } else if let campaignId, !campaignId.isEmpty,
                  let creativeId, !creativeId.isEmpty {
            let obj = ad as OguryThumbnailAd
            let sel = NSSelectorFromString("loadWithCampaignId:creativeId:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String, String) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId, creativeId)
        } else if let campaignId, !campaignId.isEmpty {
            let obj = ad as OguryThumbnailAd
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
        //      guard let ad else { throw AdManagerError.loadNotCalledBeforeShow }
        if ad == nil {
            ad = OguryThumbnailAd(adUnitId: adUnitId)
            ad.delegate = proxyDelegate
        }
        DispatchQueue.main.async {
            self.ad?.show()
        }
        append(.adDisplaying)
    }
    
    internal func update(ad: OguryThumbnailAd) {
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
internal class ThumbnailProxyDelegate: AdDelegateProxy<ThumbnailAdManager>, OguryThumbnailAdDelegate {
    func thumbnailAdDidLoad(_ thumbnailAd: OguryThumbnailAd) {
        guard let adManager else { return }
        adManager.append(.adLoaded(canShow: true))
    }
    
    func thumbnailAdDidClick(_ thumbnailAd: OguryThumbnailAd) {
        guard let adManager else { return }
        adManager.append(.adClicked)
    }
    
    func thumbnailAdDidClose(_ thumbnailAd: OguryThumbnailAd) {
        guard let adManager else { return }
        adManager.append(.adClosed)
    }
    
    func thumbnailAd(_ thumbnailAd: OguryThumbnailAd, didFailWithError error: OguryAdError) {
        handle(error)
    }
    
    func thumbnailAdDidTriggerImpression(_ thumbnailAd: OguryThumbnailAd) {
        guard let adManager else { return }
        adManager.append(.adDidTriggerImpression)
    }
}
