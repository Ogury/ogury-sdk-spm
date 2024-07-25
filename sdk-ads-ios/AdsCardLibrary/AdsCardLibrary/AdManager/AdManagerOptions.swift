//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation
import OguryAds

//MARK: -
public protocol AdOptions: Equatable, Codable {
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
    func isEqual(_ otherOption: any AdOptions) -> Bool
}

public struct BaseAdOptions: Equatable, Codable {
    /// The name of the card that will handle the ad
    public internal(set) var adDisplayName: String
    /// The adUnitId used to load the ad
    public internal(set) var adUnitId: String
    /// The campaignId used to load the ad
    public internal(set) var campaignId: String?
    /// The dsp creativeId used to load the ad
    public internal(set) var  dspCreativeId: String?
    /// The dsp region used to load the ad
    public internal(set) var  dspRegion: DspRegion?
    /// The creativeId used to load the ad
    public internal(set) var creativeId: String?
    /// The adMarkUp JSON object for HB
    public internal(set) var adMarkUp: String?
    /// indicates if the card is selected or not
    public internal(set) var isSelected: Bool
    /// indicates if we should show the action bar or not
    public internal(set) var bulkModeEnabled: Bool
    
    mutating public
    func update(name: String) {
        adDisplayName = name
    }
}

extension AdOptions {
    static public func == (lhs: any AdOptions, rhs: any AdOptions) -> Bool {
        lhs.isEqual(rhs)
    }
}

//MARK: -
/// ``BaseAdManagerOptions`` will handle all the common settings for all ad format
public class BaseAdManagerOptions: AdOptions, Codable {
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
                adMarkUp: String? = nil,
                isSelected: Bool = false,
                bulkModeEnabled: Bool = false) {
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
                                    adMarkUp: adMarkUp,
                                    isSelected: isSelected,
                                    bulkModeEnabled: bulkModeEnabled)
    }
    
    public func isEqual(_ options: any AdOptions) -> Bool {
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
                adMarkUp: String? = nil,
                isSelected: Bool = false,
                bulkModeEnabled: Bool = false) {
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
                   adMarkUp: adMarkUp,
                   isSelected: isSelected,
                   bulkModeEnabled: bulkModeEnabled)
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
                   adMarkUp: options.baseOptions.adMarkUp,
                   isSelected: options.baseOptions.isSelected,
                   bulkModeEnabled: options.baseOptions.bulkModeEnabled)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    public override func isEqual(_ options: any AdOptions) -> Bool {
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
                adMarkUp: String? = nil,
                isSelected: Bool = false,
                bulkModeEnabled: Bool = false) {
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
                   adMarkUp: adMarkUp,
                   isSelected: isSelected,
                   bulkModeEnabled: bulkModeEnabled)
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
                   adMarkUp: options.baseOptions.adMarkUp,
                   isSelected: options.baseOptions.isSelected,
                   bulkModeEnabled: options.baseOptions.bulkModeEnabled)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    public override func isEqual(_ options: any AdOptions) -> Bool {
        guard let otherThumbOption = options as? AdManagerOptions else { return false }
        return super.isEqual(otherThumbOption) && viewController == otherThumbOption.viewController
    }
}

/// ``ThumbnailAdManagerOptions`` will extend ``AdManagerOptions`` to add all options associated with Thumbnail format
public class ThumbnailAdManagerOptions: AdManagerOptions {
    /// specific thumbnail options that handles the Thumbnail placement on screen.
    /// It has a visual represeentation ``AdView``. false if not set otherwise
    public var thumbnailOptions: ThumbnailOptions!
    //MARK: Initializer
    public init(showCampaignId: Bool = false,
                showCreativeId: Bool = false,
                showDspFields: Bool = true,
                showSpecificOptions: Bool = true,
                viewController: UIViewController,
                thumbnailOptions: ThumbnailOptions,
                adDisplayName: String,
                adUnitId: String,
                campaignId: String? = nil,
                creativeId: String? = nil,
                dspCreativeId: String? = nil,
                dspRegion: DspRegion? = nil,
                adMarkUp: String? = nil,
                isSelected: Bool = false,
                bulkModeEnabled: Bool = false) {
        super.init(showCampaignId: showCampaignId,
                   showCreativeId: showCreativeId,
                   showDspFields: showDspFields,
                   showSpecificOptions: showSpecificOptions,
                   viewController: viewController,
                   adDisplayName: adDisplayName,
                   adUnitId: adUnitId,
                   campaignId: campaignId,
                   creativeId: creativeId,
                   dspCreativeId: dspCreativeId,
                   dspRegion: dspRegion,
                   adMarkUp: adMarkUp,
                   isSelected: isSelected,
                   bulkModeEnabled: bulkModeEnabled)
        self.thumbnailOptions = thumbnailOptions
    }
    
    public init(options: BaseAdManagerOptions, thumbnailOptions: ThumbnailOptions) {
        super.init(showCampaignId: options.showCampaignId,
                   showCreativeId: options.showCreativeId,
                   showDspFields: options.showDspFields,
                   showSpecificOptions: options.showSpecificOptions,
                   viewController: UIViewController(),
                   adDisplayName: options.baseOptions.adDisplayName,
                   adUnitId: options.baseOptions.adUnitId,
                   campaignId: options.baseOptions.campaignId,
                   creativeId: options.baseOptions.creativeId,
                   dspCreativeId: options.baseOptions.dspCreativeId,
                   dspRegion: options.baseOptions.dspRegion,
                   adMarkUp: options.baseOptions.adMarkUp,
                   isSelected: options.baseOptions.isSelected,
                   bulkModeEnabled: options.baseOptions.bulkModeEnabled)
        self.thumbnailOptions = thumbnailOptions
    }
    
    private enum CodingKeys: String, CodingKey {
        case thumbnailOptions
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        thumbnailOptions = try container.decode(ThumbnailOptions.self, forKey: .thumbnailOptions)
        try super.init(from: decoder)
    }
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(thumbnailOptions, forKey: .thumbnailOptions)
    }
    
    public override func isEqual(_ options: any AdOptions) -> Bool {
        guard let otherThumbOption = options as? ThumbnailAdManagerOptions else { return false }
        return super.isEqual(otherThumbOption) && thumbnailOptions == otherThumbOption.thumbnailOptions
    }
}

//MARK: -
/// Options specific to Thumbnail Ads
public struct ThumbnailOptions: Codable {
    /// the position of the top left corner of the thumbnail if provided
    public var position: CGPoint?
    /// the size of the thumbnail if provided
    public var size: CGSize?
    /// the offset of the thumbnail if provided
    public var offset: OguryOffset?
    /// the rect corner of the thumbnail if provided
    public var corner: OguryRectCorner?
    /// the scene in which we should show the thumbnail
    public var scene: UIWindowScene?
    
    public init(position: CGPoint? = nil,
                size: CGSize? = nil,
                offset: OguryOffset? = nil,
                corner: OguryRectCorner? = nil,
                scene: UIWindowScene? = nil) {
        self.position = position
        self.size = size
        self.offset = offset
        self.corner = corner
        self.scene = scene
    }
    
    private enum CodingKeys: String, CodingKey {
        case position, size, offset, corner
    }
    
    public var rawCorner: Int { corner?.rawValue ?? 0 }
    public var x: Int { Int(position?.x ?? (offset?.x ?? 0)) }
    public var y: Int { Int(position?.y ?? (offset?.y ?? 0)) }
    public var width: Int { Int(size?.width ?? 180) }
    public var height: Int { Int(size?.height ?? 180) }
}

extension ThumbnailOptions: Equatable {
    static public func == (lhs: Self, rhs: Self) -> Bool {
        lhs.corner == rhs.corner &&
        lhs.position == rhs.position &&
        lhs.size == rhs.size &&
        lhs.offset == rhs.offset
    }
}

//MARK: - Codable extensions for OguryAds options
extension OguryOffset: Codable {
    enum CodingKeys: CodingKey {
        case x, y
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
    }
    public init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        x = try container.decode(CGFloat.self, forKey: .x)
        y = try container.decode(CGFloat.self, forKey: .y)
    }
}

extension OguryOffset: Equatable {
    static public func == (lhs: OguryOffset, rhs: OguryOffset) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
}

extension OguryRectCorner: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(Int.self)
        self = OguryRectCorner(rawValue: rawValue) ?? OguryRectCorner.topLeft
    }
}
