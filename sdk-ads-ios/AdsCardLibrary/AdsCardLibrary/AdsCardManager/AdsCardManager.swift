//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation
import OguryAds
import SwiftUI
import OguryCore.Private

//MARK: - AdsCardManager
public struct AdsCardManager {
    public static let testModeSuffix = "_test"
    internal static var logger: OguryLogger?
    
    public init(logger: OguryLogger? = nil) {
        AdsCardManager.logger = logger  
    }
    
    /// Returns the dedicated adManager associated with the ``AdType``
    /// - Parameters:
    ///   - adType:  the type of ad you want to instanciate
    ///   - options: the options associated with the AdManager to handle
    ///   - adDelegate: the ``AdLifeCycleDelegate`` object
    /// - Returns: a specific adManager that will be able to handle the adType used as parameter
    /// - throws: throws ``AdType/AdManagerError/adManagerMismatch`` if the type of the variable is not the type that should be used to
    /// handle this ad format
    ///
    /// - Note: How to retrieve a proper adManager for a dedicated AdType
    /// ```swift
    ///  let cardManager = AdsCardManager()
    ///  let interstitial: AdType<InterstitialAdManager> = .interstitial
    ///  let interstitialManager = try? cardManager.adManager(for: interstitial, options: AdManagerOptions(adUnitId: ""), adDelegate: nil)
    /// ```
    public func adManager<T: OguryAdManager>(for adType: AdType<T>,
                                        options: T.Options,
                                        adDelegate: AdLifeCycleDelegate?) throws -> T {
        var manager = try adType.adManager
        manager.adDelegate = adDelegate
        manager.options = options
        return manager
    }
    
    /// Return a SwiftUI adView Card to handle ad managed inside the `adManager`
    /// - Parameter adManager: the `AdManager` that handle the underlying ad
    /// - Returns: a SwiftUI AdView object that handles all ad lifecycle through its
    public func card(for adManager: inout any AdManager) -> AdView? {
        nil
    }
}

public extension String {
    var isTestModeOn: Bool { suffix(5) == AdsCardManager.testModeSuffix }
}

public enum AdTypeTitle: String {
    case interstitial
    case rewarded
    case thumbnail
    case banner
    case mpu
    
    var display: String {
        switch self {
            case .interstitial: return "Interstitial"
            case .rewarded: return "Rewarded"
            case .thumbnail: return "Thumbnail"
            case .banner: return "Small banner"
            case .mpu: return "MREC"
        }
    }
}

//MARK: - Ad Types
/// The ad format to load
/// Note that in order to use ``AdType/maxHeaderBidding(_:)``, you should also define the inner format
///
/// Example on how to use maxHeaderBidding
/// ```swift
/// let adType: AdType<InterstitialAdManager> = .maxHeaderBidding(.interstitial)
/// ```
public indirect enum AdType<T: OguryAdManager> {
    case interstitial
    case rewarded
    case thumbnail
    case banner
    case mpu
    case maxHeaderBidding(adType: AdType, adMarkUpRetriever: MaxHeaderBidable?)
    case dtFairBidHeaderBidding(adType: AdType, adMarkUpRetriever: DTFairBidHeaderBidable?)
    case unityLevelPlayHeaderBidding(adType: AdType, adMarkUpRetriever: UnityLevelPlayBidable?)
    
    /// returns the proper adManager handled by the AdType
    /// if no suitable adManager is found ``AdManagerError/adManagerMismatch`` is thrown
    internal var adManager: T  {
        get throws {
            switch self {
                case .rewarded:
                    guard T.self == RewardedAdManager.self else {
                        throw AdManagerError.adManagerMismatch
                    }
                    return RewardedAdManager(adType: .rewarded) as! T
                    
                case .interstitial:
                    guard T.self == InterstitialAdManager.self else {
                        throw AdManagerError.adManagerMismatch
                    }
                    return InterstitialAdManager(adType: .interstitial) as! T
                    
                case .thumbnail:
                    guard T.self == ThumbnailAdManager.self else {
                        throw AdManagerError.adManagerMismatch
                    }
                    return ThumbnailAdManager(adType: .thumbnail) as! T
                    
                case .banner:
                    guard T.self == BannerAdManager.self else {
                        throw AdManagerError.adManagerMismatch
                    }
                    return BannerAdManager(adType: .banner) as! T
                    
                case .mpu:
                    guard T.self == BannerAdManager.self else {
                        throw AdManagerError.adManagerMismatch
                    }
                    return BannerAdManager(adType: .mpu) as! T
                    
                case .maxHeaderBidding(.thumbnail, _):
                    fatalError("Thumbnail is not supported on HB")
                    
                case let .maxHeaderBidding(.interstitial, adMarkUpRetriever):
                    guard T.self == InterstitialAdManager.self else {
                        throw AdManagerError.adManagerMismatch
                    }
                    return InterstitialAdManager(adType: .maxHeaderBidding(adType: .interstitial, adMarkUpRetriever: adMarkUpRetriever)) as! T
                    
                case let .maxHeaderBidding(.rewarded, adMarkUpRetriever):
                    guard T.self == RewardedAdManager.self else {
                        throw AdManagerError.adManagerMismatch
                    }
                    return RewardedAdManager(adType: .maxHeaderBidding(adType: .rewarded, adMarkUpRetriever: adMarkUpRetriever)) as! T
                    
                case let .maxHeaderBidding(.banner, adMarkUpRetriever):
                    guard T.self == BannerAdManager.self else {
                        throw AdManagerError.adManagerMismatch
                    }
                    return BannerAdManager(adType: .maxHeaderBidding(adType: .banner, adMarkUpRetriever: adMarkUpRetriever)) as! T
                    
                case let .maxHeaderBidding(.mpu, adMarkUpRetriever):
                    guard T.self == BannerAdManager.self else {
                        throw AdManagerError.adManagerMismatch
                    }
                    return BannerAdManager(adType: .maxHeaderBidding(adType: .mpu, adMarkUpRetriever: adMarkUpRetriever)) as! T
                
                case .dtFairBidHeaderBidding(.thumbnail, _):
                   fatalError("Thumbnail is not supported on HB")
                   
                case let .dtFairBidHeaderBidding(.interstitial, adMarkUpRetriever):
                   guard T.self == InterstitialAdManager.self else {
                       throw AdManagerError.adManagerMismatch
                   }
                   return InterstitialAdManager(adType: .dtFairBidHeaderBidding(adType: .interstitial, adMarkUpRetriever: adMarkUpRetriever)) as! T
                   
                case let .dtFairBidHeaderBidding(.rewarded, adMarkUpRetriever):
                   guard T.self == RewardedAdManager.self else {
                       throw AdManagerError.adManagerMismatch
                   }
                   return RewardedAdManager(adType: .dtFairBidHeaderBidding(adType: .rewarded, adMarkUpRetriever: adMarkUpRetriever)) as! T
                   
                case let .dtFairBidHeaderBidding(.banner, adMarkUpRetriever):
                   guard T.self == BannerAdManager.self else {
                       throw AdManagerError.adManagerMismatch
                   }
                   return BannerAdManager(adType: .dtFairBidHeaderBidding(adType: .banner, adMarkUpRetriever: adMarkUpRetriever)) as! T
                   
                case let .dtFairBidHeaderBidding(.mpu, adMarkUpRetriever):
                   guard T.self == BannerAdManager.self else {
                       throw AdManagerError.adManagerMismatch
                   }
                   return BannerAdManager(adType: .dtFairBidHeaderBidding(adType: .mpu, adMarkUpRetriever: adMarkUpRetriever)) as! T

                case .unityLevelPlayHeaderBidding(.thumbnail, _):
                       fatalError("Thumbnail is not supported on HB")
                       
                case let .unityLevelPlayHeaderBidding(.interstitial, adMarkUpRetriever):
                   guard T.self == InterstitialAdManager.self else {
                       throw AdManagerError.adManagerMismatch
                   }
                   return InterstitialAdManager(adType: .unityLevelPlayHeaderBidding(adType: .interstitial, adMarkUpRetriever: adMarkUpRetriever)) as! T
                   
                case let .unityLevelPlayHeaderBidding(.rewarded, adMarkUpRetriever):
                   guard T.self == RewardedAdManager.self else {
                       throw AdManagerError.adManagerMismatch
                   }
                   return RewardedAdManager(adType: .unityLevelPlayHeaderBidding(adType: .rewarded, adMarkUpRetriever: adMarkUpRetriever)) as! T
                   
                case let .unityLevelPlayHeaderBidding(.banner, adMarkUpRetriever):
                   guard T.self == BannerAdManager.self else {
                       throw AdManagerError.adManagerMismatch
                   }
                   return BannerAdManager(adType: .unityLevelPlayHeaderBidding(adType: .banner, adMarkUpRetriever: adMarkUpRetriever)) as! T
                   
                case let .unityLevelPlayHeaderBidding(.mpu, adMarkUpRetriever):
                   guard T.self == BannerAdManager.self else {
                       throw AdManagerError.adManagerMismatch
                   }
                   return BannerAdManager(adType: .unityLevelPlayHeaderBidding(adType: .mpu, adMarkUpRetriever: adMarkUpRetriever)) as! T

                default: throw AdManagerError.adManagerMismatch
            }
        }
    }
    
    public var displayTitle: String {
        switch self {
            case .interstitial: return AdTypeTitle.interstitial.display
            case .rewarded: return AdTypeTitle.rewarded.display
            case .thumbnail: return AdTypeTitle.thumbnail.display
            case .mpu: return AdTypeTitle.mpu.display
            case .banner: return AdTypeTitle.banner.display
            case let .maxHeaderBidding(innerType, _): return innerType.displayTitle
            case let .dtFairBidHeaderBidding(innerType, _): return innerType.displayTitle
            case let .unityLevelPlayHeaderBidding(innerType, _): return innerType.displayTitle
        }
    }
    
    public var headerTitle: String {
        switch self {
            case .interstitial: return AdTypeTitle.interstitial.display
            case .rewarded: return AdTypeTitle.rewarded.display
            case .thumbnail: return AdTypeTitle.thumbnail.display
            case .mpu: return AdTypeTitle.mpu.display
            case .banner: return AdTypeTitle.banner.display
            case let .maxHeaderBidding(innerType, _): return innerType.displayTitle
            case let .dtFairBidHeaderBidding(innerType, _): return innerType.displayTitle
            case let .unityLevelPlayHeaderBidding(innerType, _): return innerType.displayTitle
        }
    }
    
    public var uuid: Int {
        switch self {
            case .interstitial: return displayTitle.hashValue
            case .rewarded: return displayTitle.hashValue
            case .thumbnail: return displayTitle.hashValue
            case .mpu: return displayTitle.hashValue
            case .banner: return displayTitle.hashValue
            case let .maxHeaderBidding(inner, _): return ("maxHeaderBidding" + inner.displayTitle).hashValue
            case let .dtFairBidHeaderBidding(inner, _): return ("dtFairBidHeaderBidding" + inner.displayTitle).hashValue
            case let .unityLevelPlayHeaderBidding(inner, _): return ("unityLevelPlayHeaderBidding" + inner.displayTitle).hashValue
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


//MARK: - Errors
extension AdType {
    /// Errors that can be thrown by ``AdsCardManager/adManager(for:options:adDelegate:)``
    public enum AdManagerError: Error {
        /// The type of the AdManager that should be used is different from the one specified at call level
        case adManagerMismatch
    }
}

public protocol TypeErasing {
    var underlyingValue: Any { get }
}

public struct TypeEraser<V: OguryAdManager>: TypeErasing {
    let orinal: AdType<V>
    public var underlyingValue: Any {
        return self.orinal
    }
}

public struct AnyAdType: Identifiable, Hashable {
    public let id = UUID()
    typealias Value = Any
    private let eraser: TypeErasing
    public init<V>(_ adType: AdType<V>) where V:OguryAdManager {
        eraser = TypeEraser(orinal: adType)
    }
    
    public var adType: Any {
        return eraser.underlyingValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension AnyAdType: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return String(describing: lhs) == String(describing: rhs)
    }
}
