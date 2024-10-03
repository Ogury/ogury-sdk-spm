//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import UIKit
import OguryAds

enum BannerType: CaseIterable {
    case mpu
    case smallBanner
    
    var name: String {
        switch self {
            case .mpu: return "mpu"
            case .smallBanner: return "small banner"
        }
    }
    
    var oguryBannerSize: OguryAdsBannerSize {
        switch self {
            case .mpu: return OguryAdsBannerSize.mpu_300x250()
            case .smallBanner: return OguryAdsBannerSize.small_banner_320x50()
        }
    }
    
    var size: CGSize {
        switch self {
            case .mpu: return CGSize(width: 300, height: 250)
            case .smallBanner: return CGSize(width: 320, height: 50)
        }
    }
}

enum ThumbnailPositionType: Int, CaseIterable, Codable {
    case byDefault
    case byCorner
    case byPosition
    
    var name: String {
        switch self {
            case .byDefault: return "Default"
            case .byCorner: return "Corner"
            case .byPosition: return "Position"
        }
    }
}

indirect enum AvailableType: Equatable {
    case interstitial
    case optinVideo
    case thumbnail
    case banner(type: BannerType)
    case logs
    case deprecated(_: AvailableType)
    case headerBidding(_: AvailableType)
    
    static let allValues = [logs,
                            interstitial,
                            headerBidding(.interstitial),
                            //.deprecated(.interstitial),
                            optinVideo,
                            //.deprecated(.optinVideo),
                            headerBidding(.optinVideo),
                            thumbnail,
                            //.deprecated(.thumbnail),
                            banner(type: .mpu),
                            //.deprecated(.banner(type: .mpu)),
                            headerBidding(.banner(type: .mpu)),]
    
    var instance: AdsCollectionCell? {
        switch self {
            case .interstitial:
                let inter = InterstitialCollectionCell()
                inter.configType = .interstitial
                return inter
                
            case .deprecated(.interstitial):
                let inter = InterstitialCollectionCell()
                inter.configType = .deprecated(.interstitial)
                return inter
                
            case .optinVideo:
                let inter = InterstitialCollectionCell()
                inter.configType = .optinVideo
                return inter
                
            case .headerBidding(.optinVideo):
                let inter = InterstitialCollectionCell()
                inter.configType = .headerBidding(.optinVideo)
                return inter
                
            case .deprecated(.optinVideo):
                let inter = InterstitialCollectionCell()
                inter.configType = .deprecated(.optinVideo)
                return inter
                
            case .thumbnail:
                let thumbnail = ThumbnailCollectionCell()
                thumbnail.configType = .thumbnail
                return thumbnail
                
            case .deprecated(.thumbnail):
                let thumbnail = ThumbnailCollectionCell()
                thumbnail.configType = .deprecated(.thumbnail)
                return thumbnail
                
            case .headerBidding(.interstitial):
                let cell = InterstitialCollectionCell()
                cell.configType = .headerBidding(.interstitial)
                return cell
                
            case .banner(type: .mpu):
                let bannerCell = BannerCollectionCell()
                bannerCell.configType = .banner(type: .mpu)
                bannerCell.bannerType = .mpu
                return bannerCell
                
            case .headerBidding(.banner(type: .mpu)):
                let bannerCell = BannerCollectionCell()
                bannerCell.configType = .headerBidding(.banner(type: .mpu))
                bannerCell.bannerType = .mpu
                return bannerCell
                
            case .banner(type: .smallBanner):
                let bannerCell = BannerCollectionCell()
                bannerCell.configType = .banner(type: .smallBanner)
                bannerCell.bannerType = .smallBanner
                return bannerCell
                
            case .deprecated(.banner(type: .mpu)):
                let bannerCell = BannerCollectionCell()
                bannerCell.configType = .deprecated(.banner(type: .mpu))
                bannerCell.bannerType = .mpu
                return bannerCell
                
            case .deprecated(.banner(type: .smallBanner)):
                let bannerCell = BannerCollectionCell()
                bannerCell.configType = .deprecated(.banner(type: .smallBanner))
                bannerCell.bannerType = .smallBanner
                return bannerCell
                
            case .logs:
                let logs = LogsCell()
                logs.configType = .logs
                return logs
                
            default: return nil
        }
    }
    
    var configName: String {
        switch self {
            case .interstitial: return "interstitial"
            case .optinVideo: return "optin"
            case .thumbnail: return "thumbnail"
            case .banner(type: .mpu): return "mpu"
            case .banner(type: .smallBanner): return "smallBanner"
            case .logs:return "logs"
            case .deprecated(let type): return "deprecated\(type.configName.capitalizeFirstLetter())"
            case .headerBidding(let type): return "headerBidding\(type.configName.capitalizeFirstLetter())"
        }
    }
    
    var displayName: String? {
        switch self {
            case .interstitial: return "Interstitial ad"
            case .optinVideo: return "Opt-in Video ad"
            case .thumbnail: return "Thumbnail ad"
            case .banner:return "Banner ad"
            case .logs:return "Logs"
            case .deprecated(let type): return "\(type.displayName ?? "") (deprecated)"
            case .headerBidding(let type): return "HB (\(SettingsHeaderVC.selectedCountry)) - \(type.displayName ?? "")"
        }
    }
    
    var backgroundColor: UIColor? {
        switch self {
            case .headerBidding: return UIColor(red: 0.78, green: 0.5, blue: 0.5, alpha: 1)
            case .deprecated: return UIColor(red: 0.78, green: 0.78, blue: 0.78, alpha: 1)
            default: return UIColor(red: 0.78, green: 0.78, blue: 0.78, alpha: 1)
        }
    }
}

protocol AdCellAction {
    func updateAdCell(_ type: AvailableType, in viewController: UIViewController)
}

class AdConfig: NSObject, Codable {
    var adUnitID: String?
    var campaignID: String?
    var creativeID: String?
    var dspCreativeId: String?
    var dspRegion: String?
    var xOffset: Int?
    var yOffset: Int?
    var height: Int?
    var width: Int?
    var corner: OguryRectCorner?
    var thumbnailPositionType: ThumbnailPositionType?
    
    enum CodingKeys: String, CodingKey {
        case adUnitID
        case campaignID
        case creativeID
        case dspCreativeID
        case dspRegion
        case xOffset
        case yOffset
        case height
        case width
        case corner
        case thumbnailPositionType
    }
    
    init(adUnitID: String? = nil,
         campaignID: String? = "",
         creativeID: String? = "",
         dspCreativeId: String? = "",
         dspRegion: String? = "",
         xOffset: Int? = nil,
         yOffset: Int? = nil,
         height: Int? = nil,
         width: Int? = nil,
         corner: OguryRectCorner? = nil,
         thumbnailPositionType: ThumbnailPositionType? = nil) {
        self.adUnitID = adUnitID
        self.campaignID = campaignID
        self.creativeID = creativeID
        self.dspCreativeId = dspCreativeId
        self.dspRegion = dspRegion
        self.xOffset = xOffset
        self.yOffset = yOffset
        self.height = height
        self.width = width
        self.corner = corner
        self.thumbnailPositionType = thumbnailPositionType
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(adUnitID, forKey: .adUnitID)
        try container.encode(campaignID, forKey: .campaignID)
        try container.encode(creativeID, forKey: .creativeID)
        try container.encode(dspCreativeId, forKey: .dspCreativeID)
        try container.encode(dspRegion, forKey: .dspRegion)
        try container.encode(xOffset, forKey: .xOffset)
        try container.encode(yOffset, forKey: .yOffset)
        try container.encode(height, forKey: .height)
        try container.encode(width, forKey: .width)
        try container.encode(corner?.rawValue, forKey: .corner)
        try container.encode(thumbnailPositionType, forKey: .thumbnailPositionType)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        adUnitID = try? container.decode(String.self, forKey: .adUnitID)
        campaignID = try? container.decode(String.self, forKey: .campaignID)
        creativeID = try? container.decode(String.self, forKey: .creativeID)
        dspCreativeId = try? container.decode(String.self, forKey: .dspCreativeID)
        dspRegion = try? container.decode(String.self, forKey: .dspRegion)
        xOffset = try? container.decode(Int.self, forKey: .xOffset)
        yOffset = try? container.decode(Int.self, forKey: .yOffset)
        height = try? container.decode(Int.self, forKey: .height)
        width = try? container.decode(Int.self, forKey: .width)
        corner = (try? container.decode(Int.self, forKey: .corner)).map {
            OguryRectCorner(rawValue: $0)
        } as? OguryRectCorner
        thumbnailPositionType = try? container.decode(ThumbnailPositionType.self, forKey: .thumbnailPositionType)
    }
}
