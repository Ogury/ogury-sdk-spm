//
//  PrebidCardAdapter.swift
//  PrebidCardAdapter
//
//  Created by Jerome TONNELIER on 12/06/2025.
//

import UIKit
import AdsCardAdapter
import AdsCardLibrary
import OguryCore.Private
import OguryCore
import PrebidMobile

public enum OguryEnvironement {
    case devc, staging, prod
}

public struct PrebidAdsCardAdapter: AdsCardAdaptable {
    private let environment: OguryEnvironement
    static var configuration: Configuration!
    
    public init(assetKey: String, environment: OguryEnvironement) {
        self.environment = environment
        PrebidAdsCardAdapter.configuration = .init(from: assetKey, environment: environment)
    }
    
    public var availableAdFormats: [AdAdapterFormatSection] = [
        .init(title: "Prebid", formats: [
            PrebidAdType.default(.interstitial),
            PrebidAdType.default(.standardBanner)
        ])
    ]
    public var sdkVersions: String = {
"""
PreBid: \(Prebid.shared.version),
OguryCore: \(OGCInternal.shared().getVersion())
"""
    }()
    
    public var actions: [any AdsCardAdapterAction] = []
    
    public func adManager(for adFormat: any AdAdapterFormat, options: AdViewOptions, viewController: UIViewController?, adDelegate: (any AdLifeCycleDelegate)?) throws(AdsCardAdapterError) -> any AdManager {
        guard let adType = adFormat as? PrebidAdType else {
            throw .noSuitableAdapterAvailable
        }
        let adManager = try adType.adManager(viewController: viewController, adDelegate: adDelegate)
        adManager.adConfiguration = adConfiguration(for: adFormat)
        adManager.cardConfiguration = options.cardConfiguration
        adManager.cardConfiguration.oguryTestModeEnabled = false
        adManager.cardConfiguration.rtbTestModeEnabled = false
        adManager.cardConfiguration.showRtbTestMode = false
        return adManager
    }
    
    private func adConfiguration(for format: any AdAdapterFormat) -> AdsCardLibrary.AdConfiguration? {
        guard let conf = defaultOptions(for: format) else { return .init(adUnitId: "") }
        return .init(adUnitId: conf.adUnitId,
                     campaignId: conf.campaignId,
                     creativeId: conf.creativeId)
    }
    private func defaultOptions(for adFormat: any AdAdapterFormat) -> Configuration.DefaultBaseOptions? {
        guard let adType = adFormat as? PrebidAdType else { return nil }
        switch adType {
            case .default(.interstitial): return PrebidAdsCardAdapter.configuration.options.interstitial
            case .default(.standardBanner): return PrebidAdsCardAdapter.configuration.options.standardBanner
            default: return nil
        }
    }
    
    public func adAdapterFormat(fromRawValue rawValue: Int,
                                fileVersion: FileVersion = .preVersion) throws(AdsCardAdapterError) -> any AdAdapterFormat {
        guard let adType = PrebidAdType(rawValue: rawValue, fileVersion: fileVersion) else {
            throw .noSuitableAdapterAvailable
        }
        return adType
    }
    
    public func adManager(from container: AdCardContainer,
                          viewController: UIViewController?,
                          adDelegate: AdLifeCycleDelegate?) throws(AdsCardAdapterError) -> any AdManager {
        guard let adFormat: PrebidAdType = try adAdapterFormat(fromRawValue: container.adType, fileVersion: container.version) as? PrebidAdType else {
            throw .noSuitableAdapterAvailable
        }
        do {
            switch adFormat {
                case .default(.interstitial):
                    var manager = try PrebidInterstitialAdManager.decode(from: container)
                    manager.adDelegate = adDelegate
                    manager.viewController = viewController
                    return manager
                    
                case .default(.standardBanner):
                    var manager = try PrebidBannerAdManager.decode(from: container)
                    manager.adDelegate = adDelegate
                    manager.viewController = viewController
                    return manager
                    
//                case .default(.rewardedVideo):
//                    return try ULPRewardedAdManager.decode(from: container)
//                    
//                case .default(.standardBanner):
//                    return try ULPBannerAdManager.decode(from: container)
                    
                default: throw AdsCardAdapterError.noSuitableAdapterAvailable
            }
        } catch {
            throw .noSuitableAdapterAvailable
        }
    }
    
    public func startSdk() async {
        Prebid.shared.prebidServerAccountId = "0689a263-318d-448b-a3d4-b02e8a709d9d"
        Targeting.shared.setGlobalORTBConfig("{\"ext\":{\"prebid\":{\"storedrequest\": {\"id\":\"ogury-id-123\"}}}}")
        try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            do {
                try Prebid.initializeSDK(serverURL: PrebidAdsCardAdapter.configuration.url) { status, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if status == .succeeded {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: NSError(
                            domain: "PrebidInitialization",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "SDK initialization failed with unknown error"]
                        ))
                    }
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func resetSdk() {
        // n/a
    }
    
    public func add(logger: any OguryLogger) {
        // n/a
    }
}

