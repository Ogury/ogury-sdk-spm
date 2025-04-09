//
//  OguryCardAdapter.swift
//  OguryCardAdapter
//
//  Created by Jerome TONNELIER on 08/04/2025.
//

import UIKit
import AdsCardAdapter
import AdsCardLibrary

public enum OguryEnvironement {
    case devc, staging, prod
}

public struct OguryAdsCardAdapter: AdsCardAdaptable {
    private let environment: OguryEnvironement
    static var configuration: Configuration!
    public init(assetKey: String, environment: OguryEnvironement) {
        self.environment = environment
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
    
    public func startSdk() {
        
    }
}
