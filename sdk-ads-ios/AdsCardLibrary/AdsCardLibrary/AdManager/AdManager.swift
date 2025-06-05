//
//  AdManager.swift
//  AdsCardLibrary
//
//  Created by Jerome TONNELIER on 01/04/2025.
//

import SwiftUI
import Combine
import WebKit

public enum AdFormat: Codable {
    case interstitial, rewardedVideo, standardBanner, thumbnail
    public var name: String {
        switch self {
            case .interstitial: return "Interstitial"
            case .rewardedVideo: return "Rewarded"
            case .thumbnail: return "Thumbnail"
            case .standardBanner: return "Standard banner"
        }
    }
}

public protocol AdManager: Equatable, Hashable, Identifiable where ID == UUID {
    //MARK: properties
    var adFormat: AdFormat { get set }
    var bannerSizes: [BannerSize]? { get }
    var actualSize: BannerSize? { get  }
    var id: UUID { get }
    var adConfiguration: AdConfiguration! { get set }
    var cardConfiguration: CardConfiguration! { get set }
    var viewController: UIViewController? { get set }
    var adDelegate: AdLifeCycleDelegate? { get set }
    var events: PassthroughSubject<AdLifeCycleEvent, Never> { get }
    var lifeCycleEvents: [AdLifeCycleEventHistory] { get }
    var adView: AdView { get }
    
    //MARK: functions
    func cardDidAppear()
    func update(_ adConfiguration: AdConfiguration)
    func updateBannerSize(_: BannerSize)
    func load() async
    func show()
    func close() // used only for banners
    func updateCard(events: [AdOptionsEvent]) // update cardConfiguration through events
    func killWebview(_ killMode: KillWebviewMode)
    func append(_ event: AdLifeCycleEvent)
    func encode() -> AdCardContainer
    static func decode(from container: AdCardContainer) throws(AdCardContainerError) -> any AdManager
}


@dynamicMemberLookup
open class BannerSize: Identifiable, Equatable, Hashable {
    public let id = UUID()
    var size: CGSize
    let image: Image
    var description: String { "\(Int(size.width)) x \(Int(size.height))" }
    public init(size: CGSize, image: Image) {
        self.size = size
        self.image = image
    }
    
    subscript (dynamicMember keyPath: WritableKeyPath<CGSize, CGFloat>) -> CGFloat {
        get { size[keyPath: keyPath] }
        set { size[keyPath: keyPath] = newValue }
    }
    
    public static func == (lhs: BannerSize, rhs: BannerSize) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public enum AdCardContainerError: Error {
    case invalidAdType
}

public struct AdCardContainer: Codable {
    public struct AdInformationsContainer: Codable {
        public let adUnitId: String
        public let campaignId: String?
        public let creativeId: String?
        public let dspCreativeId: String?
        public let dspRegion: DspRegion?
        public let settings: CardSettings
        public init(adUnitId: String,
                    campaignId: String? = nil,
                    creativeId: String? = nil,
                    dspCreativeId: String? = nil,
                    dspRegion: DspRegion? = nil,
                    settings: CardSettings) {
            self.adUnitId = adUnitId
            self.campaignId = campaignId
            self.creativeId = creativeId
            self.dspCreativeId = dspCreativeId
            self.dspRegion = dspRegion
            self.settings = settings
        }
    }
    public struct CardSettings: Codable {
        public let oguryTestModeEnabled: Bool
        public let rtbTestModeEnabled: Bool
        public let qaLabel: String
        public init(oguryTestModeEnabled: Bool, rtbTestModeEnabled: Bool, qaLabel: String) {
            self.oguryTestModeEnabled = oguryTestModeEnabled
            self.rtbTestModeEnabled = rtbTestModeEnabled
            self.qaLabel = qaLabel
        }
    }
    public let name: String
    public let adType: Int
    public let adInformations: AdInformationsContainer
    public init(name: String, adType: Int, adInformations: AdInformationsContainer) {
        self.name = name
        self.adType = adType
        self.adInformations = adInformations
    }
}

public extension AdManager {
    func updateCard(events: [AdOptionsEvent])  {
        adView.updateCard(events: events)
    }
}

public extension AdManager {
    var cardName: String {
        get { cardConfiguration.adDisplayName }
        set { cardConfiguration.adDisplayName = newValue }
    }
    var qaLabel: String {
        get { cardConfiguration.qaLabel }
        set { cardConfiguration.qaLabel = newValue }
    }
    var adUnitId: String {
        get { adConfiguration.adUnitId }
        set { adConfiguration.adUnitId = newValue }
    }
    var campaignId: String? {
        get {
            (adUnitId.isTestModeOn || !cardConfiguration.showCampaignId) ? nil : adConfiguration.campaignId
        }
        set { adConfiguration.campaignId = newValue }
    }
    var creativeId: String? {
        get {
            (adUnitId.isTestModeOn || !cardConfiguration.showCreativeId) ? nil : adConfiguration.creativeId
        }
        set { adConfiguration.creativeId = newValue }
    }
    var dspCreativeId: String? {
        get {
            (adUnitId.isTestModeOn || !cardConfiguration.showDspFields) ? nil : adConfiguration.dspCreativeId
        }
        set { adConfiguration.dspCreativeId = newValue }
    }
    var dspRegion: DspRegion? {
        get {
            (adUnitId.isTestModeOn || !cardConfiguration.showDspFields) ? nil : adConfiguration.dspRegion
        }
        set { adConfiguration.dspRegion = newValue }
    }
}

public extension AdManager {
    func kill(_ webView: WKWebView) {
        DispatchQueue.main.async {
            Task {
                let crashCommand = "let largeArray = Array(1e9).fill(0);"
                do {
                    let res = try await webView.evaluateJavaScript(crashCommand)
                    print("crash result \(String(describing: res))")
                } catch {
                    print("⚠️ Error while trying to crash webview \(error)")
                }
            }
        }
    }
}

public enum AdOptionsEvent {
    case enableAdUnitEditing(_: Bool)
    case showCampaignId(_: Bool)
    case showCreativeId(_: Bool)
    case showDspFields(_: Bool)
    case enableBulkMode(_: Bool)
    case showTestMode(_: Bool)
    case forceTestMode(_: Bool)
    case enableFeedbacks(_: Bool)
    case updateKillMode(_: KillWebviewMode)
}

public enum AdLifeCycleEvent {
    case adLoading
    // canShow indicates wether the show action can be performed afterwards.
    // False in case of banners/mpu, true otherwise
    case adLoaded(canShow: Bool)
    case adDisplaying
    case adClicked
    case adClosed
    case adDidTriggerImpression
    case adDidFailToLoad(_: Error)
    case adDidFailToDisplay(_: Error)
    case adDidFail(_: Error)
    case bannerReady(_: UIView)
    case rewardReady(name: String, value: String)
}

public struct AdLifeCycleEventHistory: Equatable {
    let event: AdLifeCycleEvent
    let date = Date()
    public init(event: AdLifeCycleEvent) {
        self.event = event
    }
}

public enum AdManagerError: Error {
    case adMarkUpRetrievalFailed(_: String?)
    case viewControllerMissing
}

extension AdLifeCycleEvent: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
            case (.adLoading, .adLoading): return true
            case (.adLoaded, .adLoaded): return true
            case (.adDisplaying, .adDisplaying): return true
            case (.adClicked, .adClicked): return true
            case (.adClosed, .adClosed): return true
            case (.adDidTriggerImpression, .adDidTriggerImpression): return true
            case (let .adDidFailToLoad(lhsError), let .adDidFailToLoad(rhsError)): return areEqual(lhsError, rhsError)
            case (let .adDidFail(lhsError), let .adDidFail(rhsError)): return areEqual(lhsError, rhsError)
            case (let .adDidFailToDisplay(lhsError), let .adDidFailToDisplay(rhsError)): return areEqual(lhsError, rhsError)
            default: return false
        }
    }
}

/**
 This is a equality on any 2 instance of Error.
 */
public func areEqual(_ lhs: Error, _ rhs: Error) -> Bool {
    return lhs.reflectedString == rhs.reflectedString
}

public extension Error {
    var reflectedString: String {
        // NOTE 1: We can just use the standard reflection for our case
        return String(reflecting: self)
    }
    
    // Same typed Equality
    func isEqual(to: Self) -> Bool {
        return self.reflectedString == to.reflectedString
    }
    
}

public extension NSError {
    // prevents scenario where one would cast swift Error to NSError
    // whereby losing the associatedvalue in Obj-C realm.
    // (IntError.unknown as NSError("some")).(IntError.unknown as NSError)
    func isEqual(to: NSError) -> Bool {
        let lhs = self as Error
        let rhs = to as Error
        return self.isEqual(to) && lhs.reflectedString == rhs.reflectedString
    }
}
