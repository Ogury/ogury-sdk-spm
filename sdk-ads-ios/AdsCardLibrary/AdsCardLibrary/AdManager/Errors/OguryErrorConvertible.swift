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

extension OguryAdErrorCode: OguryErrorConvertible {
    var readableError: String? {
        switch self {
            case .adDisabledOtherReason: return "Ad is disabled"
            case .adDisabledConsentMissing: return "Ad is disabled (Missing consent)"
            case .adDisabledConsentDenied: return "Ad is disabled (consent denied)"
            case .adDisabledUnopenedCountry: return "Ad is disabled (unopened country)"
            case .invalidConfiguration: return "Profig is not Synced"
            case .adExpired: return "Ad is expired"
            case .adParsingFailed: return "Ad parsing failed"
            case .adPrecachingFailed: return "Ad precaching failed"
            case .adPrecachingTimeout: return "Ad precaching timed out"
            case .noInternetConnection: return "No internet connection"
            case .adRequestFailed: return "Ad request failed"
            case .sdkNotInitialized: return "SDK was not initialized"
            case .sdkNotProperlyInitialized: return "SDK was not properly initialized"
            case .anotherAdIsAlreadyDisplayed: return "Another ad is already being display"
            case .noFill: return "Ad is not available"
            case .noAdLoaded: return "Ad is not loaded"
            case .viewControllerPreventsAdFromBeingDisplayed: return "We were unable to show the ad in the current presenting view controller"
            case .viewInBackground: return "Try to present an ad while app is in background"
            case .webviewTerminatedBySystem: return "iOS killed the webview due to memory pressure"
            case .headerBidding: return "OgurySDK can't generate HB token"
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
            default: return nil
        }
    }
}
