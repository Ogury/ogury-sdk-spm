//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import OguryAds
import OguryAds.Private
import ComposableArchitecture
import Combine

public final class ThumbnailAdManager: AdManager {
    public static func == (lhs: ThumbnailAdManager, rhs: ThumbnailAdManager) -> Bool {
        return lhs.adType == rhs.adType && lhs.ad == rhs.ad
    }
    
    public var events: PassthroughSubject<AdLifeCycleEvent, Never>
   lazy var store = Store(initialState: AdViewFeature.State(from: self.options, adType: AnyAdType(self.adType)), reducer: {
        AdViewFeature(adManager: self)
    })
    public typealias Ad = OguryThumbnailAd
    public typealias Options = ThumbnailAdManagerOptions
    public var adOptionView: (any View)? { nil }
    //MARK: Variables
    public var options: ThumbnailAdManagerOptions!
    public private(set) var ad: OguryThumbnailAd!
    public private(set) var adType: AdType<ThumbnailAdManager>
    public var adView: AdView { AdView(store: self.store) }
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
    public init(adType: AdType<ThumbnailAdManager>, adDelegate: AdLifeCycleDelegate? = nil) {
        events = PassthroughSubject<AdLifeCycleEvent, Never>()
        self.adType = adType
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
                self.ad = OguryThumbnailAd(adUnitId: options.adUnitId, mediation: OguryMediation(name: "AdsTestApp", version: .sdkVersion))
            }
            self.ad.delegate = self.proxyDelegate
            self.ad.setLogOrigin(options.qaLabel)
            self.load()
        }
        append(.adLoading)
    }
    
    private func load() {
        if let dspCreativeId = options.baseOptions.dspCreativeId, !dspCreativeId.isEmpty,
           let campaignId = options.baseOptions.campaignId, !campaignId.isEmpty,
           let creativeId = options.baseOptions.creativeId,
           let dspRegion = options.baseOptions.dspRegion?.displayName, !dspRegion.isEmpty {
            if let size = options.thumbnailOptions.size {
                let obj = ad as OguryThumbnailAd
                let sel = NSSelectorFromString("loadWithCampaignId:creativeId:dspCreativeId:dspRegion:thumbnailSize:")
                let meth = class_getInstanceMethod(object_getClass(obj), sel)
                let imp = method_getImplementation(meth!)
                typealias ClosureType = @convention(c) (AnyObject, Selector, String, String?, String, String, CGSize) -> Void
                let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
                sayHiTo(obj, sel, campaignId, creativeId, dspCreativeId, dspRegion, size)
            } else {
                let obj = ad as OguryThumbnailAd
                let sel = NSSelectorFromString("loadWithCampaignId:creativeId:dspCreativeId:dspRegion:")
                let meth = class_getInstanceMethod(object_getClass(obj), sel)
                let imp = method_getImplementation(meth!)
                typealias ClosureType = @convention(c) (AnyObject, Selector, String, String?, String, String) -> Void
                let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
                sayHiTo(obj, sel, campaignId, creativeId, dspCreativeId, dspRegion)
            }
        } else if let campaignId = options.baseOptions.campaignId,
                  !campaignId.isEmpty,
                  let creativeId = options.baseOptions.creativeId,
                  !creativeId.isEmpty {
            if let size = options.thumbnailOptions.size {
                let obj = ad as OguryThumbnailAd
                let sel = NSSelectorFromString("loadWithCampaignId:creativeId:thumbnailSize:")
                let meth = class_getInstanceMethod(object_getClass(obj), sel)
                let imp = method_getImplementation(meth!)
                typealias ClosureType = @convention(c) (AnyObject, Selector, String, String, CGSize) -> Void
                let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
                sayHiTo(obj, sel, campaignId,creativeId, size)
            } else {
                let obj = ad as OguryThumbnailAd
                let sel = NSSelectorFromString("loadWithCampaignId:creativeId:")
                let meth = class_getInstanceMethod(object_getClass(obj), sel)
                let imp = method_getImplementation(meth!)
                typealias ClosureType = @convention(c) (AnyObject, Selector, String, String) -> Void
                let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
                sayHiTo(obj, sel, campaignId, creativeId)
            }
        } else if let campaignId = options.baseOptions.campaignId,
                  !campaignId.isEmpty {
            if let size = options.thumbnailOptions.size {
                let obj = ad as OguryThumbnailAd
                let sel = NSSelectorFromString("loadWithCampaignId:thumbnailSize:")
                let meth = class_getInstanceMethod(object_getClass(obj), sel)
                let imp = method_getImplementation(meth!)
                typealias ClosureType = @convention(c) (AnyObject, Selector, String, CGSize) -> Void
                let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
                sayHiTo(obj, sel, campaignId, size)
            } else {
                let obj = ad as OguryThumbnailAd
                let sel = NSSelectorFromString("loadWithCampaignId:")
                let meth = class_getInstanceMethod(object_getClass(obj), sel)
                let imp = method_getImplementation(meth!)
                typealias ClosureType = @convention(c) (AnyObject, Selector, String) -> Void
                let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
                sayHiTo(obj, sel, campaignId)
            }
        } else {
            ad.load()
        }
    }
    
    internal func updateOptions(from options: ThumbnailDisplayOptions) {
        var size = self.options.thumbnailOptions.size ?? .zero
        if let width = Float(options.width) {
            size.width = CGFloat(width)
        }
        if let height = Float(options.height) {
            size.height = CGFloat(height)
        }
        self.options.thumbnailOptions.size = size
        switch options.thumbnailPosition {
            case .topleft, .topright, .bottomleft, .bottomright:
                self.options.thumbnailOptions.corner = options.thumbnailPosition.corner
                self.options.thumbnailOptions.offset = .init(x: CGFloat(Float(options.xOffset) ?? 0),
                                                             y: CGFloat(Float(options.yOffset) ?? 0))
            case .position:
                var position = self.options.thumbnailOptions.position ?? .zero
                if let xOffset = Float(options.xOffset) {
                    position.x = CGFloat(xOffset)
                }
                if let yOffset = Float(options.yOffset) {
                    position.y = CGFloat(yOffset)
                }
                self.options.thumbnailOptions.position = position
                
            default: ()
        }
    }
    
    public func showAd() throws {
        guard let options else { throw AdManagerError.noOptions }
        //      guard let ad else { throw AdManagerError.loadNotCalledBeforeShow }
        if ad == nil {
            ad = OguryThumbnailAd(adUnitId: options.baseOptions.adUnitId)
            ad.delegate = proxyDelegate
        }
        let thumbOptions = options.thumbnailOptions
        DispatchQueue.main.async {
            switch (thumbOptions?.scene, thumbOptions?.corner, thumbOptions?.offset, thumbOptions?.position) {
                case (let scene, let corner, let offset, _) where scene != nil && corner != nil && offset != nil:
                    self.ad.scene = scene!
                    self.ad?.show(with: corner!, offset: offset!)
                    
                case (let scene, _, _, let position) where scene != nil && position != nil:
                    self.ad.scene = scene!
                    self.ad?.show(at: position!)
                    
                case (let scene, _, _, _) where scene != nil:
                    self.ad.scene = scene!
                    self.ad?.show()
                    
                case (_, let corner, let offset, _) where corner != nil && offset != nil:
                    self.ad?.show(with: corner!, offset: offset!)
                    
                case (_, _, _, let position) where position != nil:
                    self.ad?.show(at: position!)
                    
                default: self.ad?.show()
            }
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
    
    public func updateCard(events: [AdOptionsEvent]) {
        adView.updateCard(events: events)
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
    
    public func encode() -> StorableAdManager {
        StorableAdManager(rawAdType: adType.innerType,
                          options: options,
                          thumbnailOptions: options.thumbnailOptions)
    }
}
