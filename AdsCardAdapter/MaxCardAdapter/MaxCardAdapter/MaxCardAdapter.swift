//
//  MaxCardAdapter.swift
//  MaxCardAdapter
//
//  Created by Jerome TONNELIER on 17/04/2025.
//

import AdsCardAdapter
import AdsCardLibrary
import OguryCore
import OgurySdk
import OMSDK_Ogury
import OguryAds.Private
import UIKit
import AppLovinSDK

public struct MaxAdsCardAdapter: AdsCardAdaptable {
    public var options: AdapterOptions = .init(showResetSdkButton: false, showLogs: true)
    public var availableAdFormats: [AdAdapterFormatSection] = [
        .init(title: "AppLovin Max",
              formats: [
                MaxAdType.default(.interstitial),
                MaxAdType.default(.rewardedVideo),
                MaxAdType.default(.smallBanner),
                MaxAdType.default(.mrec)
                       ])
    ]
    public var sdkVersions: [String : String] = {
        let coreSdkVersion = String(describing: OGCInternal.shared().getVersion())
        let appLovinSdkVersion = ALSdk.version()
        let ogurySdkVersion = Ogury.sdkVersion()
        let origin = Bundle.main.object(forInfoDictionaryKey: "SDK_SOURCE") as? String ?? "Dev"
        let adsSdkVersion = "\(String(describing: OGAInternal.shared().getVersion())) (\(origin == "Pod" ? "Release" : "Development"))"
        let omid = OMIDOgurySDK.versionString()
        return [
            "AppLovin SDK" : appLovinSdkVersion,
            "Ogury Sdk" : ogurySdkVersion,
            "Module Ads" : adsSdkVersion,
            "Module Core" : coreSdkVersion,
            "OM SDK Version" : omid
        ]
    }()
    public init() {
        
    }
    
    public func adManager(for adFormat: any AdAdapterFormat, options: AdViewOptions, viewController: UIViewController?, adDelegate: (any AdLifeCycleDelegate)?) throws(AdsCardAdapterError) -> any AdManager {
        throw .noSuitableAdapterAvailable
    }
    
    public func adAdapterFormat(fromRawValue rawValue: Int) throws(AdsCardAdapterError) -> any AdAdapterFormat {
        throw .noSuitableAdapterAvailable
    }
    
    public func startSdk() async {
//        let config = ALSdkInitializationConfiguration(sdkKey: "") { builder in
//            builder.mediationProvider = ALMediationProviderMAX
//        }
//        _ = await ALSdk.shared().initialize(with: config)
    }
    
    public func resetSdk() {
        
    }
    
    public func add(logger: any OguryLogger) {
        
    }
    
    
}

