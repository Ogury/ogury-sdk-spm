//
//  MaxAdManager.swift
//  MaxCardAdapter
//
//  Created by Jerome TONNELIER on 17/04/2025.
//

import Foundation
import SwiftUI
import AppLovinSDK
import AdsCardLibrary
import AdsCardAdapter
import Combine

enum MaxAdType: AdAdapterFormat, RawRepresentable, Equatable {
    case `default`(_: AdFormat)
    
    var adFormat: AdFormat {
        switch self {
            case let .default(adFormat): return adFormat
        }
    }
    
    var adUnit: String {
        switch self {
            case let .default(adFormat):
                switch adFormat {
                    case .interstitial: return "33ef6bc64f259a70"
                    case .rewardedVideo: return "bee4990ad3478ccd"
                    case .standardBanner: return "9bf5161c44fe5a8f"
                    default: fatalError("AdFormat \(adFormat) not supported")
                }
        }
    }
    
    var tags: [any AdTag] {
        [OguryAdTag.max, OguryAdTag.headerBidding]
    }
    
    var displayName: String {
        switch self {
            case let .default(adFormat):
                switch adFormat {
                    case .standardBanner: return "Std banners"
                    default: return adFormat.name
                }
        }
    }
    
    var id: UUID { displayName.uuid }
    
    var sortOrder: Int {
        switch self {
            case let .default(adFormat):
                switch adFormat {
                    case .interstitial: return 0
                    case .rewardedVideo: return 1
                    case .standardBanner: return 2
                    case .thumbnail: fatalError("No thumbnail on AppLovin")
                    @unknown default: fatalError("unknown adFormat \(adFormat)")
                }
        }
    }
    
    init?(rawValue: Int) {
        switch rawValue {
            case 100: self = .`default`(.interstitial)
            case 101: self = .`default`(.rewardedVideo)
            case 102: self = .`default`(.standardBanner)
            default: return nil
        }
    }
    
    private static let maxPrefix = 100
    var rawValue: Int { MaxAdType.maxPrefix + self.sortOrder }
    
    static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
    
    /// associated icon
    public var displayIcon: Image {
        switch self {
            case let .default(adFormat):
                switch adFormat {
                    case .interstitial: return Image(systemName: "iphone").symbolRenderingMode(.monochrome)
                    case .rewardedVideo: return Image(systemName: "iphone.gen3.badge.play")
                    case .standardBanner: return Image(systemName: "platter.filled.bottom.iphone")
                    case .thumbnail: return Image(systemName: "rectangle.portrait.bottomright.inset.filled")
                    @unknown default: fatalError("unknown adFormat \(adFormat)")
                }
        }
    }
    
    internal func adManager(viewController: UIViewController?,
                            adDelegate: AdLifeCycleDelegate?) -> MaxAdManager  {
        switch self {
            case let .default(innerType):
                switch innerType {
                    case .interstitial: return MaxInterstitialAdManager(adType: self, viewController: viewController, adDelegate: adDelegate)
                    case .rewardedVideo: return MaxRewardedAdManager(adType: self, viewController: viewController, adDelegate: adDelegate)
                    case .standardBanner: return MaxBannerAdManager(adType: self, viewController: viewController, adDelegate: adDelegate)
                    default: fatalError()
                }
        }
    }
}

enum MaxError: Error {
    case maError(MAError)
    case adNotReady
}

extension MaxError: ErrorConvertible {
    var readableError: String? {
        switch self {
            case .maError(let mAError): return mAError.message
            case .adNotReady: return "Ad is not ready to show"
        }
    }
}

class ALDelegateProxy: NSObject, MAAdDelegate, MARewardedAdDelegate, MAAdViewAdDelegate {
    func didExpand(_ ad: MAAd) {
        guard let adManager = adManager as? MaxBannerAdManager else { return }
        adManager.append(.adDisplaying)
    }
    
    func didCollapse(_ ad: MAAd) {
        guard let adManager else { return }
        adManager.append(.adClosed)
    }
    
    func didRewardUser(for ad: MAAd, with reward: MAReward) {
        guard let adManager else { return }
        adManager.append(.rewardReady(name: reward.label, value: "\(reward.amount)"))
    }
    
    func didLoad(_ ad: MAAd) {
        guard let adManager else { return }
        adManager.append(.adLoaded(canShow: true))
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        guard let adManager else { return }
        adManager.append(.adDidFailToLoad(MaxError.maError(error)))
    }
    
    func didDisplay(_ ad: MAAd) {
        guard let adManager else { return }
        adManager.append(.adDisplaying)
    }
    
    func didHide(_ ad: MAAd) {
        guard let adManager = adManager as? MaxBannerAdManager else { return }
        adManager.append(.adClosed)
    }
    
    func didClick(_ ad: MAAd) {
        guard let adManager else { return }
        adManager.append(.adClicked)
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        guard let adManager else { return }
        adManager.append(.adDidFailToDisplay(MaxError.maError(error)))
    }
    
    var adManager: MaxAdManager?
    init(adManager: MaxAdManager? = nil) {
        self.adManager = adManager
    }
}

class MaxAdManager: NSObject, AdManager {
    static func == (lhs: MaxAdManager, rhs: MaxAdManager) -> Bool {
        lhs.adType == rhs.adType && lhs.id == rhs.id
    }
    
    var adType: MaxAdType
    var proxy: ALDelegateProxy
    var adFormat: AdFormat {
        get { self.adType.adFormat }
        set { }
    }
    public var bannerSizes: [BannerSize]? = nil
    public var actualSize: BannerSize? = nil
    public func updateBannerSize(_ size: BannerSize) { actualSize = size }
    var id: UUID = .init()
    var adConfiguration: AdConfiguration!
    var cardConfiguration: CardConfiguration!
    var viewController: UIViewController?
    var adDelegate: (any AdLifeCycleDelegate)?
    var events: PassthroughSubject<AdLifeCycleEvent, Never>
    var lifeCycleEvents: [AdLifeCycleEventHistory] = []
    internal var _adView: AdView?
    public var adView: AdView {
        guard let view = _adView else {
            var wself: (any AdManager)? = self
            _adView = AdsCardManager().card(for: &wself!)
            return _adView!
        }
        return view
    }
    public func cardDidAppear() {}
    
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
    }
    
    func close() {
    }
    
    func killWebview(_ killMode: KillWebviewMode) {
        // n/a
    }
    
    func append(_ event: AdLifeCycleEvent) {
        print("💡 send \(event)")
        events.send(event)
        lifeCycleEvents.append(AdLifeCycleEventHistory(event: event))
    }
    
    func encode() -> AdCardContainer {
        AdCardContainer(name: cardConfiguration.adDisplayName,
                        adType: adType.rawValue,
                        adInformations: .init(adUnitId: adConfiguration.adUnitId,
                                              settings: .init(oguryTestModeEnabled: false,
                                                              rtbTestModeEnabled: false,
                                                              qaLabel: cardConfiguration.qaLabel)))
    }
    
    class func decode(from container: AdCardContainer) throws(AdCardContainerError) -> any AdManager {
        fatalError("Implement in subclasses")
    }
    
    //MARK: Initializer
    public init(adType: MaxAdType,
                adConfiguration: AdConfiguration = .init(adUnitId: ""),
                cardConfiguration: CardConfiguration = .init(),
                viewController: UIViewController?,
                adDelegate: AdLifeCycleDelegate? = nil) {
        events = PassthroughSubject<AdLifeCycleEvent, Never>()
        self.adType = adType
        self.adConfiguration = adConfiguration
        self.adDelegate = adDelegate
        self.cardConfiguration = cardConfiguration
        self.viewController = viewController
        proxy = ALDelegateProxy()
        super.init()
        proxy.adManager = self
    }
}
