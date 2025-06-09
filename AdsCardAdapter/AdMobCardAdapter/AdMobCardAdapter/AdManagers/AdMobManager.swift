//
//  AdMobAdManager.swift
//  AdMobCardAdapter
//
//  Created by Jerome TONNELIER on 28/04/2025.
//

import AdsCardLibrary
import AdsCardAdapter
import SwiftUI
import Combine
import GoogleMobileAds

enum AdMobTag: AdTag {
    case adMob
    
    var displayMode: TagDisplayMode {
        switch self {
            case .adMob: return .fill
        }
    }
    
    var name: String {
        switch self {
            case .adMob: return "Google AdMob"
        }
    }
    
    var description: String {
        switch self {
            case .adMob: return "Google AdMob Mediation direct integration"
        }
    }
    
    var color: Color {
        switch self {
            case .adMob: return Color(#colorLiteral(red: 0.9287784696, green: 0.7156555653, blue: 0.2884071469, alpha: 1))
        }
    }
    
    var textColor: Color {
        switch self {
            case .adMob: return .white
        }
    }
}

enum AdMobAdType: AdAdapterFormat, RawRepresentable, Equatable {
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
                    case .interstitial: return "ca-app-pub-5735986212655126/6644649999"
                    case .rewardedVideo: return "ca-app-pub-5735986212655126/9889760434"
                    case .standardBanner: return "ca-app-pub-5735986212655126/6385870948"
                    default: fatalError("AdFormat \(adFormat) not supported")
                }
        }
    }
    
    var tags: [any AdTag] {
        [AdMobTag.adMob, OguryAdTag.waterfall]
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
    
    private static let prefix = 200
    var rawValue: Int { AdMobAdType.prefix + self.sortOrder }
    
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
                            adDelegate: AdLifeCycleDelegate?) -> AdMobManager  {
        switch self {
            case let .default(innerType):
                switch innerType {
                    case .interstitial: return AdMobInterstitialManager(adType: self, viewController: viewController, adDelegate: adDelegate)
                    case .rewardedVideo: return AdMobRewardedManager(adType: self, viewController: viewController, adDelegate: adDelegate)
                    case .standardBanner: return AdMobBannerManager(adType: self, viewController: viewController, adDelegate: adDelegate)
                    default: fatalError()
                }
        }
    }
}

class AdMobManager: NSObject, AdManager {
    var proxy: AdMobDelegateProxy
    var adType: AdMobAdType
    var adFormat: AdsCardLibrary.AdFormat {
        get { adType.adFormat }
        set {}
    }
    public var bannerSizes: [BannerSize]? = nil
    public var actualSize: BannerSize? = nil
    public func updateBannerSize(_ size: BannerSize) { actualSize = size }
    
    var id: UUID = .init()
    var adConfiguration: AdConfiguration!
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
        fatalError("Should be implemented in subclass")
    }
    
    //MARK: Initializer
    public init(adType: AdMobAdType,
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
        proxy = AdMobDelegateProxy()
        super.init()
        proxy.adManager = self
    }
}

class AdMobDelegateProxy: NSObject, FullScreenContentDelegate, BannerViewDelegate {
    var adManager: AdMobManager?
    
    func adDidRecordClick(_ ad: any FullScreenPresentingAd) {
        guard let adManager else { return }
        adManager.append(.adClicked)
        
    }
    func adDidRecordImpression(_ ad: any FullScreenPresentingAd) {
        guard let adManager else { return }
        adManager.append(.adDidTriggerImpression)
        
    }
    func adDidDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {guard let adManager else { return }
        adManager.append(.adClosed)
        
    }
    func adWillDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {
        
    }
    func adWillPresentFullScreenContent(_ ad: any FullScreenPresentingAd) {
        guard let adManager else { return }
        adManager.append(.adDisplaying)
        
    }
    func ad(_ ad: any FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: any Error) {
        guard let adManager else { return }
        adManager.append(.adDidFail(error))
        
    }
    
    /// Banner
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        guard let adManager else { return }
        adManager.append(.bannerReady(bannerView))
    }
    
    func bannerViewDidRecordClick(_ bannerView: BannerView) {
        guard let adManager else { return }
        adManager.append(.adClicked)
    }
    
    func bannerViewDidDismissScreen(_ bannerView: BannerView) {
        guard let adManager else { return }
        adManager.append(.adClosed)
    }
    
    func bannerViewWillDismissScreen(_ bannerView: BannerView) {
        
    }
    
    func bannerViewWillPresentScreen(_ bannerView: BannerView) {
        
    }
    
    func bannerViewDidRecordImpression(_ bannerView: BannerView) {
        guard let adManager else { return }
        adManager.append(.adDidTriggerImpression)
    }
    
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: any Error) {
        guard let adManager else { return }
        adManager.append(.adDidFail(error))
    }
}
