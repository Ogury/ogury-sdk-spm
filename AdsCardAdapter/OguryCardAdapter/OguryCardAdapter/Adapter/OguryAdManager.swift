//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import OguryAds
import WebKit
import AdsCardLibrary
import AdsCardAdapter

/// All objects that should have an ad manager basic bahavior should implement this protocol
public protocol OguryAdManager: AdManager {
    /// the type of ad to load
    var adType: AdType { get }
    var bidder: HeaderBidable? { get set }
    init(adType: AdType,
         viewController: UIViewController?,
         adDelegate: AdLifeCycleDelegate?)
    
    init(adType: AdType,
         adConfiguration: AdConfiguration,
         cardConfiguration: CardConfiguration,
         viewController: UIViewController?,
         adDelegate: AdLifeCycleDelegate?)
}

extension OguryAdManager {    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(adFormat)
        hasher.combine(adConfiguration)
        hasher.combine(cardConfiguration)
    }
}

public indirect enum AdType: AdAdapterFormat, RawRepresentable, Equatable {
    case interstitial
    case rewarded
    case thumbnail
    case standardBanner
    case maxHeaderBidding(_: AdType)
    case dtFairBidHeaderBidding(_: AdType)
    case unityLevelPlayHeaderBidding(_: AdType)
    
    public typealias RawValue = Int
    public enum RawInnerAdType: Int {
        case interstitial = 0
        case rewarded = 1
        case standardBanner = 2
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
            case .standardBanner: return RawInnerAdType.standardBanner.rawValue
            case .maxHeaderBidding(let adType): return adType.rawValue + RawInnerAdType.maxSuffix.rawValue
            case .dtFairBidHeaderBidding(let adType): return adType.rawValue + RawInnerAdType.dtFairBidSuffix.rawValue
            case .unityLevelPlayHeaderBidding(let adType): return adType.rawValue + RawInnerAdType.unityLevelPlaySuffix.rawValue
        }
    }
    public init?(rawValue: Int) {
        switch rawValue {
            case RawInnerAdType.interstitial.rawValue: self = .interstitial
            case RawInnerAdType.rewarded.rawValue: self = .rewarded
            case RawInnerAdType.standardBanner.rawValue: self = .standardBanner
            case RawInnerAdType.thumbnail.rawValue: self = .thumbnail
            case RawInnerAdType.maxSuffix.rawValue..<RawInnerAdType.dtFairBidSuffix.rawValue:
                guard let innerRawType = AdType(rawValue: rawValue - RawInnerAdType.maxSuffix.rawValue) else { return nil }
                self = .maxHeaderBidding(innerRawType)
            case RawInnerAdType.dtFairBidSuffix.rawValue..<RawInnerAdType.unityLevelPlaySuffix.rawValue:
                guard let innerRawType = AdType(rawValue: rawValue - RawInnerAdType.dtFairBidSuffix.rawValue) else { return nil }
                self = .dtFairBidHeaderBidding(innerRawType)
            case RawInnerAdType.unityLevelPlaySuffix.rawValue...RawInnerAdType.unityLevelPlaySuffix.rawValue + RawInnerAdType.thumbnail.rawValue:
                guard let innerRawType = AdType(rawValue: rawValue - RawInnerAdType.unityLevelPlaySuffix.rawValue) else { return nil }
                self = .unityLevelPlayHeaderBidding(innerRawType)
            default: return nil
        }
    }
    
    public var sortOrder: Int { rawValue }
    
    /// returns the proper adManager handled by the AdType
    /// if no suitable adManager is found ``AdManagerError/adManagerMismatch`` is thrown
    internal func adManager(viewController: UIViewController?,
                            adDelegate: AdLifeCycleDelegate?,
                            overridenAdType: AdType? = nil) -> any OguryAdManager  {
        switch self {
            case .rewarded:
                return RewardedAdManager(adType: overridenAdType ?? .rewarded, viewController: viewController, adDelegate: adDelegate)
                
            case .interstitial:
                return InterstitialAdManager(adType: overridenAdType ?? .interstitial, viewController: viewController, adDelegate: adDelegate)
                
            case .thumbnail:
                return ThumbnailAdManager(adType: .thumbnail, viewController: viewController, adDelegate: adDelegate)
                
            case .standardBanner:
                return BannerAdManager(adType: overridenAdType ?? .standardBanner, viewController: viewController, adDelegate: adDelegate)
                
            case .maxHeaderBidding(.thumbnail):
                fatalError("Thumbnail is not supported on HB")
                
            case let .maxHeaderBidding(adType):
                return adType.adManager(viewController: viewController, adDelegate: adDelegate, overridenAdType: .maxHeaderBidding(adType))
                
            case .unityLevelPlayHeaderBidding(.thumbnail):
                fatalError("Thumbnail is not supported on HB")
                
            case let .unityLevelPlayHeaderBidding(adType):
                return adType.adManager(viewController: viewController, adDelegate: adDelegate, overridenAdType: .unityLevelPlayHeaderBidding(adType))
                
            case .dtFairBidHeaderBidding(.thumbnail):
                fatalError("Thumbnail is not supported on HB")
                
            case let .dtFairBidHeaderBidding(adType):
                return adType.adManager(viewController: viewController, adDelegate: adDelegate, overridenAdType: .dtFairBidHeaderBidding(adType))
        }
    }
    
    public var adFormat: AdFormat {
        switch self {
            case .interstitial: return .interstitial
            case .rewarded: return .rewardedVideo
            case .thumbnail: return .thumbnail
            case .standardBanner: return .standardBanner
            case let .maxHeaderBidding(adType): return adType.adFormat
            case let .dtFairBidHeaderBidding(adType): return adType.adFormat
            case let .unityLevelPlayHeaderBidding(adType): return adType.adFormat
        }
    }
    
    public var displayName: String {
        switch self {
            case .interstitial: return "Interstitial"
            case .rewarded: return "Rewarded"
            case .thumbnail: return "Thumbnail"
            case .standardBanner: return "Std banners"
            case let .maxHeaderBidding(adType): return adType.displayName
            case let .dtFairBidHeaderBidding(adType): return adType.displayName
            case let .unityLevelPlayHeaderBidding(adType): return adType.displayName
        }
    }
    
    public var id: UUID {
        switch self {
            case .interstitial, .rewarded, .standardBanner, .thumbnail: return self.displayName.uuid
            case let .maxHeaderBidding(inner): return ("maxHeaderBidding" + inner.displayName).uuid
            case let .dtFairBidHeaderBidding(inner): return ("dtFairBidHeaderBidding" + inner.displayName).uuid
            case let .unityLevelPlayHeaderBidding(inner): return ("unityLevelPlayHeaderBidding" + inner.displayName).uuid
        }
    }
    
    // use get/set because protocol is definied that way
    public var tags: [any AdTag] {
        switch self {
            case .interstitial, .rewarded, .thumbnail, .standardBanner: return [OguryAdTag.ogury, OguryAdTag.direct]
            case .maxHeaderBidding: return [OguryAdTag.max, OguryAdTag.headerBidding, OguryAdTag.bypass]
            case .dtFairBidHeaderBidding: return [OguryAdTag.dtFairbid, OguryAdTag.headerBidding, OguryAdTag.bypass]
            case .unityLevelPlayHeaderBidding: return [OguryAdTag.unityLevelPlay, OguryAdTag.headerBidding, OguryAdTag.bypass]
        }
    }
    
    public var enableRtbTestMode: Bool {
        switch self {
            case .unityLevelPlayHeaderBidding: return true
            default: return false
        }
    }
    
    /// associated icon
    public var displayIcon: Image {
        switch self {
            case .interstitial: return Image(systemName: "iphone").symbolRenderingMode(.monochrome)
            case .rewarded: return Image(systemName: "iphone.gen3.badge.play")
            case .standardBanner: return Image(systemName: "platter.filled.bottom.iphone")
            case .thumbnail: return Image(systemName: "rectangle.portrait.bottomright.inset.filled")
            case let .maxHeaderBidding(adType): return adType.displayIcon
            case let .dtFairBidHeaderBidding(adType): return adType.displayIcon
            case let .unityLevelPlayHeaderBidding(adType): return adType.displayIcon
        }
    }
}
