//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import OguryAds
import ComposableArchitecture
import Combine

public final class BannerAdManager: AdManager {
   public static func == (lhs: BannerAdManager, rhs: BannerAdManager) -> Bool {
      return lhs.adType == rhs.adType && lhs.ad == rhs.ad
   }
   
   public var events: PassthroughSubject<AdLifeCycleEvent, Never>
   lazy var store = Store(
      initialState: AdViewFeature.State(from: self.options, 
                                        bannerContainer: BannerContainer(bannerType: adType)),
      reducer: {
         AdViewFeature(adManager: self)
      })
   
   public typealias Ad = OguryBannerAdView
   public typealias Options = BannerAdManagerOptions
   public var adOptionView: (any View)? { nil }
   //MARK: Variables
   public var options: BannerAdManagerOptions!
   public private(set) var ad: OguryBannerAdView!
   public private(set) var adType: AdType<BannerAdManager>
   public var adView: AdView { AdView(store: self.store) }
   public var adDelegate: AdLifeCycleDelegate? {
      set {
         proxyDelegate.adDelegate = newValue
      }
      
      get {
         proxyDelegate.adDelegate
      }
   }
   internal let proxyDelegate: MrecProxyDelegate!
   public var lifeCycleEvents: [AdLifeCycleEventHistory] = []
   internal var bidder: HeaderBidable?
   public let id: UUID = UUID()
   
   //MARK: Initializer
   public init(adType: AdType<BannerAdManager>, adDelegate: AdLifeCycleDelegate? = nil) {
      events = PassthroughSubject<AdLifeCycleEvent, Never>()
      self.adType = adType
      proxyDelegate = MrecProxyDelegate(adDelegate: adDelegate)
      proxyDelegate.adManager = self
      if case let .maxHeaderBidding(_, adMarkUpRetriever) = adType {
         bidder = adMarkUpRetriever
      }
      else if case let .dtFairBidHeaderBidding(_, adMarkUpRetriever) = adType {
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
      DispatchQueue.main.async {
         if (self.ad == nil) {
             self.ad = OguryBannerAdView(adUnitId: options.adUnitId,
                                     size: self.adType == .banner ? .small_banner_320x50() : .mrec_300x250(),
                                     mediation: OguryMediation(name: "AdsTestApp", version: .sdkVersion))
         } else {
            self.ad?.destroy()
         }
         self.ad.delegate = self.proxyDelegate
         self.append(.adLoading)
         guard let bidder = self.bidder else {
            self.load()
            return
         }
         Task {
            do {
               let adMakUp = try await bidder.adMarkUp(adUnitId: options.adUnitId,
                                                     campaignId: options.campaignId,
                                                     creativeId: options.creativeId,
                                                    dspCreative: options.dspCreativeId,
                                                      dspRegion: options.dspRegion)
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
   
   private var isMpu: Bool {
      switch adType {
         case .mpu, .maxHeaderBidding(.mpu, _): return true
         default: return false
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
         let obj = ad as OguryBannerAdView
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
         let obj = ad as OguryBannerAdView
         let sel = NSSelectorFromString("loadWithCampaignId:creativeId:")
         let meth = class_getInstanceMethod(object_getClass(obj), sel)
         let imp = method_getImplementation(meth!)
         typealias ClosureType = @convention(c) (AnyObject, Selector, String, String) -> Void
         let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
         sayHiTo(obj, sel, campaignId, creativeId)
      } else if let campaignId = options.baseOptions.campaignId,
                !campaignId.isEmpty {
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
   
   public func loadAdFromAdMarkUp(from options: BaseAdOptions) throws {
      self.options.baseOptions = options
      guard let adMarkUp = options.adMarkUp else { throw AdManagerError.noOptions }
      DispatchQueue.main.async {
          self.ad = OguryBannerAdView(adUnitId: options.adUnitId,
                                  size: self.adType == .banner ? .small_banner_320x50() : .mrec_300x250(),
                                  mediation: OguryMediation(name: "AdsTestApp", version: .sdkVersion))
         self.ad.delegate = self.proxyDelegate
          self.ad.load(withAdMarkup: adMarkUp)
         self.append(.adLoading)
      }
   }
   
   public func showAd() throws {
       guard let options else { throw AdManagerError.noOptions }
       if ad == nil {
           self.ad = OguryBannerAdView(adUnitId: options.baseOptions.adUnitId,
                                   size: self.adType == .banner ? .small_banner_320x50() : .mrec_300x250(),
                                   mediation: OguryMediation(name: "AdsTestApp", version: .sdkVersion))
           ad.delegate = proxyDelegate
       }
      append(.bannerReady(ad))
   }
   
   internal func closeAd() {
      ad?.destroy()
   }
   
   internal func update(ad: OguryBannerAdView) {
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
internal class MrecProxyDelegate: AdDelegateProxy<BannerAdManager>, OguryBannerAdDelegate {
   func didLoad(_ ad: OguryBannerAdView) {
      guard let adManager else { return }
      adManager.append(.adLoaded(canShow:true))
   }
   
   func didClick(_ ad: OguryBannerAdView) {
      guard let adManager else { return }
      adManager.append(.adClicked)
   }
   
   func didClose(_ ad: OguryBannerAdView) {
      guard let adManager else { return }
      adManager.append(.adClosed)
   }
    
    func didFail(_ banner: OguryBannerAdView, error: OguryAdError) {
        handle(error, for: banner)
    }
   
   func didTriggerImpressionOguryBannerAdView(_ banner: OguryBannerAdView) {
      guard let adManager else { return }
      adManager.append(.adDidTriggerImpression)
   }
   
    func presentingViewController(forOguryAdsBannerAdView banner: OguryBannerAdView) -> UIViewController? {
      guard let adManager else { return nil }
      return adDelegate?.viewController(forBanner: banner, adManager: adManager)
    }
}

extension BannerAdManager: Storable {
   public convenience init(from data: StorableAdManager) {
      fatalError()
   }
   
   public func encode() -> StorableAdManager {
      StorableAdManager(rawAdType: adType.innerType,
                        options: options,
                        thumbnailOptions: nil)
   }
}
