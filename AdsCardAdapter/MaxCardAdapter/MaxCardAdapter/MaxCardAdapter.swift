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
    
    func startSdk() {
        
    }
    
    func resetSdk() {
        
    }
    
    func add(logger: any OguryLogger) {
        
    }
    
    
}

