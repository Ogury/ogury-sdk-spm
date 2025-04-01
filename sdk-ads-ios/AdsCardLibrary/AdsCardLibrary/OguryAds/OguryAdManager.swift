//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import OguryAds
import WebKit

/// All objects that should have an ad manager basic bahavior should implement this protocol
public protocol OguryAdManager: Storable, Equatable, Identifiable where ID == UUID {
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
    init(adType: AdType<Self>, adDelegate: AdLifeCycleDelegate?)
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

extension OguryAdManager {
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
    case showSpecificOptions(_: Bool)
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
    case bannerReady(_: OguryBannerAdView)
    case rewardReady(_: OguryReward)
}

public struct AdLifeCycleEventHistory {
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
