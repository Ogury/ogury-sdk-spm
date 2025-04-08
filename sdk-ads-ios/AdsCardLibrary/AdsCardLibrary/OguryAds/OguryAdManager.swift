//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import OguryAds
import WebKit

/// All objects that should have an ad manager basic bahavior should implement this protocol
public protocol OguryAdManager: AdManager {
    /// The underlying ad implementation associated with this manager
    associatedtype Ad
    /// the ad associate with this ad format. Mandatory
    var ad: Ad! { get }
    /// the type of ad to load
    var adType: AdType<Self> { get }
    /// The underlying ad implementation associated with this manager
    associatedtype Options: OguryAdOptions
    /// the options associate with this ad format. Mandatory
    var options: Options! { get set }
    /// updates the base options
    func update(options: BaseAdOptions)
    /// instanciate a new AdManager object with a given ad type
    init(adType: AdType<Self>,
         adConfiguration: AdConfiguration,
         cardConfiguration: CardConfiguration,
         viewController: UIViewController?,
         adDelegate: AdLifeCycleDelegate?)
    /// the SwiftUI view that will be displayed and which will manage the underlying ad format
    var adView: AdView { get }
    /// the SwiftUI view dedicated to specific that will be displayed and which will manage the underlying ad format options
    var adOptionView: (any View)? { get }
    /// banner delegate for the controller
    var adDelegate: AdLifeCycleDelegate? { get set }
    /// Mimics the ``AdLifeCycleDelegate`` with Combine in order to ease TCA integration
    var events: PassthroughSubject<AdLifeCycleEvent, Never> { get }
    /// An ordered list of all the events
    var lifeCycleEvents: [AdLifeCycleEventHistory] { get }
    /// appends an event to the ``lifeCycleEvents`` array and triggers a publisher event on ``events``
    func append(_ event: AdLifeCycleEvent)
    /// asks the AdManager to load the add
    /// - Throws : throws an error if the ad can't be instanciated
    func loadAd(from options: BaseAdOptions) throws
    /// asks the AdManager to show the add
    func showAd() throws
    // updates the card from the event
    func updateCard(events: [AdOptionsEvent])
    // simulate a memory pressure by calling webViewTerminated
    func killWebview(_: KillWebviewMode)
}

extension AdType {
    struct OguryAdapterAdFormat: ACLAdapterFormat {
        var adFormat: AdFormat
        /// have to use this trick because `any [AdTag]` does not conform to Codable 😓
        var tags: [any AdTag] {
            get { ogyTags as [any AdTag] }
            set { ogyTags = newValue as? [OguryAdTag] ?? [] }
        }
        var ogyTags: [OguryAdTag]
        var displayName: String { adFormat.name }
        var adType: Int
        var options: AdAdapterFormatOptions
        var id: UUID { UUID(displayName.hashValue) }
    }
    var adFormat: any ACLAdapterFormat {
        switch self {
            case .interstitial:
                return OguryAdapterAdFormat(adFormat: .interstitial,
                                            ogyTags: [OguryAdTag.ogury, OguryAdTag.direct],
                                            adType: 0,
                                            options: AdAdapterFormatOptions())
                
            case .rewarded:
                return OguryAdapterAdFormat(adFormat: .rewardedVideo,
                                            ogyTags: [OguryAdTag.ogury, OguryAdTag.direct],
                                            adType: 0,
                                            options: AdAdapterFormatOptions())
                
            case .thumbnail:
                return OguryAdapterAdFormat(adFormat: .thumbnail,
                                            ogyTags: [OguryAdTag.ogury, OguryAdTag.direct],
                                            adType: 0,
                                            options: AdAdapterFormatOptions())
                
            case .banner:
                return OguryAdapterAdFormat(adFormat: .smallBanner,
                                            ogyTags: [OguryAdTag.ogury, OguryAdTag.direct],
                                            adType: 0,
                                            options: AdAdapterFormatOptions())
                
            case .mpu:
                return OguryAdapterAdFormat(adFormat: .mrec,
                                            ogyTags: [OguryAdTag.ogury, OguryAdTag.direct],
                                            adType: 0,
                                            options: AdAdapterFormatOptions())
                
            case .maxHeaderBidding(let adType, _):
                var innerType: OguryAdapterAdFormat = adType.adFormat as! OguryAdapterAdFormat
                innerType.options.enableRtbTestMode = enableRtbTestMode
                innerType.ogyTags = [OguryAdTag.max, OguryAdTag.headerBidding, OguryAdTag.bypass]
                return innerType
                
            case .dtFairBidHeaderBidding(let adType, _):
                var innerType: OguryAdapterAdFormat = adType.adFormat as! OguryAdapterAdFormat
                innerType.options.enableRtbTestMode = enableRtbTestMode
                innerType.ogyTags = [OguryAdTag.dtFairbid, OguryAdTag.headerBidding, OguryAdTag.bypass]
                return innerType
                
            case .unityLevelPlayHeaderBidding(let adType, _):
                var innerType: OguryAdapterAdFormat = adType.adFormat as! OguryAdapterAdFormat
                innerType.options.enableRtbTestMode = enableRtbTestMode
                innerType.ogyTags = [OguryAdTag.unityLevelPlay, OguryAdTag.headerBidding, OguryAdTag.bypass]
                return innerType
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
    internal func adManager(from options: AdManagerOptions,
                            viewController: UIViewController?,
                            adDelegate: AdLifeCycleDelegate?) throws -> T  {
        switch self {
            case .rewarded:
                guard T.self == RewardedAdManager.self else {
                    throw AdManagerError.adManagerMismatch
                }
                return RewardedAdManager(adType: .rewarded,
                                         adConfiguration: .init(options: options),
                                         cardConfiguration: .init(options: options),
                                         viewController: viewController,
                                         adDelegate: adDelegate) as! T
                
            case .interstitial:
                guard T.self == InterstitialAdManager.self else {
                    throw AdManagerError.adManagerMismatch
                }
                return InterstitialAdManager(adType: .interstitial,
                                             adConfiguration: .init(options: options),
                                             cardConfiguration: .init(options: options),
                                             viewController: viewController,
                                             adDelegate: adDelegate) as! T
                
            case .thumbnail:
                guard T.self == ThumbnailAdManager.self else {
                    throw AdManagerError.adManagerMismatch
                }
                return ThumbnailAdManager(adType: .thumbnail,
                                          adConfiguration: .init(options: options),
                                          cardConfiguration: .init(options: options),
                                          viewController: viewController,
                                          adDelegate: adDelegate) as! T
                
            case .banner:
                guard T.self == BannerAdManager.self else {
                    throw AdManagerError.adManagerMismatch
                }
                return BannerAdManager(adType: .banner,
                                       adConfiguration: .init(options: options),
                                       cardConfiguration: .init(options: options),
                                       viewController: viewController,
                                       adDelegate: adDelegate) as! T
                
            case .mpu:
                guard T.self == BannerAdManager.self else {
                    throw AdManagerError.adManagerMismatch
                }
                return BannerAdManager(adType: .mpu,
                                       adConfiguration: .init(options: options),
                                       cardConfiguration: .init(options: options),
                                       viewController: viewController,
                                       adDelegate: adDelegate) as! T
                
            case .maxHeaderBidding(.thumbnail, _):
                fatalError("Thumbnail is not supported on HB")
                
            case let .maxHeaderBidding(.interstitial, adMarkUpRetriever):
                guard T.self == InterstitialAdManager.self else {
                    throw AdManagerError.adManagerMismatch
                }
                return InterstitialAdManager(adType: .maxHeaderBidding(adType: .interstitial, adMarkUpRetriever: adMarkUpRetriever),
                                             adConfiguration: .init(options: options),
                                             cardConfiguration: .init(options: options),
                                             viewController: viewController,
                                             adDelegate: adDelegate) as! T
                
            case let .maxHeaderBidding(.rewarded, adMarkUpRetriever):
                guard T.self == RewardedAdManager.self else {
                    throw AdManagerError.adManagerMismatch
                }
                return RewardedAdManager(adType: .maxHeaderBidding(adType: .rewarded, adMarkUpRetriever: adMarkUpRetriever),
                                         adConfiguration: .init(options: options),
                                         cardConfiguration: .init(options: options),
                                         viewController: viewController,
                                         adDelegate: adDelegate) as! T
                
            case let .maxHeaderBidding(.banner, adMarkUpRetriever):
                guard T.self == BannerAdManager.self else {
                    throw AdManagerError.adManagerMismatch
                }
                return BannerAdManager(adType: .maxHeaderBidding(adType: .banner, adMarkUpRetriever: adMarkUpRetriever),
                                       adConfiguration: .init(options: options),
                                       cardConfiguration: .init(options: options),
                                       viewController: viewController,
                                       adDelegate: adDelegate) as! T
                
            case let .maxHeaderBidding(.mpu, adMarkUpRetriever):
                guard T.self == BannerAdManager.self else {
                    throw AdManagerError.adManagerMismatch
                }
                return BannerAdManager(adType: .maxHeaderBidding(adType: .mpu, adMarkUpRetriever: adMarkUpRetriever),
                                       adConfiguration: .init(options: options),
                                       cardConfiguration: .init(options: options),
                                       viewController: viewController,
                                       adDelegate: adDelegate) as! T
                
            case .dtFairBidHeaderBidding(.thumbnail, _):
                fatalError("Thumbnail is not supported on HB")
                
            case let .dtFairBidHeaderBidding(.interstitial, adMarkUpRetriever):
                guard T.self == InterstitialAdManager.self else {
                    throw AdManagerError.adManagerMismatch
                }
                return InterstitialAdManager(adType: .dtFairBidHeaderBidding(adType: .interstitial, adMarkUpRetriever: adMarkUpRetriever),
                                             adConfiguration: .init(options: options),
                                             cardConfiguration: .init(options: options),
                                             viewController: viewController,
                                             adDelegate: adDelegate) as! T
                
            case let .dtFairBidHeaderBidding(.rewarded, adMarkUpRetriever):
                guard T.self == RewardedAdManager.self else {
                    throw AdManagerError.adManagerMismatch
                }
                return RewardedAdManager(adType: .dtFairBidHeaderBidding(adType: .rewarded, adMarkUpRetriever: adMarkUpRetriever),
                                         adConfiguration: .init(options: options),
                                         cardConfiguration: .init(options: options),
                                         viewController: viewController,
                                         adDelegate: adDelegate) as! T
                
            case let .dtFairBidHeaderBidding(.banner, adMarkUpRetriever):
                guard T.self == BannerAdManager.self else {
                    throw AdManagerError.adManagerMismatch
                }
                return BannerAdManager(adType: .dtFairBidHeaderBidding(adType: .banner, adMarkUpRetriever: adMarkUpRetriever),
                                       adConfiguration: .init(options: options),
                                       cardConfiguration: .init(options: options),
                                       viewController: viewController,
                                       adDelegate: adDelegate) as! T
                
            case let .dtFairBidHeaderBidding(.mpu, adMarkUpRetriever):
                guard T.self == BannerAdManager.self else {
                    throw AdManagerError.adManagerMismatch
                }
                return BannerAdManager(adType: .dtFairBidHeaderBidding(adType: .mpu, adMarkUpRetriever: adMarkUpRetriever),
                                       adConfiguration: .init(options: options),
                                       cardConfiguration: .init(options: options),
                                       viewController: viewController,
                                       adDelegate: adDelegate) as! T
                
            case .unityLevelPlayHeaderBidding(.thumbnail, _):
                fatalError("Thumbnail is not supported on HB")
                
            case let .unityLevelPlayHeaderBidding(.interstitial, adMarkUpRetriever):
                guard T.self == InterstitialAdManager.self else {
                    throw AdManagerError.adManagerMismatch
                }
                return InterstitialAdManager(adType: .unityLevelPlayHeaderBidding(adType: .interstitial, adMarkUpRetriever: adMarkUpRetriever),
                                             adConfiguration: .init(options: options),
                                             cardConfiguration: .init(options: options),
                                             viewController: viewController,
                                             adDelegate: adDelegate) as! T
                
            case let .unityLevelPlayHeaderBidding(.rewarded, adMarkUpRetriever):
                guard T.self == RewardedAdManager.self else {
                    throw AdManagerError.adManagerMismatch
                }
                return RewardedAdManager(adType: .unityLevelPlayHeaderBidding(adType: .rewarded, adMarkUpRetriever: adMarkUpRetriever),
                                         adConfiguration: .init(options: options),
                                         cardConfiguration: .init(options: options),
                                         viewController: viewController,
                                         adDelegate: adDelegate) as! T
                
            case let .unityLevelPlayHeaderBidding(.banner, adMarkUpRetriever):
                guard T.self == BannerAdManager.self else {
                    throw AdManagerError.adManagerMismatch
                }
                return BannerAdManager(adType: .unityLevelPlayHeaderBidding(adType: .banner, adMarkUpRetriever: adMarkUpRetriever),
                                       adConfiguration: .init(options: options),
                                       cardConfiguration: .init(options: options),
                                       viewController: viewController,
                                       adDelegate: adDelegate) as! T
                
            case let .unityLevelPlayHeaderBidding(.mpu, adMarkUpRetriever):
                guard T.self == BannerAdManager.self else {
                    throw AdManagerError.adManagerMismatch
                }
                return BannerAdManager(adType: .unityLevelPlayHeaderBidding(adType: .mpu, adMarkUpRetriever: adMarkUpRetriever),
                                       adConfiguration: .init(options: options),
                                       cardConfiguration: .init(options: options),
                                       viewController: viewController,
                                       adDelegate: adDelegate) as! T
                
            default: throw AdManagerError.adManagerMismatch
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
