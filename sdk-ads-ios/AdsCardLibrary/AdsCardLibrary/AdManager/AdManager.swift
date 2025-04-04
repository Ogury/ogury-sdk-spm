//
//  AdManager.swift
//  AdsCardLibrary
//
//  Created by Jerome TONNELIER on 01/04/2025.
//

import SwiftUI
import Combine
import WebKit

public enum AdFormat {
    case interstitial, rewardedVideo, smallBanner, mrec, thumbnail
    public var name: String {
        switch self {
            case .interstitial: return "Interstitial"
            case .rewardedVideo: return "Rewarded"
            case .thumbnail: return "Thumbnail"
            case .smallBanner: return "Small banner"
            case .mrec: return "MREC"
        }
    }
    public var isBanner: Bool {  return [.smallBanner, .mrec].contains(self) }
}

public protocol AdManager: Storable, Equatable, Identifiable where ID == UUID {
    //MARK: properties
    var adFormat: AdFormat { get set }
    var adConfiguration: AdConfiguration! { get set }
    var cardConfiguration: CardConfiguration! { get set }
    var viewController: UIViewController? { get set }
    var adDelegate: AdLifeCycleDelegate? { get set }
    var events: PassthroughSubject<AdLifeCycleEvent, Never> { get }
    var lifeCycleEvents: [AdLifeCycleEventHistory] { get }
    var adView: AdView { get }
    
    //MARK: functions
    func update(_ adConfiguration: AdConfiguration)
    func load()
    func show()
    func close() // used only for banners
    func updateCard(events: [AdOptionsEvent]) // update cardConfiguration through events
    func killWebview(_ killMode: KillWebviewMode)
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
        get { adConfiguration.campaignId }
        set { adConfiguration.campaignId = newValue }
    }
    var creativeId: String? {
        get { adConfiguration.creativeId }
        set { adConfiguration.creativeId = newValue }
    }
    var dspCreativeId: String? {
        get { adConfiguration.dspCreativeId }
        set { adConfiguration.dspCreativeId = newValue }
    }
    var dspRegion: DspRegion? {
        get { adConfiguration.dspRegion }
        set { adConfiguration.dspRegion = newValue }
    }
}

extension AdManager {
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
}

enum AdManagerError: Error {
    case noOptions
    case loadNotCalledBeforeShow
    case noShowForBanner
    case adMarkUpRetrievalFailed(_: String?)
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
