//
//  AdManager.swift
//  UnityLevelPlayCardAdapter
//
//  Created by Jerome TONNELIER on 07/05/2025.
//

import SwiftUI
import AdsCardAdapter
import AdsCardLibrary
import Combine
import IronSource

enum AdType: AdAdapterFormat, RawRepresentable, Equatable {
    case headerBidding(_: AdFormat)
    case waterfall(_: AdFormat)
    
    var adUnit: String {
        switch self {
            case let .headerBidding(adFormat):
                switch adFormat {
                    case .interstitial: return "g3od8mer7o464aw7"
                    case .rewardedVideo: return "a838wmqd7zm9py8b"
                    case .smallBanner: return "nskkdxm4ovkpg3a7"
                    case .mrec: return "ccto2jp7yug7z53e"
                    case .thumbnail: fallthrough
                    @unknown default:
                        fatalError()
                }
                
            case let .waterfall(adFormat):
                switch adFormat {
                    case .interstitial: return "ygf0aaj5owuvic0x"
                    case .rewardedVideo: return "xoivghporet4j1pm"
                    case .smallBanner: return "usa76usbg4hvdsow"
                    case .mrec: return "vnufmywgs9qqnqjm"
                    case .thumbnail: fallthrough
                    @unknown default:
                        fatalError()
                }
        }
    }
    
    var adFormat: AdFormat {
        switch self {
            case let .headerBidding(adFormat): return adFormat
            case let .waterfall(adFormat): return adFormat
        }
    }
    
    var tags: [any AdTag] {
        switch self {
            case .headerBidding: return [OguryAdTag.headerBidding, OguryAdTag.unityLevelPlay]
            case .waterfall: return [OguryAdTag.waterfall, OguryAdTag.unityLevelPlay]
        }
    }
    
    var displayName: String {
        switch self {
            case let .headerBidding(adFormat): return adFormat.name
            case let .waterfall(adFormat): return adFormat.name
        }
    }
    
    var id: UUID {
        switch self {
            case let .headerBidding(adFormat): return "ULPHB\(adFormat.name)".uuid
            case let .waterfall(adFormat): return "ULPWF\(adFormat.name)".uuid
        }
    }
    
    var sortOrder: Int {
        switch self {
            case let .headerBidding(adFormat):
                switch adFormat {
                    case .interstitial: return 0
                    case .rewardedVideo: return 1
                    case .smallBanner: return 2
                    case .mrec: return 3
                    case .thumbnail: fallthrough
                    @unknown default:
                        fatalError()
                }
                
            case let .waterfall(adFormat):
                switch adFormat {
                    case .interstitial: return 10
                    case .rewardedVideo: return 11
                    case .smallBanner: return 12
                    case .mrec: return 13
                    case .thumbnail: fallthrough
                    @unknown default:
                        fatalError()
                }
        }
    }
    
    var displayIcon: Image {
        switch self {
            case let .headerBidding(adFormat):
                switch adFormat {
                    case .interstitial: return Image(systemName: "iphone").symbolRenderingMode(.monochrome)
                    case .rewardedVideo: return Image(systemName: "iphone.gen3.badge.play")
                    case .smallBanner, .mrec: return Image(systemName: "platter.filled.bottom.iphone")
                    case .thumbnail: return Image(systemName: "rectangle.portrait.bottomright.inset.filled")
                    @unknown default: fatalError("unknown adFormat \(adFormat)")
                }
                
            case let .waterfall(adFormat):
                switch adFormat {
                    case .interstitial: return Image(systemName: "iphone").symbolRenderingMode(.monochrome)
                    case .rewardedVideo: return Image(systemName: "iphone.gen3.badge.play")
                    case .smallBanner, .mrec: return Image(systemName: "platter.filled.bottom.iphone")
                    case .thumbnail: return Image(systemName: "rectangle.portrait.bottomright.inset.filled")
                    @unknown default: fatalError("unknown adFormat \(adFormat)")
                }
        }
    }
    
    init?(rawValue: Int) {
        switch rawValue {
            case 300: self = .headerBidding(.interstitial)
            case 301: self = .headerBidding(.rewardedVideo)
            case 302: self = .headerBidding(.smallBanner)
            case 303: self = .headerBidding(.mrec)
            case 310: self = .waterfall(.interstitial)
            case 311: self = .waterfall(.rewardedVideo)
            case 312: self = .waterfall(.smallBanner)
            case 313: self = .waterfall(.mrec)
            default: return nil
        }
    }
    
    private static let prefix = 300
    var rawValue: Int { AdType.prefix + self.sortOrder }
    
    static func < (lhs: AdType, rhs: AdType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    internal func adManager(viewController: UIViewController?,
                            adDelegate: AdLifeCycleDelegate?) throws(AdsCardAdapterError) -> ULPAdManager  {
        var innerFormat: AdFormat?
        switch self {
            case let .headerBidding(innerAdFormat): innerFormat = innerAdFormat
            case let .waterfall(innerAdFormat): innerFormat = innerAdFormat
        }
        guard let innerFormat else { throw .noSuitableAdapterAvailable }
        switch innerFormat {
            case .interstitial: return ULPIntertstitialAdManager(adType: self, viewController: viewController, adDelegate: adDelegate)
            case .rewardedVideo: return ULPRewardedAdManager(adType: self, viewController: viewController, adDelegate: adDelegate)
            case .smallBanner: return ULPBannerAdManager(adType: self, viewController: viewController, adDelegate: adDelegate)
            case .mrec: return ULPBannerAdManager(adType: self, viewController: viewController, adDelegate: adDelegate)
            case .thumbnail: fallthrough
            @unknown default:  throw .noSuitableAdapterAvailable
        }
    }
}


class ULPAdManager: NSObject, AdManager {
    var proxy: ULPDelegateProxy
    var adType: AdType
    var adFormat: AdFormat {
        get { adType.adFormat }
        set {}
    }
    
    var id: UUID = .init()
    var adConfiguration: AdConfiguration!
    var cardConfiguration: CardConfiguration!
    var viewController: UIViewController?
    var adDelegate: (any AdLifeCycleDelegate)?
    var events: PassthroughSubject<AdLifeCycleEvent, Never> = .init()
    var lifeCycleEvents: [AdLifeCycleEventHistory] = []
    var adView: AdView {
        var wself: (any AdManager)? = self
        return AdsCardManager().card(for: &wself!)
    }
    
    func update(_ adConfiguration: AdConfiguration) {
        if adConfiguration.adUnitId != self.adConfiguration.adUnitId {
            resetAd()
        }
        self.adConfiguration = adConfiguration
    }
    
    internal func instanciateAd() async {
        fatalError("Implement method")
    }
    internal func resetAd() {
        fatalError("Implement method")
    }
    
    func load() async {
        append(.adLoading)
    }
    
    func show() {
        fatalError("Should be implemented in subclass")
    }
    
    func close() {
        // n/a
    }
    
    func killWebview(_ killMode: KillWebviewMode) {
        // n/a
    }
    
    func append(_ event: AdLifeCycleEvent) {
        events.send(event)
        lifeCycleEvents.append(AdLifeCycleEventHistory(event: event))
    }
    
    func encode() -> AdCardContainer {
        AdCardContainer(name: cardConfiguration.adDisplayName,
                        adType: adType.rawValue,
                        adInformations: .init(adUnitId: adConfiguration.adUnitId,
                                              settings: .init(oguryTestModeEnabled: false,
                                                              rtbTestModeEnabled: true,
                                                              qaLabel: cardConfiguration.qaLabel)))
    }
    
    class func decode(from container: AdCardContainer) throws(AdCardContainerError) -> any AdManager {
        fatalError("Should be implemented in subclass")
    }
    
    //MARK: Initializer
    public init(adType: AdType,
                adConfiguration: AdConfiguration = .init(adUnitId: ""),
                cardConfiguration: CardConfiguration = .init(),
                viewController: UIViewController?,
                adDelegate: AdLifeCycleDelegate? = nil) {
        events = PassthroughSubject<AdLifeCycleEvent, Never>()
        self.adType = adType
        self.adConfiguration = adConfiguration
        self.cardConfiguration = cardConfiguration
        self.viewController = viewController
        self.adDelegate = adDelegate
        proxy = ULPDelegateProxy()
        super.init()
        proxy.adManager = self
    }
}

class ULPDelegateProxy: NSObject, LPMInterstitialAdDelegate, LPMRewardedAdDelegate, LPMBannerAdViewDelegate {
    var adManager: ULPAdManager?
    
    func didLoadAd(with adInfo: LPMAdInfo) {
        guard let adManager else { return }
        adManager.append(.adLoaded(canShow: true))
    }
    
    func didFailToLoadAd(withAdUnitId adUnitId: String, error: any Error) {
        guard let adManager else { return }
        adManager.append(.adDidFailToLoad(error))
    }
    
    func didDisplayAd(with adInfo: LPMAdInfo) {
        guard let adManager else { return }
        adManager.append(.adDisplaying)
    }
    
    func didClickAd(with adInfo: LPMAdInfo) {
        guard let adManager else { return }
        adManager.append(.adClicked)
    }
    
    func didCloseAd(with adInfo: LPMAdInfo) {
        guard let adManager else { return }
        adManager.append(.adClosed)
    }
    
    func didFailToDisplayAd(with adInfo: LPMAdInfo, error: any Error) {
        guard let adManager else { return }
        adManager.append(.adDidFailToDisplay(error))
    }
    
    func didRewardAd(with adInfo: LPMAdInfo, reward: LPMReward) {
        guard let adManager else { return }
        adManager.append(.rewardReady(name: reward.name, value: "\(reward.amount)"))
    }
    
}
