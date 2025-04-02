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

extension AdType {
    var adFormat: AdFormat {
        switch self {
            case .interstitial: return .interstitial
            case .rewarded: return .rewardedVideo
            case .thumbnail: return .thumbnail
            case .banner: return.smallBanner
            case .mpu: return .mrec
            case .maxHeaderBidding(let adType, _): return adType.adFormat
            case .dtFairBidHeaderBidding(let adType, _): return adType.adFormat
            case .unityLevelPlayHeaderBidding(let adType, _): return adType.adFormat
        }
    }
}
