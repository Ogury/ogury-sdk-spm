//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation

public protocol Storable {
    init(from data: StorableAdManager)
    func encode() -> StorableAdManager
}

public struct StorableAdManager: Codable {
    public let rawAdType: Int
    public let options: BaseAdManagerOptions
    public let thumbnailOptions: ThumbnailOptions?
}

//MARK: AdType Codable
public enum RawInnerAdType: Int {
    case interstitial = 0
    case rewarded = 1
    case banner = 2
    case mpu = 3
    case thumbnail = 4
    case maxSuffix = 10
    case dtFairBidSuffix = 20
}

extension AdType: Codable {
    
    public var innerType: Int {
        switch self {
            case .interstitial: return RawInnerAdType.interstitial.rawValue
            case .rewarded: return RawInnerAdType.rewarded.rawValue
            case .thumbnail: return RawInnerAdType.thumbnail.rawValue
            case .mpu: return RawInnerAdType.mpu.rawValue
            case .banner: return RawInnerAdType.banner.rawValue
            case let .maxHeaderBidding(adType, _): return RawInnerAdType.maxSuffix.rawValue + adType.innerType
            case let .dtFairBidHeaderBidding(adType, _): return RawInnerAdType.dtFairBidSuffix.rawValue + adType.innerType
        }
    }
    
   public static func adType(from innerType: Int, adMarkUpRetriever: HeaderBidable?) throws -> AdType? {
        switch innerType {
            case RawInnerAdType.interstitial.rawValue:
                let adType: AdType<InterstitialAdManager> = .interstitial
                return adType as? AdType<T>
                
            case RawInnerAdType.rewarded.rawValue:
                let adType: AdType<RewardedAdManager> = .rewarded
                return adType as? AdType<T>
                
            case RawInnerAdType.banner.rawValue:
                let adType: AdType<BannerAdManager> = .banner
                return adType as? AdType<T>
                
            case RawInnerAdType.mpu.rawValue:
                let adType: AdType<BannerAdManager> = .mpu
                return adType as? AdType<T>
                
            case RawInnerAdType.thumbnail.rawValue:
                let adType: AdType<ThumbnailAdManager> = .thumbnail
                return adType as? AdType<T>
                
            case RawInnerAdType.interstitial.rawValue + RawInnerAdType.maxSuffix.rawValue:
                let adType: AdType<InterstitialAdManager> = .maxHeaderBidding(adType:.interstitial, adMarkUpRetriever: adMarkUpRetriever as? MaxHeaderBidable)
                return adType as? AdType<T>
                
            case RawInnerAdType.rewarded.rawValue + RawInnerAdType.maxSuffix.rawValue:
                let adType: AdType<RewardedAdManager> = .maxHeaderBidding(adType:.rewarded, adMarkUpRetriever: adMarkUpRetriever as? MaxHeaderBidable)
                return adType as? AdType<T>
                
            case RawInnerAdType.thumbnail.rawValue + RawInnerAdType.maxSuffix.rawValue:
                let adType: AdType<ThumbnailAdManager> = .maxHeaderBidding(adType:.thumbnail, adMarkUpRetriever: adMarkUpRetriever as? MaxHeaderBidable)
                return adType as? AdType<T>
                
            case RawInnerAdType.banner.rawValue + RawInnerAdType.maxSuffix.rawValue:
                let adType: AdType<BannerAdManager> = .maxHeaderBidding(adType:.banner, adMarkUpRetriever: adMarkUpRetriever as? MaxHeaderBidable)
                return adType as? AdType<T>
                
            case RawInnerAdType.mpu.rawValue + RawInnerAdType.maxSuffix.rawValue:
                let adType: AdType<BannerAdManager> = .maxHeaderBidding(adType:.mpu, adMarkUpRetriever: adMarkUpRetriever as? MaxHeaderBidable)
                return adType as? AdType<T>
           
            case RawInnerAdType.interstitial.rawValue + RawInnerAdType.dtFairBidSuffix.rawValue:
                let adType: AdType<InterstitialAdManager> = .dtFairBidHeaderBidding(adType:.interstitial, adMarkUpRetriever: adMarkUpRetriever as? DTFairBidHeaderBidable)
                return adType as? AdType<T>
               
            case RawInnerAdType.rewarded.rawValue + RawInnerAdType.dtFairBidSuffix.rawValue:
                let adType: AdType<RewardedAdManager> = .dtFairBidHeaderBidding(adType:.rewarded, adMarkUpRetriever: adMarkUpRetriever as? DTFairBidHeaderBidable)
                return adType as? AdType<T>
               
            case RawInnerAdType.thumbnail.rawValue + RawInnerAdType.dtFairBidSuffix.rawValue:
                let adType: AdType<ThumbnailAdManager> = .dtFairBidHeaderBidding(adType:.thumbnail, adMarkUpRetriever: adMarkUpRetriever as? DTFairBidHeaderBidable)
                return adType as? AdType<T>
               
            case RawInnerAdType.banner.rawValue + RawInnerAdType.dtFairBidSuffix.rawValue:
                let adType: AdType<BannerAdManager> = .dtFairBidHeaderBidding(adType:.banner, adMarkUpRetriever: adMarkUpRetriever as? DTFairBidHeaderBidable)
                return adType as? AdType<T>
               
            case RawInnerAdType.mpu.rawValue + RawInnerAdType.dtFairBidSuffix.rawValue:
                let adType: AdType<BannerAdManager> = .dtFairBidHeaderBidding(adType:.mpu, adMarkUpRetriever: adMarkUpRetriever as? DTFairBidHeaderBidable)
                return adType as? AdType<T>
                
            default: throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "\(innerType) is not a valid AdType"))
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let innerType = try container.decode(Int.self)
       if let type = try AdType.adType(from: innerType, adMarkUpRetriever: nil) {
            self = type
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "\(innerType) is not a valid adType"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(innerType)
    }
}
