//
//  AdMobCardAdapter.swift
//  AdMobCardAdapter
//
//  Created by Jerome TONNELIER on 28/04/2025.
//

import AdsCardAdapter
import AdsCardLibrary
import OguryAds.Private
import OguryCore
import OguryAds
import OgurySdk
import OMSDK_Ogury
import UIKit
import SwiftUI
import GoogleMobileAds
import AdSupport

internal enum AdMobAction: AdsCardAdapterAction {
    var name: String {
        switch self {
            case .showDebugger: return "Ad Inspector"
        }
    }
    
    var icon: Image? {
        switch self {
            case .showDebugger: return Image(systemName: "bubbles.and.sparkles")
        }
    }
    
    func perform()  {
        switch self {
            case let .showDebugger(viewController): MobileAds.shared.presentAdInspector(from: viewController)
        }
    }
    
    case showDebugger(_: UIViewController)
}

public struct AdMobAdsCardAdapter: AdsCardAdaptable {
    public init(debugViewController: UIViewController) {
        actions = [AdMobAction.showDebugger(debugViewController)]
    }
    public var availableAdFormats: [AdAdapterFormatSection] = [
        .init(title: "Google Ad Mob", formats: [
            AdMobAdType.default(.interstitial),
            AdMobAdType.default(.rewardedVideo),
            AdMobAdType.default(.smallBanner),
            AdMobAdType.default(.mrec),
        ])
    ]
    
    public var sdkVersions: String {
        let coreSdkVersion = String(describing: OGCInternal.shared().getVersion())
        let adMobSdkVersion = string(for: MobileAds.shared.versionNumber)
        let ogurySdkVersion = Ogury.sdkVersion()
        let origin = Bundle.main.object(forInfoDictionaryKey: "SDK_SOURCE") as? String ?? "Dev"
        let adsSdkVersion = "\(String(describing: OGAInternal.shared().getVersion())) (\(origin == "Pod" ? "Release" : "Development"))"
        let omid = OMIDOgurySDK.versionString()
        return
"""
AdMob SDK : \(adMobSdkVersion)
Ogury Sdk : \(ogurySdkVersion)
Module Ads : \(adsSdkVersion)
Module Core : \(coreSdkVersion)
OM SDK Version : \(omid)
"""
    }
    
    public var actions: [any AdsCardAdapterAction]
    
    public func adManager(for adFormat: any AdAdapterFormat,
                   options: AdViewOptions,
                   viewController: UIViewController?,
                   adDelegate: (any AdLifeCycleDelegate)?) throws(AdsCardAdapterError) -> any AdManager {
        guard let adMobType = adFormat as? AdMobAdType else { throw .noSuitableAdapterAvailable }
        let adManager = adMobType.adManager(viewController: viewController, adDelegate: adDelegate)
        adManager.adConfiguration = AdConfiguration.init(adUnitId: adMobType.adUnit)
        adManager.cardConfiguration = options.cardConfiguration
        adManager.cardConfiguration.oguryTestModeEnabled = false
        adManager.cardConfiguration.rtbTestModeEnabled = false
        adManager.cardConfiguration.showRtbTestMode = false
        return adManager
    }
    
    public func adAdapterFormat(fromRawValue rawValue: Int) throws(AdsCardAdapterError) -> any AdAdapterFormat {
        guard let adFormat = AdMobAdType(rawValue: rawValue) else { throw .noSuitableAdapterAvailable }
        return adFormat
    }
    
    public func startSdk() async {
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [ ASIdentifierManager().advertisingIdentifier.uuidString ]
        let res = await MobileAds.shared.start()
        print(res.adapterStatusesByClassName)
    }
    
    public func resetSdk() {
        
    }
    
    public func add(logger: any OguryLogger) {
        OGAInternal.shared().add(logger)
    }
}

