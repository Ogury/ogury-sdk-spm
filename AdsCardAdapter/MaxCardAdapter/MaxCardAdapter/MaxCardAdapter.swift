//
//  MaxCardAdapter.swift
//  MaxCardAdapter
//
//  Created by Jerome TONNELIER on 17/04/2025.
//

import AdsCardAdapter
import AdsCardLibrary
import OguryCore
import UIKit
import AppLovinSDK

struct MaxAdsCardAdapter: AdsCardAdaptable {
    var assetKey: String
    var options: AdapterOptions
    var availableAdFormats: [AdAdapterFormatSection] = [
        .init(title: "AppLovin Max",
              formats: [
                MaxAdType.default(.interstitial),
                MaxAdType.default(.rewardedVideo),
                MaxAdType.default(.smallBanner),
                MaxAdType.default(.mrec)
                       ])
    ]
    var sdkVersions: [String : String] = [:]
    
    func adManager(for adFormat: any AdAdapterFormat, options: AdViewOptions, viewController: UIViewController?, adDelegate: (any AdLifeCycleDelegate)?) throws(AdsCardAdapterError) -> any AdManager {
        throw .noSuitableAdapterAvailable
    }
    
    func adAdapterFormat(fromRawValue rawValue: Int) throws(AdsCardAdapterError) -> any AdAdapterFormat {
        throw .noSuitableAdapterAvailable
    }
    
    func startSdk() async {
        let config = ALSdkInitializationConfiguration(sdkKey: "") { builder in
            builder.mediationProvider = ALMediationProviderMAX
        }
        let sdkConfig = await ALSdk.shared().initialize(with: config)
    }
    
    func resetSdk() {
        
    }
    
    func add(logger: any OguryLogger) {
        
    }
    
    
}

