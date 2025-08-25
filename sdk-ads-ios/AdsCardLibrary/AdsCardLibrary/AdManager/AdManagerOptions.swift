//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation
import SwiftUI

public struct AdViewOptions: Codable, Equatable {
    public var adConfiguration: AdConfiguration!
    public var cardConfiguration: CardConfiguration!
    public init(adParameters: AdConfiguration!, cardConfiguration: CardConfiguration = .init()) {
        self.adConfiguration = adParameters
        self.cardConfiguration = cardConfiguration
    }
}

public struct FieldEditingMask: OptionSet, Codable, Hashable, CaseIterable {
    public static var allCases: [FieldEditingMask] = [.allowAdUnit, .allowCampaignId, .allowCreativeId, .allowDspFields]
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let denyAll = FieldEditingMask(rawValue: 1 << 0)
    public static let allowAll = FieldEditingMask(rawValue: 1 << 30) // to handle Android 32 bit system
    public static let allowAdUnit = FieldEditingMask(rawValue: 1 << 1)
    public static let allowCampaignId = FieldEditingMask(rawValue: 1 << 2)
    public static let allowCreativeId = FieldEditingMask(rawValue: 1 << 3)
    public static let allowDspFields = FieldEditingMask(rawValue: 1 << 4)
    
    var displayName: String {
        switch self {
            case .denyAll: return "None"
            case .allowAll: return "All"
            case .allowAdUnit: return "Ad Unit"
            case .allowCampaignId: return "Campaign Id"
            case .allowCreativeId: return "Creative Id"
            case .allowDspFields: return "Dsp fields"
            default: return ""
        }
    }
}

public struct CardConfiguration: Codable, Equatable, Hashable {
    public var enableFieldsEditing: Bool = true
    public var fieldEditingMask: FieldEditingMask = .allowAll
    /// show the campaignId field on the ``AdView``
    public var showCampaignId: Bool = true
    /// show the creativeId field on the ``AdView``
    public var showCreativeId: Bool = false
    /// show the DSP creativeId field on the ``AdView``
    public var showDspFields: Bool = false
    /// show the DSP creativeId field on the ``AdView``
    public var showKillMode: Bool = true
    /// show the DSP creativeId field on the ``AdView``
    public var showRtbTestMode: Bool = true
    /// The name of the card that will handle the ad
    public var adDisplayName: String = ""
    /// indicates if we should show the action bar or not
    public var bulkModeEnabled: Bool = false
    /// indicates if we should use _test mode
    public var showTestModeButton: Bool = true
    /// indicates if we should use _test mode
    public var oguryTestModeEnabled: Bool = true
    /// indicates if we should use the RTB test mode (test=1 in bid request)
    public var rtbTestModeEnabled: Bool = true
    /// indicates if we should show the killWebView feature
    public var killWebviewMode: KillWebviewMode = .none
    /// The card accessibilityLabel for testSigma and filter logs
    public var qaLabel: String = UUID().uuidString
    
    public init(enableFieldsEditing: Bool = true,
                fieldEditingMask: FieldEditingMask = .allowAll,
                showCampaignId: Bool = true,
                showCreativeId: Bool = false,
                showDspFields: Bool = false,
                showKillMode: Bool = true,
                showRtbTestMode: Bool = true,
                adDisplayName: String = "",
                bulkModeEnabled: Bool = false,
                oguryTestModeEnabled: Bool = true,
                showTestModeButton: Bool = true,
                rtbTestModeEnabled: Bool = true,
                killWebviewMode: KillWebviewMode = .none,
                qaLabel: String = UUID().uuidString) {
        self.enableFieldsEditing = enableFieldsEditing
        self.fieldEditingMask = fieldEditingMask
        self.showCampaignId = showCampaignId
        self.showCreativeId = showCreativeId
        self.showDspFields = showDspFields
        self.showKillMode = showKillMode
        self.showRtbTestMode = showRtbTestMode
        self.adDisplayName = adDisplayName
        self.bulkModeEnabled = bulkModeEnabled
        self.oguryTestModeEnabled = oguryTestModeEnabled
        self.showTestModeButton = showTestModeButton
        self.rtbTestModeEnabled = rtbTestModeEnabled
        self.killWebviewMode = killWebviewMode
        self.qaLabel = qaLabel
    }
}

public struct AdConfiguration: Codable, Equatable, Hashable {
    /// The adUnitId used to load the ad
    public internal(set) var adUnitId: String
    /// The campaignId used to load the ad
    public var campaignId: String?
    /// The creativeId used to load the ad
    public var creativeId: String?
    /// The dsp creativeId used to load the ad
    public var dspCreativeId: String?
    /// The dsp region used to load the ad
    public var dspRegion: DspRegion?
    /// The dsp region used to load the ad
    public var bannerSize: CGSize?
    
    public init(adUnitId: String,
                campaignId: String? = nil,
                creativeId: String? = nil,
                dspCreativeId: String? = nil,
                dspRegion: DspRegion? = nil,
                bannerSize: CGSize? = nil) {
        self.adUnitId = adUnitId
        self.campaignId = campaignId
        self.creativeId = creativeId
        self.dspCreativeId = dspCreativeId
        self.dspRegion = dspRegion
        self.bannerSize = bannerSize
    }
}

public enum DspRegion : CaseIterable, Codable {
    case euWest1
    case usEast1
    case usWest2
    case apNorthEast1
    
    public var displayName: String {
        switch self {
            case .euWest1: return "eu-west-1"
            case .usEast1: return "us-east-1"
            case .usWest2: return "us-west-2"
            case .apNorthEast1: return "ap-northeast-1"
        }
    }
}

public enum KillWebviewMode: String, CaseIterable, Codable {
    case none, simulate, saturate
    
    public static var allCases: [KillWebviewMode] {
#if targetEnvironment(simulator)
        return [.none, .simulate]
#else
        return [.none, .simulate, .saturate]
#endif
    }
    
    public var displayName: String {
        switch self {
            case .none: return "Don't display feature"
            case .simulate: return "Simulate"
            case .saturate: return "Crash"
        }
    }
    public var description: String? {
        switch self {
            case .none: return nil
            case .simulate: return "Simulate a memory pressure by calling the SDK delegate method that handles webview kill"
            case .saturate: return "Saturate the device's memory to try to trigger a webview crash. This will heat your device as memory will saturate, use with caution"
        }
    }
    public var displayColor: Color {
        switch self {
            case .none: return Color(AdColorPalette.Text.primary(onAccent: false).color)
            case .simulate: return Color(AdColorPalette.Text.primary(onAccent: false).color)
            case .saturate: return Color(AdColorPalette.State.failure.color)
        }
    }
    public var icon: Image? {
        if case .saturate = self {
            return Image(systemName: "bolt.trianglebadge.exclamationmark.fill")
        }
        return nil
    }
}
