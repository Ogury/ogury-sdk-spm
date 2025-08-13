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
import SwiftUI
import AppLovinSDK

internal enum MaxAction: AdsCardAdapterAction {
    var name: String {
        switch self {
            case .showDebugger: return "AppLovin Debugger"
        }
    }
    
    var icon: Image? {
        switch self {
            case .showDebugger: return Image(systemName: "bubbles.and.sparkles")
        }
    }
    
    func perform()  {
        switch self {
            case .showDebugger: ALSdk.shared().showMediationDebugger()
        }
    }
    
    case showDebugger
}

public struct MaxAdsCardAdapter: AdsCardAdaptable {
    public var availableAdFormats: [AdAdapterFormatSection] = [
        .init(title: "AppLovin Max",
              formats: [
                MaxAdType.default(.interstitial),
                MaxAdType.default(.rewardedVideo),
                MaxAdType.default(.standardBanner)
                       ])
    ]
    public var actions: [AdsCardAdapterAction] = [MaxAction.showDebugger]
    public var sdkVersions: String = {
        let coreSdkVersion = String(describing: OGCInternal.shared().getVersion())
        let appLovinSdkVersion = ALSdk.version()
        let ogurySdkVersion = Ogury.sdkVersion()
        let origin = Bundle.main.object(forInfoDictionaryKey: "SDK_SOURCE") as? String ?? "Dev"
        let adsSdkVersion = "\(String(describing: OGAInternal.shared().getVersion())) (\(origin == "Pod" ? "Release" : "Development"))"
        let omid = OMIDOgurySDK.versionString()
        return
"""
AppLovin SDK : \(appLovinSdkVersion)
Ogury Sdk : \(ogurySdkVersion)
Module Ads : \(adsSdkVersion)
Module Core : \(coreSdkVersion)
OM SDK Version : \(omid)
"""
    }()
    public init() {
        
    }
    
    public func adManager(for adFormat: any AdAdapterFormat,
                          options: AdViewOptions,
                          viewController: UIViewController?,
                          adDelegate: (any AdLifeCycleDelegate)?) throws(AdsCardAdapterError) -> any AdManager {
        guard let maxFormat = adFormat as? MaxAdType else { throw .noSuitableAdapterAvailable }
        let adManager = maxFormat.adManager(viewController: viewController, adDelegate: adDelegate)
        adManager.adConfiguration = AdConfiguration.init(adUnitId: maxFormat.adUnit)
        adManager.cardConfiguration = options.cardConfiguration
        adManager.cardConfiguration.oguryTestModeEnabled = false
        adManager.cardConfiguration.rtbTestModeEnabled = false
        adManager.cardConfiguration.showRtbTestMode = false
        return adManager
    }
    
    public func adAdapterFormat(fromRawValue rawValue: Int,
                                fileVersion: FileVersion = .preVersion) throws(AdsCardAdapterError) -> any AdAdapterFormat {
        guard let adType = MaxAdType(rawValue: rawValue, fileVersion: fileVersion) else {
            throw .noSuitableAdapterAvailable
        }
        return adType
    }
    
    public func adManager(from container: AdCardContainer,
                          viewController: UIViewController?,
                          adDelegate: AdLifeCycleDelegate?) throws(AdsCardAdapterError) -> any AdManager {
        guard let adFormat: MaxAdType = try adAdapterFormat(fromRawValue: container.adType, fileVersion: container.version) as? MaxAdType else {
            throw .noSuitableAdapterAvailable
        }
        do {
            switch adFormat {
                case .default(.interstitial):
                    var manager = try MaxInterstitialAdManager.decode(from: container)
                    manager.adDelegate = adDelegate
                    manager.viewController = viewController
                    return manager
                    
                case .default(.rewardedVideo):
                    var manager = try MaxRewardedAdManager.decode(from: container)
                    manager.adDelegate = adDelegate
                    manager.viewController = viewController
                    return manager
                    
                case .default(.standardBanner):
                    var manager = try MaxBannerAdManager.decode(from: container)
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
        let config = ALSdkInitializationConfiguration(sdkKey: "1gPFBPN3E3HoZdhU--XVvMEd3BHrxK9ID3dCmpTcpmmpPOvHsc3-u6Q5yPXrTf8pVcsnPMtH8nQ1PbAfPVgpT2") { builder in
            builder.mediationProvider = ALMediationProviderMAX
        }
        ALSdk.shared().settings.isVerboseLoggingEnabled = true
        _ = await ALSdk.shared().initialize(with: config)
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

