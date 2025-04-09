//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import OguryAds
import WebKit
import AdsCardLibrary

/// All objects that should have an ad manager basic bahavior should implement this protocol
public protocol OguryAdManager: AdManager {
    /// the type of ad to load
    var adType: AdType { get }
    var bidder: HeaderBidable? { get set }
    /// instanciate a new AdManager object with a given ad type
    init(adType: AdType,
         adConfiguration: AdConfiguration,
         cardConfiguration: CardConfiguration,
         viewController: UIViewController?,
         adDelegate: AdLifeCycleDelegate?)
    init(adType: AdType,
         viewController: UIViewController?,
         adDelegate: AdLifeCycleDelegate?)
}

//extension AdType {
//    struct OguryAdapterAdFormat: ACLAdapterFormat {
//        var adFormat: AdFormat
//        /// have to use this trick because `any [AdTag]` does not conform to Codable 😓
//        var tags: [any AdTag] {
//            get { ogyTags as [any AdTag] }
//            set { ogyTags = newValue as? [OguryAdTag] ?? [] }
//        }
//        var ogyTags: [OguryAdTag]
//        var displayName: String { adFormat.name }
//        var adType: Int
//        var options: ACLAdapterFormatOptions
//        var id: UUID { UUID(displayName.hashValue) }
//    }
//    var adFormat: any ACLAdapterFormat {
//        switch self {
//            case .interstitial:
//                return OguryAdapterAdFormat(adFormat: .interstitial,
//                                            ogyTags: [OguryAdTag.ogury, OguryAdTag.direct],
//                                            adType: 0,
//                                            options: ACLAdapterFormatOptions())
//                
//            case .rewarded:
//                return OguryAdapterAdFormat(adFormat: .rewardedVideo,
//                                            ogyTags: [OguryAdTag.ogury, OguryAdTag.direct],
//                                            adType: 0,
//                                            options: ACLAdapterFormatOptions())
//                
//            case .thumbnail:
//                return OguryAdapterAdFormat(adFormat: .thumbnail,
//                                            ogyTags: [OguryAdTag.ogury, OguryAdTag.direct],
//                                            adType: 0,
//                                            options: ACLAdapterFormatOptions())
//                
//            case .banner:
//                return OguryAdapterAdFormat(adFormat: .smallBanner,
//                                            ogyTags: [OguryAdTag.ogury, OguryAdTag.direct],
//                                            adType: 0,
//                                            options: ACLAdapterFormatOptions())
//                
//            case .mpu:
//                return OguryAdapterAdFormat(adFormat: .mrec,
//                                            ogyTags: [OguryAdTag.ogury, OguryAdTag.direct],
//                                            adType: 0,
//                                            options: ACLAdapterFormatOptions())
//                
//            case .maxHeaderBidding(let adType, _):
//                var innerType: OguryAdapterAdFormat = adType.adFormat as! OguryAdapterAdFormat
//                innerType.options.enableRtbTestMode = enableRtbTestMode
//                innerType.ogyTags = [OguryAdTag.max, OguryAdTag.headerBidding, OguryAdTag.bypass]
//                return innerType
//                
//            case .dtFairBidHeaderBidding(let adType, _):
//                var innerType: OguryAdapterAdFormat = adType.adFormat as! OguryAdapterAdFormat
//                innerType.options.enableRtbTestMode = enableRtbTestMode
//                innerType.ogyTags = [OguryAdTag.dtFairbid, OguryAdTag.headerBidding, OguryAdTag.bypass]
//                return innerType
//                
//            case .unityLevelPlayHeaderBidding(let adType, _):
//                var innerType: OguryAdapterAdFormat = adType.adFormat as! OguryAdapterAdFormat
//                innerType.options.enableRtbTestMode = enableRtbTestMode
//                innerType.ogyTags = [OguryAdTag.unityLevelPlay, OguryAdTag.headerBidding, OguryAdTag.bypass]
//                return innerType
//        }
//    }
//}

//MARK: - Ad Types
/// The ad format to load
/// Note that in order to use ``AdType/maxHeaderBidding(_:)``, you should also define the inner format
///
/// Example on how to use maxHeaderBidding
/// ```swift
/// let adType: AdType<InterstitialAdManager> = .maxHeaderBidding(.interstitial)
/// ```
public indirect enum AdType: RawValue {
    case interstitial
    case rewarded
    case thumbnail
    case banner
    case mpu
    case maxHeaderBidding(adType: AdType)
    case dtFairBidHeaderBidding(adType: AdType)
    case unityLevelPlayHeaderBidding(adType: AdType)
    
    typealias RawValue = Int
    public enum RawInnerAdType: Int {
        case interstitial = 0
        case rewarded = 1
        case banner = 2
        case mpu = 3
        case thumbnail = 4
        case maxSuffix = 10
        case dtFairBidSuffix = 20
        case unityLevelPlaySuffix = 30
    }
    public var rawValue: Int {
        switch self {
            case .interstitial: return RawInnerAdType.interstitial.rawValue
            case .rewarded: return RawInnerAdType.rewarded.rawValue
            case .thumbnail: return RawInnerAdType.thumbnail.rawValue
            case .banner: return RawInnerAdType.banner.rawValue
            case .mpu: return RawInnerAdType.mpu.rawValue
            case .maxHeaderBidding(let adType): return adType.rawValue + RawInnerAdType.maxSuffix.rawValue
            case .dtFairBidHeaderBidding(let adType): return adType.rawValue + RawInnerAdType.dtFairBidSuffix.rawValue
            case .unityLevelPlayHeaderBidding(let adType): return adType.rawValue + RawInnerAdType.unityLevelPlaySuffix.rawValue
        }
    }
    init(rawValue: Int) -> Self? {
        switch rawValue {
            case RawInnerAdType.interstitial: return .interstitial
            case RawInnerAdType.rewarded: return .rewarded
            case RawInnerAdType.banner: return .smallBanner
            case RawInnerAdType.mpu: return .mrec
            case RawInnerAdType.thumbnail: return .thumbnail
            case RawInnerAdType.maxSuffix..<RawInnerAdType.dtFairBidSuffix:
                guard let innerRawType = AdType(rawValue - RawInnerAdType.maxSuffix) else { return nil }
                return .maxHeaderBidding(innerRawType)
            case RawInnerAdType.dtFairBidSuffix..<RawInnerAdType.unityLevelPlaySuffix:
                guard let innerRawType = AdType(rawValue - RawInnerAdType.dtFairBidSuffix) else { return nil }
                return .dtFairBidHeaderBidding(innerRawType)
            case RawInnerAdType.unityLevelPlaySuffix...RawInnerAdType.unityLevelPlaySuffix + RawInnerAdType.thumbnail:
                guard let innerRawType = AdType(rawValue - RawInnerAdType.unityLevelPlaySuffix) else { return nil }
                return .unityLevelPlayHeaderBidding(innerRawType)
            default: return nil
        }
    }
    
    /// returns the proper adManager handled by the AdType
    /// if no suitable adManager is found ``AdManagerError/adManagerMismatch`` is thrown
    internal func adManager(bidder: HeaderBidable?,
                            viewController: UIViewController?,
                            adDelegate: AdLifeCycleDelegate?) throws -> OguryAdManager  {
        switch self {
            case .rewarded:
                return RewardedAdManager(adType: .rewarded, viewController: viewController, adDelegate: adDelegate)
                
            case .interstitial:
                return InterstitialAdManager(adType: .interstitial, viewController: viewController, adDelegate: adDelegate)
                
            case .thumbnail:
                return ThumbnailAdManager(adType: .thumbnail, viewController: viewController, adDelegate: adDelegate)
                
            case .banner:
                return BannerAdManager(adType: .banner, viewController: viewController, adDelegate: adDelegate)
                
            case .mpu:
                return BannerAdManager(adType: .mpu, viewController: viewController, adDelegate: adDelegate)
                
            case .maxHeaderBidding(.thumbnail):
                fatalError("Thumbnail is not supported on HB")
                
            case let .maxHeaderBidding(adType):
                var adManager = adType.adManager(bidder: bidder, viewController: viewController, adDelegate: adDelegate)
                adManager.bidder = bidder
                return adManager
                
            case .unityLevelPlayHeaderBidding(.thumbnail):
                fatalError("Thumbnail is not supported on HB")
                
            case let .unityLevelPlayHeaderBidding(adType):
                var adManager = adType.adManager(bidder: bidder, viewController: viewController, adDelegate: adDelegate)
                adManager.bidder = bidder
                return adManager
                
            case .dtFairBidHeaderBidding(.thumbnail):
                fatalError("Thumbnail is not supported on HB")
                
            case let .dtFairBidHeaderBidding(adType):
                var adManager = adType.adManager(bidder: bidder, viewController: viewController, adDelegate: adDelegate)
                adManager.bidder = bidder
                return adManager
        }
    }
    
    public var displayTitle: String {
        switch self {
            case .interstitial: return AdTypeTitle.interstitial.display
            case .rewarded: return AdTypeTitle.rewarded.display
            case .thumbnail: return AdTypeTitle.thumbnail.display
            case .mpu: return AdTypeTitle.mpu.display
            case .banner: return AdTypeTitle.banner.display
            case let .maxHeaderBidding(innerType): return innerType.displayTitle
            case let .dtFairBidHeaderBidding(innerType): return innerType.displayTitle
            case let .unityLevelPlayHeaderBidding(innerType): return innerType.displayTitle
        }
    }
    
    public var headerTitle: String {
        switch self {
            case .interstitial: return AdTypeTitle.interstitial.display
            case .rewarded: return AdTypeTitle.rewarded.display
            case .thumbnail: return AdTypeTitle.thumbnail.display
            case .mpu: return AdTypeTitle.mpu.display
            case .banner: return AdTypeTitle.banner.display
            case let .maxHeaderBidding(innerType): return innerType.displayTitle
            case let .dtFairBidHeaderBidding(innerType): return innerType.displayTitle
            case let .unityLevelPlayHeaderBidding(innerType): return innerType.displayTitle
        }
    }
    
    public var uuid: Int {
        switch self {
            case .interstitial: return displayTitle.hashValue
            case .rewarded: return displayTitle.hashValue
            case .thumbnail: return displayTitle.hashValue
            case .mpu: return displayTitle.hashValue
            case .banner: return displayTitle.hashValue
            case let .maxHeaderBidding(inner): return ("maxHeaderBidding" + inner.displayTitle).hashValue
            case let .dtFairBidHeaderBidding(inner): return ("dtFairBidHeaderBidding" + inner.displayTitle).hashValue
            case let .unityLevelPlayHeaderBidding(inner): return ("unityLevelPlayHeaderBidding" + inner.displayTitle).hashValue
        }
    }
    
    public var tags: [OguryAdTag] {
        switch self {
            case .interstitial, .rewarded, .thumbnail, .banner, .mpu: return [.ogury, .direct]
            case .maxHeaderBidding: return [.max, .headerBidding, .bypass]
            case .dtFairBidHeaderBidding: return [.dtFairbid, .headerBidding, .bypass]
            case .unityLevelPlayHeaderBidding: return [.unityLevelPlay, .headerBidding, .bypass]
        }
    }
    
    public var enableRtbTestMode: Bool {
        switch self {
            case .unityLevelPlayHeaderBidding: return true
            default: return false
        }
    }
}

extension AdType: Equatable {
    public static func ==(lhs: AdType<T>, rhs:AdType<T>) -> Bool {
        switch (lhs, rhs) {
            case (.interstitial, .interstitial): return true
            case (.rewarded, .rewarded): return true
            case (.thumbnail, .thumbnail): return true
            case (.banner, .banner): return true
            case (.mpu, .mpu): return true
            default: return false
        }
    }
}
