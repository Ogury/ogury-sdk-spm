//
//  OguryCardAdapter.swift
//  OguryCardAdapter
//
//  Created by Jerome TONNELIER on 08/04/2025.
//

import UIKit
import AdsCardAdapter
import AdsCardLibrary
import OguryAds.Private
import OguryCore.Private
import OgurySdk
import OMSDK_Ogury

public enum OguryEnvironement {
    case devc, staging, prod
}

public struct OguryAdsCardAdapter: AdsCardAdaptable {
    public var sdkVersions: String {
        let coreSdkVersion = String(describing: OGCInternal.shared().getVersion())
        let ogurySdkVersion = Ogury.sdkVersion()
        let adsSdkVersion = "\(String(describing: OGAInternal.shared().getVersion()))"
        let omid = OMIDOgurySDK.versionString()
        var environment: String { Bundle.main.object(forInfoDictionaryKey: "DefaultEnv") as? String ?? "" }
        return
"""
Ogury Sdk : \(ogurySdkVersion)
Module Ads : \(adsSdkVersion)
Module Core : \(coreSdkVersion)
OM SDK Version : \(omid)
Environment: \(environment)
"""
    }
    public var actions: [AdsCardAdapterAction] = []
    
    public let assetKey: String
    private let environment: OguryEnvironement
    static var configuration: Configuration!
    public init(assetKey: String, environment: OguryEnvironement) {
        self.environment = environment
        self.assetKey = assetKey
        OguryAdsCardAdapter.configuration = .init(from: assetKey, environment: environment)
    }
    
    public var availableAdFormats: [AdAdapterFormatSection] = [
        .init(title: "Ogury", formats: [AdType.interstitial,
                                        AdType.rewarded,
                                        AdType.standardBanner,
                                        AdType.thumbnail]),
        .init(title: "MAX Header Bidding", formats: [AdType.maxHeaderBidding(.interstitial),
                                                     AdType.maxHeaderBidding(.rewarded),
                                                     AdType.maxHeaderBidding(.standardBanner)]),
        .init(title: "DT Fair Bid Header Bidding", formats: [AdType.dtFairBidHeaderBidding(.interstitial),
                                                             AdType.dtFairBidHeaderBidding(.rewarded),
                                                             AdType.dtFairBidHeaderBidding(.standardBanner)]),
        .init(title: "Unity LevelPlay Header Bidding", formats: [AdType.unityLevelPlayHeaderBidding(.interstitial),
                                                                 AdType.unityLevelPlayHeaderBidding(.rewarded),
                                                                 AdType.unityLevelPlayHeaderBidding(.standardBanner)]),
    ]
    
    public func adManager(for adFormat: any AdAdapterFormat,
                   options: AdViewOptions,
                   viewController: UIViewController?,
                   adDelegate: AdLifeCycleDelegate?) throws(AdsCardAdapterError) -> any AdManager {
        guard let adType = adFormat as? AdType else {
            throw .noSuitableAdapterAvailable
        }
        var adManager = adType.adManager(viewController: viewController, adDelegate: adDelegate)
        adManager.adConfiguration = adConfiguration(for: adFormat)
        adManager.cardConfiguration = options.cardConfiguration
        adManager.cardConfiguration.oguryTestModeEnabled = false
        adManager.cardConfiguration.rtbTestModeEnabled = false
        adManager.cardConfiguration.showRtbTestMode = adType.enableRtbTestMode
        return adManager
    }
    
    private func adConfiguration(for format: any AdAdapterFormat) -> AdConfiguration? {
        guard let conf = defaultOptions(for: format) else { return .init(adUnitId: "") }
        return .init(adUnitId: conf.adUnitId,
                     campaignId: conf.campaignId,
                     creativeId: conf.creativeId,
                     dspCreativeId: conf.dspCreativeId,
                     dspRegion: conf.dspRegion)
    }
    private func defaultOptions(for adFormat: any AdAdapterFormat) -> Configuration.DefaultBaseOptions? {
        guard let adType = adFormat as? AdType else { return nil }
        switch adType {
            case .interstitial: return OguryAdsCardAdapter.configuration.options.interstitial
            case .rewarded: return OguryAdsCardAdapter.configuration.options.optIn
            case .thumbnail: return OguryAdsCardAdapter.configuration.options.thumbnail
            case .standardBanner: return OguryAdsCardAdapter.configuration.options.standardBanner
            
            case let .maxHeaderBidding(innerFormat):
                switch innerFormat {
                    case .interstitial: return OguryAdsCardAdapter.configuration.maxOptions.interstitial
                    case .rewarded: return OguryAdsCardAdapter.configuration.maxOptions.optIn
                    case .standardBanner: return OguryAdsCardAdapter.configuration.maxOptions.standardBanner
                    default: return nil
                }
            case let .dtFairBidHeaderBidding(innerFormat):
                switch innerFormat {
                    case .interstitial: return OguryAdsCardAdapter.configuration.dtFairBidOptions.interstitial
                    case .rewarded: return OguryAdsCardAdapter.configuration.dtFairBidOptions.optIn
                    case .standardBanner: return OguryAdsCardAdapter.configuration.dtFairBidOptions.standardBanner
                    default: return nil
                }
            case let .unityLevelPlayHeaderBidding(innerFormat):
                switch innerFormat {
                    case .interstitial: return OguryAdsCardAdapter.configuration.unityLevelPlayOptions.interstitial
                    case .rewarded: return OguryAdsCardAdapter.configuration.unityLevelPlayOptions.optIn
                    case .standardBanner: return OguryAdsCardAdapter.configuration.unityLevelPlayOptions.standardBanner
                    default: return nil
                }
        }
    }
    
    public func adAdapterFormat(fromRawValue rawValue: Int,
                                fileVersion: FileVersion = .preVersion) throws(AdsCardAdapterError) -> any AdAdapterFormat {
        guard let adType = AdType(rawValue: rawValue, fileVersion: fileVersion) else {
            throw .noSuitableAdapterAvailable
        }
        return adType
    }
    
    public func adManager(from container: AdCardContainer,
                          viewController: UIViewController?,
                          adDelegate: AdLifeCycleDelegate?) throws(AdsCardAdapterError) -> any AdManager {
        guard let adFormat: AdType = try adAdapterFormat(fromRawValue: container.adType, fileVersion: container.version) as? AdType else {
            throw .noSuitableAdapterAvailable
        }
        do {
            switch adFormat {
                case .interstitial,
                     .maxHeaderBidding(.interstitial),
                     .dtFairBidHeaderBidding(.interstitial),
                     .unityLevelPlayHeaderBidding(.interstitial):
                    var manager = try InterstitialAdManager.decode(from: container)
                    manager.adDelegate = adDelegate
                    manager.viewController = viewController
                    return manager
                    
                case .rewarded,
                     .maxHeaderBidding(.rewarded),
                     .dtFairBidHeaderBidding(.rewarded),
                     .unityLevelPlayHeaderBidding(.rewarded):
                    var manager = try RewardedAdManager.decode(from: container)
                    manager.adDelegate = adDelegate
                    manager.viewController = viewController
                    return manager
                    
                case .thumbnail:
                    var manager = try ThumbnailAdManager.decode(from: container)
                    manager.adDelegate = adDelegate
                    manager.viewController = viewController
                    return manager
                    
                case .standardBanner,
                     .maxHeaderBidding(.standardBanner),
                     .dtFairBidHeaderBidding(.standardBanner),
                     .unityLevelPlayHeaderBidding(.standardBanner):
                    var manager = try BannerAdManager.decode(from: container)
                    manager.adDelegate = adDelegate
                    manager.viewController = viewController
                    return manager
                    
                default: throw AdsCardAdapterError.noSuitableAdapterAvailable
            }
        } catch {
            throw .noSuitableAdapterAvailable
        }
    }
    
    public func startSdk() async {
        await Ogury.start(with: assetKey)
    }
    
    public func setLogLevel(_ level: OguryLogLevel) {
        Ogury.setLogLevel(level)
    }
    
    public func forceAdsEnvironment(_ env: String) {
        OGAInternal.shared().perform(NSSelectorFromString("changeServerEnvironment:"), with: env)
    }
    
    public func resetSdk() {
        OGAInternal.shared().perform(NSSelectorFromString("resetAdConfiguration"))
    }
    public func add(logger: any OguryLogger) {
        OGAInternal.shared().add(logger)
    }
}
