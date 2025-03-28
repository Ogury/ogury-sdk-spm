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

extension OguryAdError: OguryErrorConvertible {
    var readableError: String? {
        switch self.code {
            case OguryShowErrorCode.adDisabledUnspecifiedReason.rawValue: return "Ad is disabled"
            case OguryShowErrorCode.adDisabledConsentMissing.rawValue: return "Ad is disabled (Missing consent)"
            case OguryShowErrorCode.adDisabledConsentDenied.rawValue: return "Ad is disabled (consent denied)"
            case OguryShowErrorCode.adDisabledCountryNotOpened.rawValue: return "Ad is disabled (unopened country)"
            case OguryShowErrorCode.invalidConfiguration.rawValue: return "Profig is not Synced"
            case OguryShowErrorCode.adExpired.rawValue: return "Ad is expired"
            case OguryShowErrorCode.noActiveInternetConnection.rawValue: return "No internet connection"
            case OguryShowErrorCode.sdkNotStarted.rawValue: return "SDK was not initialized"
            case OguryShowErrorCode.sdkNotProperlyInitialized.rawValue: return "SDK was not properly initialized"
            case OguryShowErrorCode.anotherAdAlreadyDisplayed.rawValue: return "Another ad is already being display"
            case OguryShowErrorCode.noAdLoaded.rawValue: return "Ad is not loaded"
            case OguryShowErrorCode.viewControllerPreventsAdFromBeingDisplayed.rawValue: return "We were unable to show the ad in the current presenting view controller"
            case OguryShowErrorCode.viewInBackground.rawValue: return "Try to present an ad while app is in background"
            case OguryShowErrorCode.webviewTerminatedBySystem.rawValue: return "iOS killed the webview due to memory pressure"
            case OguryLoadErrorCode.adDisabledUnspecifiedReason.rawValue: return "Ad is disabled"
            case OguryLoadErrorCode.adDisabledConsentMissing.rawValue: return "Ad is disabled (Missing consent)"
            case OguryLoadErrorCode.adDisabledConsentDenied.rawValue: return "Ad is disabled (consent denied)"
            case OguryLoadErrorCode.adDisabledCountryNotOpened.rawValue: return "Ad is disabled (unopened country)"
            case OguryLoadErrorCode.invalidConfiguration.rawValue: return "Profig is not Synced"
            case OguryLoadErrorCode.adParsingFailed.rawValue: return "Ad parsing failed"
            case OguryLoadErrorCode.adPrecachingFailed.rawValue: return "Ad precaching failed"
            case OguryLoadErrorCode.adPrecachingTimeout.rawValue: return "Ad precaching timed out"
            case OguryLoadErrorCode.noActiveInternetConnection.rawValue: return "No internet connection"
            case OguryLoadErrorCode.adRequestFailed.rawValue: return "Ad request failed"
            case OguryLoadErrorCode.sdkNotStarted.rawValue: return "SDK was not initialized"
            case OguryLoadErrorCode.sdkNotProperlyInitialized.rawValue: return "SDK was not properly initialized"
            case OguryLoadErrorCode.noFill.rawValue: return "Ad is not available"
            default: return nil
        }
    }
}

extension AdManagerError: OguryErrorConvertible {
    var readableError: String? {
        switch self {
            case .noOptions: return "No options was fed to the adManager"
            case .loadNotCalledBeforeShow: return "Show was called before load"
            case .noShowForBanner: return "Show does not work on banners"
            case let .adMarkUpRetrievalFailed(error):
                return error == nil ? "AdMarkUp retrieval failed" : "\(error!)"
        }
    }
}
