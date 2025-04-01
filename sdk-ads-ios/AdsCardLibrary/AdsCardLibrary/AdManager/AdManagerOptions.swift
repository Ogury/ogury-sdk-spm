//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation
import UIKit

//MARK: -
public protocol OguryAdOptions: Equatable, Codable {
    //MARK: Variables
    /// show the campaignId field on the ``AdView``
    var showCampaignId: Bool { get set }
    /// show the creativeId field on the ``AdView``
    var showCreativeId: Bool { get set }
    /// show the DSP creativeId field on the ``AdView``
    var showDspFields: Bool { get set }
    /// show the specific options view on the ``AdView``
    var showSpecificOptions: Bool { get set }
    /// the common options for all ads
    var baseOptions: BaseAdOptions { get set }
    /// checks the equality between 2 option set
    func isEqual(_ otherOption: any OguryAdOptions) -> Bool
}

public struct BaseAdOptions: Equatable, Codable {
    /// The name of the card that will handle the ad
    public internal(set) var adDisplayName: String
    /// The adUnitId used to load the ad
    public internal(set) var adUnitId: String
    /// The campaignId used to load the ad
    public internal(set) var campaignId: String?
    /// The dsp creativeId used to load the ad
    public internal(set) var dspCreativeId: String?
    /// The dsp region used to load the ad
    public internal(set) var dspRegion: DspRegion?
    /// The creativeId used to load the ad
    public internal(set) var creativeId: String?
    /// indicates if the card is selected or not
    public internal(set) var isSelected: Bool
    /// indicates if we should show the action bar or not
    public internal(set) var bulkModeEnabled: Bool
    /// indicates if we should use _test mode
    public internal(set) var oguryTestModeEnabled: Bool
    /// indicates if we should use the RTB test mode (test=1 in bid request)
    public internal(set) var rtbTestModeEnabled: Bool
    /// indicates if we should show the killWebView feature
    public internal(set) var killWebviewMode: KillWebviewMode
    /// The card accessibilityLabel
    public internal(set) var qaLabel: String
    
    mutating public func update(name: String) {
        adDisplayName = name
    }
    mutating public func update(accessibilityLabel: String) {
        qaLabel = accessibilityLabel
    }
}

extension OguryAdOptions {
    static public func == (lhs: Self, rhs: Self) -> Bool {
        lhs.isEqual(rhs)
    }
}

//MARK: -
/// ``BaseAdManagerOptions`` will handle all the common settings for all ad format
public class BaseAdManagerOptions: OguryAdOptions, Codable {
    //MARK: Variables
    /// show the campaignId field on the ``AdView``. false if not set otherwise
    public var showCampaignId: Bool
    /// show the creativeId field on the ``AdView``. true if not set otherwise
    public var showCreativeId: Bool
    /// show the DSP creativeId field on the``AdView``. true if not set otherwise
    public var showDspFields: Bool
    /// show the specific options view on the ``AdView``. true if not set otherwise
    public var showSpecificOptions: Bool
    /// the common options for all ads
    public var baseOptions: BaseAdOptions
    
    //MARK: Initializer
    public init(showCampaignId: Bool = false,
                showCreativeId: Bool = false,
                showDspFields: Bool = true,
                showSpecificOptions: Bool = true,
                adDisplayName: String,
                adUnitId: String,
                campaignId: String? = nil,
                creativeId: String? = nil,
                dspCreativeId: String? = nil,
                dspRegion: DspRegion? = nil,
                isSelected: Bool = false,
                bulkModeEnabled: Bool = false,
                oguryTestModeEnabled: Bool = false,
                rtbTestModeEnabled: Bool = false,
                killWebviewMode: KillWebviewMode = .none,
                qaLabel: String = UUID().uuidString) {
        self.showCampaignId = showCampaignId
        self.showCreativeId = showCreativeId
        self.showDspFields = showDspFields
        self.showSpecificOptions = showSpecificOptions
        baseOptions = BaseAdOptions(adDisplayName: adDisplayName,
                                    adUnitId: adUnitId,
                                    campaignId: campaignId,
                                    dspCreativeId: dspCreativeId,
                                    dspRegion: dspRegion,
                                    creativeId: creativeId,
                                    isSelected: isSelected,
                                    bulkModeEnabled: bulkModeEnabled,
                                    oguryTestModeEnabled: oguryTestModeEnabled,
                                    rtbTestModeEnabled: rtbTestModeEnabled,
                                    killWebviewMode: killWebviewMode,
                                    qaLabel: qaLabel)
    }
    
    public func isEqual(_ options: any OguryAdOptions) -> Bool {
        guard let otherOption = options as? BaseAdManagerOptions else { return false }
        return showCampaignId == otherOption.showCampaignId &&
        showCreativeId == otherOption.showCreativeId &&
        showDspFields == showDspFields &&
        showSpecificOptions == otherOption.showSpecificOptions &&
        baseOptions == otherOption.baseOptions
    }
}

extension BaseAdManagerOptions: Equatable {
    static public func == (lhs: BaseAdManagerOptions, rhs: BaseAdManagerOptions) -> Bool {
        lhs.isEqual(rhs)
    }
}

/// ``MrecAdManagerOptions`` will add to ``BaseAdManagerOptions`` all the settings dedicated to Mrecs (banner and mpu)
public class BannerAdManagerOptions: BaseAdManagerOptions {
    /// specific banner options that handles the banner placement inside the view.
    /// > Warning: view is not encoded, nor decoded. When decoding an object, be sure to set the property back
    public var view: UIView!
    //MARK: Initializer
    public init(showCampaignId: Bool = false,
                showCreativeId: Bool = false,
                showDspFields: Bool = true,
                showSpecificOptions: Bool = true,
                view: UIView,
                adDisplayName: String,
                adUnitId: String,
                campaignId: String? = nil,
                creativeId: String? = nil,
                dspCreativeId: String? = nil,
                dspRegion: DspRegion? = nil,
                isSelected: Bool = false,
                bulkModeEnabled: Bool = false,
                oguryTestModeEnabled: Bool = false,
                rtbTestModeEnabled: Bool = false,
                killWebviewMode: KillWebviewMode = .none,
                qaLabel: String = UUID().uuidString) {
        super.init(showCampaignId: showCampaignId,
                   showCreativeId: showCreativeId,
                   showDspFields: showDspFields,
                   showSpecificOptions: showSpecificOptions,
                   adDisplayName: adDisplayName,
                   adUnitId: adUnitId,
                   campaignId: campaignId,
                   creativeId: creativeId,
                   dspCreativeId: dspCreativeId,
                   dspRegion: dspRegion,
                   isSelected: isSelected,
                   bulkModeEnabled: bulkModeEnabled,
                   oguryTestModeEnabled: oguryTestModeEnabled,
                   rtbTestModeEnabled: rtbTestModeEnabled,
                   killWebviewMode: killWebviewMode,
                   qaLabel: qaLabel)
        self.view = view
    }
    
    public init(options: BaseAdManagerOptions) {
        super.init(showCampaignId: options.showCampaignId,
                   showCreativeId: options.showCreativeId,
                   showDspFields: options.showDspFields,
                   showSpecificOptions: options.showSpecificOptions,
                   adDisplayName: options.baseOptions.adDisplayName,
                   adUnitId: options.baseOptions.adUnitId,
                   campaignId: options.baseOptions.campaignId,
                   creativeId: options.baseOptions.creativeId,
                   dspCreativeId: options.baseOptions.dspCreativeId,
                   dspRegion: options.baseOptions.dspRegion,
                   isSelected: options.baseOptions.isSelected,
                   bulkModeEnabled: options.baseOptions.bulkModeEnabled,
                   oguryTestModeEnabled: options.baseOptions.oguryTestModeEnabled,
                   rtbTestModeEnabled: options.baseOptions.rtbTestModeEnabled,
                   killWebviewMode: options.baseOptions.killWebviewMode,
                   qaLabel: options.baseOptions.qaLabel)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    public override func isEqual(_ options: any OguryAdOptions) -> Bool {
        guard let otherThumbOption = options as? BannerAdManagerOptions else { return false }
        return super.isEqual(otherThumbOption) && view == otherThumbOption.view
    }
}

/// ``AdManagerOptions`` will extend ``BaseAdManagerOptions`` to add a viewController property that is needed for most formats except Mrec
public class AdManagerOptions: BaseAdManagerOptions {
    /// options for most ads (inside UIViewController) that handles the placement inside the app.
    /// > Warning: viewController is not encoded, nor decoded. When decoding an object, be sure to set the property back
    public var viewController: UIViewController!
    //MARK: Initializer
    public init(showCampaignId: Bool = false,
                showCreativeId: Bool = false,
                showDspFields: Bool = true,
                showSpecificOptions: Bool = true,
                viewController: UIViewController,
                adDisplayName: String,
                adUnitId: String,
                campaignId: String? = nil,
                creativeId: String? = nil,
                dspCreativeId: String? = nil,
                dspRegion: DspRegion? = nil,
                isSelected: Bool = false,
                bulkModeEnabled: Bool = false,
                oguryTestModeEnabled: Bool = false,
                rtbTestModeEnabled: Bool = false,
                killWebviewMode: KillWebviewMode = .none,
                qaLabel: String = UUID().uuidString) {
        super.init(showCampaignId: showCampaignId,
                   showCreativeId: showCreativeId,
                   showDspFields: showDspFields,
                   showSpecificOptions: showSpecificOptions,
                   adDisplayName: adDisplayName,
                   adUnitId: adUnitId,
                   campaignId: campaignId,
                   creativeId: creativeId,
                   dspCreativeId: dspCreativeId,
                   dspRegion: dspRegion,
                   isSelected: isSelected,
                   bulkModeEnabled: bulkModeEnabled,
                   oguryTestModeEnabled: oguryTestModeEnabled,
                   rtbTestModeEnabled: rtbTestModeEnabled,
                   killWebviewMode: killWebviewMode,
                   qaLabel: qaLabel)
        self.viewController = viewController
    }
    
    public init(options: BaseAdManagerOptions) {
        super.init(showCampaignId: options.showCampaignId,
                   showCreativeId: options.showCreativeId,
                   showDspFields: options.showDspFields,
                   showSpecificOptions: options.showSpecificOptions,
                   adDisplayName: options.baseOptions.adDisplayName,
                   adUnitId: options.baseOptions.adUnitId,
                   campaignId: options.baseOptions.campaignId,
                   creativeId: options.baseOptions.creativeId,
                   dspCreativeId: options.baseOptions.dspCreativeId,
                   dspRegion: options.baseOptions.dspRegion,
                   isSelected: options.baseOptions.isSelected,
                   bulkModeEnabled: options.baseOptions.bulkModeEnabled,
                   oguryTestModeEnabled: options.baseOptions.oguryTestModeEnabled,
                   rtbTestModeEnabled: options.baseOptions.rtbTestModeEnabled,
                   killWebviewMode: options.baseOptions.killWebviewMode,
                   qaLabel: options.baseOptions.qaLabel)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    public override func isEqual(_ options: any OguryAdOptions) -> Bool {
        guard let otherThumbOption = options as? AdManagerOptions else { return false }
        return super.isEqual(otherThumbOption) && viewController == otherThumbOption.viewController
    }
}
