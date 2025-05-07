//
//  UnityLevelPlayCardAdapter.swift
//  UnityLevelPlayCardAdapter
//
//  Created by Jerome TONNELIER on 06/05/2025.
//
import AdsCardAdapter
import AdsCardLibrary
import OguryAds.Private
import UIKit
import SwiftUI
import IronSource
import OMSDK_Ogury
import OgurySdk

internal enum Action: AdsCardAdapterAction {
    var name: String {
        switch self {
            case .showDebugger: return "ULP Test Suite"
        }
    }
    
    var icon: Image? {
        switch self {
            case .showDebugger: return Image(systemName: "bubbles.and.sparkles")
        }
    }
    
    func perform()  {
        switch self {
            case let .showDebugger(viewController): IronSource.launchTestSuite(viewController)
        }
    }
    
    case showDebugger(_: UIViewController)
}

struct UnityLevelPlayAdsCardAdapter: AdsCardAdaptable {
    public init(testSuiteViewController: UIViewController) {
        actions = [Action.showDebugger(testSuiteViewController)]
    }
    
    var availableAdFormats: [AdAdapterFormatSection] = [
        .init(title: "Header Bidding", formats: [
            AdType.headerBidding(.interstitial),
            AdType.headerBidding(.rewardedVideo),
            AdType.headerBidding(.smallBanner),
            AdType.headerBidding(.mrec),
        ]),
        .init(title: "Waterfall", formats: [
            AdType.waterfall(.interstitial),
            AdType.waterfall(.rewardedVideo),
            AdType.waterfall(.smallBanner),
            AdType.waterfall(.mrec),
        ]),
    ]
    
    var sdkVersions: String {
        let coreSdkVersion = String(describing: OGCInternal.shared().getVersion())
        let ulpSdkVersion = IronSource.sdkVersion()
        let ogurySdkVersion = Ogury.sdkVersion()
        let origin = Bundle.main.object(forInfoDictionaryKey: "SDK_SOURCE") as? String ?? "Dev"
        let adsSdkVersion = "\(String(describing: OGAInternal.shared().getVersion())) (\(origin == "Pod" ? "Release" : "Development"))"
        let omid = OMIDOgurySDK.versionString()
        return
"""
UnityLevelPlay SDK : \(ulpSdkVersion)
Ogury Sdk : \(ogurySdkVersion)
Module Ads : \(adsSdkVersion)
Module Core : \(coreSdkVersion)
OM SDK Version : \(omid)
"""
    }
    
    var actions: [any AdsCardAdapterAction] = []
    
    func adManager(for adFormat: any AdAdapterFormat,
                   options: AdViewOptions,
                   viewController: UIViewController?,
                   adDelegate: (any AdLifeCycleDelegate)?) throws(AdsCardAdapterError) -> any AdManager {
        guard let adType = adFormat as? AdType else {
            throw .noSuitableAdapterAvailable
        }
        let adManager = try adType.adManager(viewController: viewController, adDelegate: adDelegate)
        adManager.adConfiguration = AdConfiguration.init(adUnitId: adType.adUnit)
        adManager.cardConfiguration = options.cardConfiguration
        adManager.cardConfiguration.oguryTestModeEnabled = false
        adManager.cardConfiguration.rtbTestModeEnabled = false
        adManager.cardConfiguration.showRtbTestMode = false
        return adManager
    }
    
    func adAdapterFormat(fromRawValue rawValue: Int) throws(AdsCardAdapterError) -> any AdAdapterFormat {
        guard let adFormat = AdType(rawValue: rawValue) else { throw .noSuitableAdapterAvailable }
        return adFormat
    }
    
    func startSdk() async {
        // Create a request builder with app key and ad formats. Add User ID if available
        let requestBuilder = LPMInitRequestBuilder(appKey: "21f32a64d")
            .withLegacyAdFormats([IS_INTERSTITIAL, IS_BANNER, IS_REWARDED_VIDEO])
        // Build the initial request
        let initRequest = requestBuilder.build()
        // Initialize LevelPlay with the prepared request
        IronSource.setMetaDataWithKey("is_test_suite", value: "enabled")
        let res = try? await LevelPlay.initWith(initRequest)
    }
    
    func resetSdk() {
        
    }
    
    func add(logger: any OguryLogger) {
        OGAInternal.shared().add(logger)
    }
}
