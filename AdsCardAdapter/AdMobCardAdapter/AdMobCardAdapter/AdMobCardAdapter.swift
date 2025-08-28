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
import AppTrackingTransparency

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
            case let .showDebugger(viewController):
                MobileAds.shared.presentAdInspector(from: viewController) { error in
                    print(error)
                }
        }
    }
    
    case showDebugger(_: UIViewController)
}

public struct AdMobAdsCardAdapter: AdsCardAdaptable {
    public var currentBundle: Bundle { Bundle(for: AdMobDelegateProxy.self) ?? .main }
    public init(debugViewController: UIViewController) {
        actions = [AdMobAction.showDebugger(debugViewController)]
    }
    public var availableAdFormats: [AdAdapterFormatSection] = [
        .init(title: "Google Ad Mob", formats: [
            AdMobAdType.default(.interstitial),
            AdMobAdType.default(.rewardedVideo),
            AdMobAdType.default(.standardBanner),
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
    
    public func adAdapterFormat(fromRawValue rawValue: Int,
                                fileVersion: FileVersion = .preVersion) throws(AdsCardAdapterError) -> any AdAdapterFormat {
        guard let adType = AdMobAdType(rawValue: rawValue, fileVersion: fileVersion) else {
            throw .noSuitableAdapterAvailable
        }
        return adType
    }
    
    public func adManager(from container: AdCardContainer,
                          viewController: UIViewController?,
                          adDelegate: AdLifeCycleDelegate?) throws(AdsCardAdapterError) -> any AdManager {
        guard let adFormat: AdMobAdType = try adAdapterFormat(fromRawValue: container.adType, fileVersion: container.version) as? AdMobAdType else {
            throw .noSuitableAdapterAvailable
        }
        do {
            switch adFormat {
                case .default(.interstitial):
                    var manager = try AdMobInterstitialManager.decode(from: container)
                    manager.adDelegate = adDelegate
                    manager.viewController = viewController
                    return manager
                    
                case .default(.rewardedVideo):
                    var manager = try AdMobRewardedManager.decode(from: container)
                    manager.adDelegate = adDelegate
                    manager.viewController = viewController
                    return manager
                    
                case .default(.standardBanner):
                    var manager = try AdMobBannerManager.decode(from: container)
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
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [ "dfa33b6637ac35b47c94d295970c272c" ]
        let res = await MobileAds.shared.start()
        Ogury.setLogLevel(.all)
        print(res.adapterStatusesByClassName)
    }
    
    public func resetSdk() {
        
    }
    
    public func setLogLevel(_ level: OguryLogLevel) {
        Ogury.setLogLevel(level)
    }
    
    public func add(logger: any OguryLogger) {
        OGAInternal.shared().add(logger)
    }
}

