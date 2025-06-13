//
//  PrebidAdManager.swift
//  PrebidCardAdapter
//
//  Created by Jerome TONNELIER on 12/06/2025.
//

import AdsCardLibrary
import AdsCardAdapter
import SwiftUI
import Combine
import PrebidMobile

enum PrebidTag: AdTag {
    case prebid
    
    var displayMode: TagDisplayMode {
        switch self {
            case .prebid: return .fill
        }
    }
    
    var name: String {
        switch self {
            case .prebid: return "Prebid"
        }
    }
    
    var description: String {
        switch self {
            case .prebid: return "Prebid Mobile SDK"
        }
    }
    
    var color: Color {
        switch self {
            case .prebid: return Color(#colorLiteral(red: 0.928065598, green: 0.5704154372, blue: 0.3026409149, alpha: 1))
        }
    }
    
    var textColor: Color {
        switch self {
            case .prebid: return .white
        }
    }
}

enum PrebidAdType: AdAdapterFormat, RawRepresentable, Equatable {
    case `default`(_: AdsCardLibrary.AdFormat)
    
    var adFormat: AdsCardLibrary.AdFormat {
        switch self {
            case let .default(adFormat): return adFormat
        }
    }
    
    var adUnit: String {
        switch self {
            case let .default(adFormat):
                switch adFormat {
                    case .interstitial: return "devc_banner_inter"
                    case .rewardedVideo: return "devc_banner_small"
                    case .standardBanner: return "devc_banner_small"
                    default: fatalError("AdFormat \(adFormat) not supported")
                }
        }
    }
    
    var tags: [any AdTag] {
        [PrebidTag.prebid, OguryAdTag.waterfall]
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
    
    public init?(rawValue: Int) {
        self.init(rawValue: rawValue, fileVersion: .one)
    }
    
    public init?(rawValue: Int, fileVersion: FileVersion) {
        let targetValue = PrebidAdType.migrate(fromRawValue: rawValue, fileVersion: fileVersion)
        switch targetValue {
            case 200: self = .`default`(.interstitial)
            case 201: self = .`default`(.rewardedVideo)
            case 202: self = .`default`(.standardBanner)
            default: return nil
        }
    }
    
    private static func migrate(fromRawValue rawValue: Int, fileVersion: FileVersion) -> Int {
        switch (fileVersion, AdCardContainer.currentVersion) {
            case (.preVersion, .one) where rawValue == 203: return 202
            default: return rawValue
        }
    }
    
    private static let prefix = 200
    var rawValue: Int { PrebidAdType.prefix + self.sortOrder }
    
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
    
    internal func adManager(viewController: UIViewController?, adDelegate: AdLifeCycleDelegate?) throws(AdsCardAdapterError) -> PrebidAdManager  {
        switch self {
            case let .default(innerType):
                switch innerType {
                    case .interstitial: return PrebidInterstitialAdManager(adType: self, viewController: viewController, adDelegate: adDelegate)
//                    case .rewardedVideo: return AdMobRewardedManager(adType: self, viewController: viewController, adDelegate: adDelegate)
//                    case .standardBanner: return AdMobBannerManager(adType: self, viewController: viewController, adDelegate: adDelegate)
                    default: throw .noSuitableAdapterAvailable
                }
        }
    }
}

class PrebidAdManager: NSObject, AdManager {
    var proxy: AdMobDelegateProxy
    var adType: PrebidAdType
    var adFormat: AdsCardLibrary.AdFormat {
        get { adType.adFormat }
        set {}
    }
    public var bannerSizes: [BannerSize]? = nil
    public var actualSize: BannerSize? = nil
    public func updateBannerSize(_ size: BannerSize) { actualSize = size }
    
    var id: UUID = .init()
    var adConfiguration: AdsCardLibrary.AdConfiguration!
    var cardConfiguration: CardConfiguration!
    var viewController: UIViewController?
    var adDelegate: (any AdLifeCycleDelegate)?
    var events: PassthroughSubject<AdLifeCycleEvent, Never> = .init()
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
    
    func update(_ adConfiguration: AdsCardLibrary.AdConfiguration) {
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
        print("💡 send \(event)")
        events.send(event)
        lifeCycleEvents.append(AdLifeCycleEventHistory(event: event))
    }
    
    func encode() -> AdCardContainer {
        AdCardContainer(name: cardConfiguration.adDisplayName,
                        adType: adType.rawValue,
                        adInformations: .init(adUnitId: adConfiguration.adUnitId,
                                              bannerSize: actualSize?.size,
                                              settings: .init(oguryTestModeEnabled: false,
                                                              rtbTestModeEnabled: false,
                                                              qaLabel: cardConfiguration.qaLabel)))
    }
    
    class func decode(from container: AdCardContainer) throws(AdCardContainerError) -> any AdManager {
        fatalError("Should be implemented in subclass")
    }
    
    //MARK: Initializer
    public init(adType: PrebidAdType,
                adConfiguration: AdsCardLibrary.AdConfiguration = .init(adUnitId: ""),
                cardConfiguration: CardConfiguration = .init(),
                viewController: UIViewController?,
                adDelegate: AdLifeCycleDelegate? = nil) {
        events = PassthroughSubject<AdLifeCycleEvent, Never>()
        self.adType = adType
        self.adConfiguration = adConfiguration
        self.cardConfiguration = cardConfiguration
        self.viewController = viewController
        self.adDelegate = adDelegate
        proxy = AdMobDelegateProxy()
        super.init()
        proxy.adManager = self
    }
}

class AdMobDelegateProxy: NSObject, InterstitialAdUnitDelegate {
    var adManager: PrebidAdManager?
    
    func interstitialDidClickAd(_ interstitial: InterstitialRenderingAdUnit) {
        guard let adManager else { return }
        adManager.append(.adClicked)
    }
    func interstitialDidDismissAd(_ interstitial: InterstitialRenderingAdUnit) {
        guard let adManager else { return }
        adManager.append(.adClosed)
    }
    func interstitialDidReceiveAd(_ interstitial: InterstitialRenderingAdUnit) {
        guard let adManager else { return }
        adManager.append(.adLoaded(canShow: true))
    }
    func interstitialWillPresentAd(_ interstitial: InterstitialRenderingAdUnit) {
        guard let adManager else { return }
        adManager.append(.adDisplaying)
    }
    func interstitialWillLeaveApplication(_ interstitial: InterstitialRenderingAdUnit) {
        
    }
    func interstitial(_ interstitial: InterstitialRenderingAdUnit, didFailToReceiveAdWithError error: (any Error)?) {
        guard let adManager else { return }
        if let error {
            adManager.append(.adDidFail(error))
        } else {
            adManager.append(.adDidFail(NSError(domain: "Prebid interstitial failed with unkown error", code: 66, userInfo: nil)))
        }
    }
}

