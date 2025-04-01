//
//  ThumbnailOptions.swift
//  AdsCardLibrary
//
//  Created by Jerome TONNELIER on 31/03/2025.
//

import Foundation
import OguryAds

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
                   viewController: viewController,
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
                   isSelected: options.baseOptions.isSelected,
                   bulkModeEnabled: options.baseOptions.bulkModeEnabled,
                   oguryTestModeEnabled: options.baseOptions.oguryTestModeEnabled,
                   rtbTestModeEnabled: options.baseOptions.rtbTestModeEnabled,
                   killWebviewMode: options.baseOptions.killWebviewMode,
                   qaLabel: options.baseOptions.qaLabel)
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
