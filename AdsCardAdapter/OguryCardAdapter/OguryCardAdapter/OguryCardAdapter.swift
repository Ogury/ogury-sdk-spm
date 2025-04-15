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
import OMSDK_Ogury

public enum OguryEnvironement {
    case devc, staging, prod
}

public struct OguryAdsCardAdapter: AdsCardAdaptable {
    public var sdkVersions: [String : String] {
        let coreSdkVersion = String(describing: OGCInternal.shared().getVersion())
        let ogurySdkVersion = "5.0.2"
        let origin = Bundle.main.object(forInfoDictionaryKey: "SDK_SOURCE") as? String ?? "Dev"
        let adsSdkVersion = "\(String(describing: OGAInternal.shared().getVersion())) (\(origin == "Pod" ? "Release" : "Development"))"
        let omid = OMIDOgurySDK.versionString()
        return [
            "Ogury Sdk" : ogurySdkVersion,
            "Module Ads" : adsSdkVersion,
            "Module Core" : coreSdkVersion,
            "OM SDK Version" : omid
        ]
    }
    
    public let assetKey: String
    public var showResetSdkButton: Bool { true }
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
                                        AdType.banner,
                                        AdType.mpu,
                                        AdType.thumbnail]),
        .init(title: "MAX Header Bidding", formats: [AdType.maxHeaderBidding(.interstitial),
                                                     AdType.maxHeaderBidding(.rewarded),
                                                     AdType.maxHeaderBidding(.banner),
                                                     AdType.maxHeaderBidding(.mpu)]),
        .init(title: "DT Fair Bid Header Bidding", formats: [AdType.dtFairBidHeaderBidding(.interstitial),
                                                             AdType.dtFairBidHeaderBidding(.rewarded),
                                                             AdType.dtFairBidHeaderBidding(.banner),
                                                             AdType.dtFairBidHeaderBidding(.mpu)]),
        .init(title: "Unity LevelPlay Header Bidding", formats: [AdType.unityLevelPlayHeaderBidding(.interstitial),
                                                                 AdType.unityLevelPlayHeaderBidding(.rewarded),
                                                                 AdType.unityLevelPlayHeaderBidding(.banner),
                                                                 AdType.unityLevelPlayHeaderBidding(.mpu)]),
    ]
    
    public func adManager(for adFormat: any AdAdapterFormat,
                   options: AdViewOptions,
                   viewController: UIViewController?,
                   adDelegate: AdLifeCycleDelegate?) throws(AdsCardAdapterError) -> any AdManager {
        guard let adType = adFormat as? AdType else {
            throw .noSuitableAdapterAvailable
        }
        var adManager = adType.adManager(viewController: viewController, adDelegate: adDelegate)
        adManager.adConfiguration = options.adConfiguration
        adManager.cardConfiguration = options.cardConfiguration
        return adManager
    }
    
    public func adAdapterFormat(fromRawValue rawValue: Int) throws(AdsCardAdapterError) -> any AdAdapterFormat {
        guard let adType = AdType(rawValue: rawValue) else {
            throw .noSuitableAdapterAvailable
        }
        return adType
    }
    
    public func startSdk() {
        OGAInternal.shared().start(with: assetKey) { _, _ in }
    }
    
    public func forceAdsEnvironment(_ env: String) {
        OGAInternal.shared().perform(NSSelectorFromString("changeServerEnvironment:"), with: env)
    }
    
    public func resetSdk() {
        OGAInternal.shared().perform(NSSelectorFromString("resetAdConfiguration"))
    }
}
