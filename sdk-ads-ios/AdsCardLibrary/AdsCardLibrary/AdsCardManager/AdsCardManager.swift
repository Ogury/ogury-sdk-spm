//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation
import OguryAds
import OguryCore
import SwiftUI
import OguryCore.Private

public extension String {
    static let testAppLogType: String = "TestApp"
    static let receivedCallbacksLogType: String = "ReceivedCallbacks"
    static let testModeSuffix = "_test"
    var isTestModeOn: Bool { String(suffix(5)) == .testModeSuffix }
}

//MARK: - AdsCardManager
public struct AdsCardManager {
    internal static var logger: OguryLogger?
    
    static func log(_ message: String, origin: String, logType: String = .testAppLogType) {
        AdsCardManager.logger?.logMessage(OGAAdLogMessage(level: .debug,
                                                          logType: OguryLogType(logType),
                                                          origin: origin,
                                                          sdk: .ads,
                                                          messageDate: nil,
                                                          message: message,
                                                          tags: nil))
    }
    
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
    public func adManager<T: OguryAdManager>(for adType: AdType<T>,
                                             options: AdManagerOptions,
                                             viewController: UIViewController?,
                                             adDelegate: AdLifeCycleDelegate?) throws -> T {
        return try adType.adManager(from: options, viewController: viewController, adDelegate: adDelegate)
    }
    
    /// Return a SwiftUI adView Card to handle ad managed inside the `adManager`
    /// - Parameter adManager: the `AdManager` that handle the underlying ad
    /// - Returns: a SwiftUI AdView object that handles all ad lifecycle through its
    public func card(for adManager: inout any AdManager) -> AdView? {
        nil
    }
}

#warning("TO REMOVE")
public enum AdTypeTitle: String {
    case interstitial
    case rewarded
    case thumbnail
    case banner
    case mpu
    
    var display: String {
        switch self {
            case .interstitial: return "Interstitial"
            case .rewarded: return "Rewarded"
            case .thumbnail: return "Thumbnail"
            case .banner: return "Small banner"
            case .mpu: return "MREC"
        }
    }
}

extension AdConfiguration {
    init(options: AdManagerOptions) {
        self.init(adUnitId: options.baseOptions.adUnitId,
                  campaignId: options.baseOptions.campaignId,
                  creativeId: options.baseOptions.creativeId,
                  dspCreativeId: options.baseOptions.dspCreativeId,
                  dspRegion: options.baseOptions.dspRegion)
    }
}

extension CardConfiguration {
    init(options: AdManagerOptions) {
        self.init(enableAdUnitEditing: true,
                  showCampaignId: options.showCampaignId,
                  showCreativeId: options.showCreativeId,
                  showDspFields: options.showDspFields,
                  showKillMode: true,
                  showRtbTestMode: true,
                  adDisplayName: options.baseOptions.adDisplayName,
                  bulkModeEnabled: options.baseOptions.bulkModeEnabled,
                  oguryTestModeEnabled: options.baseOptions.oguryTestModeEnabled,
                  showTestModeButton: true,
                  rtbTestModeEnabled: options.baseOptions.rtbTestModeEnabled,
                  killWebviewMode: options.baseOptions.killWebviewMode,
                  qaLabel: options.baseOptions.qaLabel)
    }
}
