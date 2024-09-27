//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation
import OguryAds
import OguryAds.Private
import SwiftUI

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
    public func adManager<T: AdManager>(for adType: AdType<T>,
                                        options: T.Options,
                                        adDelegate: AdLifeCycleDelegate?) throws -> T {
        var manager = try adType.adManager
        manager.adDelegate = adDelegate
        manager.options = options
        return manager
    }
    
    public func launch(with assetKey: String, environment: String) {
        DispatchQueue.main.async {
            let sel = NSSelectorFromString("changeServerEnvironment:")
            OGAInternal.shared().perform(sel, with: environment)
            OguryAds.shared().setup(withAssetKey: assetKey)
        }
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
}

//MARK: - Ad Types
/// The ad format to load
/// Note that in order to use ``AdType/maxHeaderBidding(_:)``, you should also define the inner format
///
/// Example on how to use maxHeaderBidding
/// ```swift
/// let adType: AdType<InterstitialAdManager> = .maxHeaderBidding(.interstitial)
/// ```
public indirect enum AdType<T: AdManager> {
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
            case .interstitial: return AdTypeTitle.interstitial.rawValue
            case .rewarded: return AdTypeTitle.rewarded.rawValue
            case .thumbnail: return AdTypeTitle.thumbnail.rawValue
            case .mpu: return AdTypeTitle.mpu.rawValue
            case .banner: return AdTypeTitle.banner.rawValue
            case let .maxHeaderBidding(innerType, _): return innerType.displayTitle
            case let .dtFairBidHeaderBidding(innerType, _): return innerType.displayTitle
            case let .unityLevelPlayHeaderBidding(innerType, _): return innerType.displayTitle
        }
    }
    
    public var headerTitle: String {
        switch self {
            case .interstitial: return AdTypeTitle.interstitial.rawValue
            case .rewarded: return AdTypeTitle.rewarded.rawValue
            case .thumbnail: return AdTypeTitle.thumbnail.rawValue
            case .mpu: return AdTypeTitle.mpu.rawValue
            case .banner: return AdTypeTitle.banner.rawValue
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
    
    public var tags: [AdTag] {
        switch self {
            case .interstitial, .rewarded, .thumbnail, .banner, .mpu: return [.ogury, .direct]
            case .maxHeaderBidding: return [.max, .headerBidding, .bypass]
            case .dtFairBidHeaderBidding: return [.dtFairbid, .headerBidding, .bypass]
            case .unityLevelPlayHeaderBidding: return [.unityLevelPlay, .headerBidding, .bypass]
        }
    }
    
    public var isHeaderBidding: Bool {
        switch self {
            case .interstitial, .rewarded, .thumbnail, .banner, .mpu: return false
            default: return true
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

public enum AdTag: String, Equatable {
    case ogury, max, dtFairbid, unityLevelPlay, direct, bypass, waterfall, headerBidding, oguryTestMode, rtbTestMode
    
    public var name: String {
        switch self {
            case .ogury: return "Ogury"
            case .max: return "Max"
            case .dtFairbid: return "Digital Turbine Fairbid"
            case .direct: return "Direct"
            case .bypass: return "Bypass"
            case .waterfall: return "Waterfall"
            case .headerBidding: return "HB"
            case .unityLevelPlay: return "Unity LevelPlay"
            case .oguryTestMode: return "Ogury Test Mode"
            case .rtbTestMode: return "RTB Test Mode"
        }
    }
    public var description: String {
        switch self {
            case .ogury: return "Ogury"
            case .max: return "AppLovin Max"
            case .dtFairbid: return "Fyber"
            case .unityLevelPlay: return "Unity LevelPlay"
            case .direct: return "Direct integration"
            case .bypass: return "The mediation's SDK is bypassed when loading the ad. In header bidding mediation case, the test app directly calls the ms-bidder endpoint of the mediation to retrieve an ad"
            case .waterfall: return "Waterfall auction integration"
            case .headerBidding: return "Header bidding integration"
            case .oguryTestMode: return "Add _test to the ad unit"
            case .rtbTestMode: return "Add test=1 to bid request"
        }
    }
    
    internal var color: Color {
        switch self {
            case .ogury: return Color(#colorLiteral(red: 0.1051147357, green: 0.2970786095, blue: 0.4525763392, alpha: 1))
            case .max: return Color(#colorLiteral(red: 0.5056632757, green: 0.4479025602, blue: 0.9351767898, alpha: 1))
            case .dtFairbid: return Color(#colorLiteral(red: 0.8326988816, green: 0.2894239128, blue: 0.3478675783, alpha: 1))
            case .unityLevelPlay: return Color(#colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1))
            case .direct: return Color(#colorLiteral(red: 0.6542432308, green: 0.8769065142, blue: 0.9881662726, alpha: 1))
            case .bypass:  return Color(#colorLiteral(red: 0, green: 0.4201652408, blue: 0.4244114757, alpha: 1))
            case .waterfall: return Color(#colorLiteral(red: 0, green: 0.5913378596, blue: 1, alpha: 1))
            case .headerBidding: return Color(#colorLiteral(red: 0, green: 0.8673904538, blue: 0.2728650272, alpha: 1))
            case .oguryTestMode: return Color(#colorLiteral(red: 0.6542432308, green: 0.8769065142, blue: 0.9881662726, alpha: 1))
            case .rtbTestMode: return Color(#colorLiteral(red: 0.6542432308, green: 0.8769065142, blue: 0.9881662726, alpha: 1))
        }
    }
    
    internal var textColor: Color {
        switch self {
            case .direct, .headerBidding, .rtbTestMode, .oguryTestMode: return .black
            default: return .white
        }
    }
}

public protocol TypeErasing {
    var underlyingValue: Any { get }
}

public struct TypeEraser<V: AdManager>: TypeErasing {
    let orinal: AdType<V>
    public var underlyingValue: Any {
        return self.orinal
    }
}

public struct AnyAdType: Identifiable, Hashable {
    public let id = UUID()
    typealias Value = Any
    private let eraser: TypeErasing
    public init<V>(_ adType: AdType<V>) where V:AdManager {
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
