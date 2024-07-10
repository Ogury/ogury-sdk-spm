//
//  OguryErrorConvertible.swift
//  AdCard
//
//  Created by Jerome TONNELIER on 31/08/2023.
//

import Foundation
import OguryAds
import OguryCore

protocol OguryErrorConvertible {
    var readableError: String? { get }
}

extension OguryAdsError: OguryErrorConvertible {
    var readableError: String? {
        switch self {
            case .adDisabledError: return "Ad is disabled"
            case .profigNotSyncedError: return "Profig is not Synced"
            case .adExpiredError: return "Ad is expired"
            case .sdkInitNotCalledError: return "SDK was not initialized"
            case .anotherAdAlreadyDisplayedError: return "Another ad is already being display"
            case .assetKeyNotValidError: return "Asset Key is not valid"
            case .notAvailableError: return "Ad is not available"
            case .notLoadedError: return "Ad is not loaded"
            case .cantShowAdsInPresentingViewControllerError: return "We were unable to show the ad in the current presenting view controller"
            case .unknownError: return "Unknown error"
//            case .webViewKilledError: return "Ad's webview was killed by iOS'"
            case .webViewKilledError: return "iOS killed the webview due to memory pressure"
            @unknown default: return nil
        }
    }
}

extension AdManagerError: OguryErrorConvertible {
    var readableError: String? {
        switch self {
            case .noOptions: return "No options was fed to the adManager"
            case .loadNotCalledBeforeShow: return "Show was called before load"
            case .noShowForBanner: return "Show does not work on banners"
            case let .adMarkUpRetrievalFailed(error): return error == nil ? "AdMarkUp retrieval failed" : "AdMarkUp retrieval failed\n\(error!)"
        }
    }
}

extension OguryError: OguryErrorConvertible {
    var readableError: String? {
        switch code {
            case OguryCoreErrorType.noInternetConnection.rawValue: return "No internet connection"
            case OguryAdsError.adDisabledError.rawValue: return "Ad is disabled"
            case OguryAdsError.profigNotSyncedError.rawValue: return "Profig is not Synced"
            case OguryAdsError.adExpiredError.rawValue: return "Ad is expired"
            case OguryAdsError.sdkInitNotCalledError.rawValue: return "SDK was not initialized"
            case OguryAdsError.anotherAdAlreadyDisplayedError.rawValue: return "Another ad is already being display"
            case OguryAdsError.assetKeyNotValidError.rawValue: return "Asset Key is not valid"
            case OguryAdsError.notAvailableError.rawValue: return "Ad is not available"
            case OguryAdsError.notLoadedError.rawValue: return "Ad is not loaded"
            case OguryAdsError.cantShowAdsInPresentingViewControllerError.rawValue: return "We were unable to show the ad in the current presenting view controller"
            case OguryAdsError.unknownError.rawValue: return "Unknown error"
            case OguryAdsError.webViewKilledError.rawValue: return "Ad's webview was killed by iOS'"
            default: return nil
        }
    }
}
