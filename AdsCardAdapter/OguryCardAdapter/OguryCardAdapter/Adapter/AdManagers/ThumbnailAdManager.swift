//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import OguryAds
import OguryAds.Private
internal import ComposableArchitecture
import Combine
import AdsCardLibrary

public final class ThumbnailAdManager: OguryAdManager, AdManager {
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
        //TODO: implement
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
    public typealias Ad = OguryThumbnailAd
    public typealias Options = AdManagerOptions
    public var adOptionView: (any View)? { nil }
    //MARK: Variables
    public var options: AdManagerOptions!  {
        didSet {
            adConfiguration = .init(adUnitId: options.baseOptions.adUnitId, campaignId: options.baseOptions.campaignId)
            cardConfiguration = .init()
        }
    }
    public private(set) var ad: OguryThumbnailAd!
    public private(set) var adType: AdType<ThumbnailAdManager>
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
    
    //MARK: Initializer
    public init(adType: AdType<ThumbnailAdManager>,
                adConfiguration: AdConfiguration,
                cardConfiguration: CardConfiguration,
                viewController: UIViewController?,
                adDelegate: AdLifeCycleDelegate? = nil) {
        events = PassthroughSubject<AdLifeCycleEvent, Never>()
        self.adType = adType
        self.adFormat = .thumbnail
        self.adConfiguration = adConfiguration
        self.cardConfiguration = cardConfiguration
        self.viewController = viewController
        proxyDelegate = ThumbnailProxyDelegate(adDelegate: adDelegate)
        proxyDelegate.adManager = self
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
        DispatchQueue.main.async {
            if (self.ad == nil) {
                self.ad = OguryThumbnailAd(adUnitId: options.adUnitId)
            }
            self.ad.delegate = self.proxyDelegate
            self.ad.setLogOrigin(options.qaLabel)
            self.load()
        }
        append(.adLoading)
    }
    
    private func privateLoad() {
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
        guard let options else { throw AdManagerError.noOptions }
        //      guard let ad else { throw AdManagerError.loadNotCalledBeforeShow }
        if ad == nil {
            ad = OguryThumbnailAd(adUnitId: options.baseOptions.adUnitId)
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
        handle(error, for: thumbnailAd)
    }
    
    func thumbnailAdDidTriggerImpression(_ thumbnailAd: OguryThumbnailAd) {
        guard let adManager else { return }
        adManager.append(.adDidTriggerImpression)
    }
}

extension ThumbnailAdManager: Storable {
    public convenience init(from data: StorableAdManager) {
        fatalError()
    }
    
    public func encode() -> StorableAdManager { StorableAdManager(rawAdType: adType.innerType, options: options) }
}
