//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import UIKit
import AdsCardLibrary

protocol MediationOptions: Codable {
    var interstitial: Configuration.DefaultBaseOptions { get }
    var optIn: Configuration.DefaultBaseOptions { get }
    var mpu: Configuration.DefaultBaseOptions { get }
    var banner: Configuration.DefaultBaseOptions { get }
    var thumbnail: Configuration.DefaultBaseOptions? { get }
    var url: URL? { get }
}

struct Configuration: Decodable {
    struct DefaultBaseOptions: Codable {
        let adUnitId: String
        let campaignId: String?
        let creativeId: String?
        let dspCreativeId: String?
        let dspRegion: DspRegion?
    }
    struct DefaultOptions: MediationOptions {
        let interstitial: DefaultBaseOptions
        let optIn: DefaultBaseOptions
        let mpu: DefaultBaseOptions
        let banner: DefaultBaseOptions
        let thumbnail: DefaultBaseOptions?
        let url: URL?
    }
    struct DefaultMaxOptions: MediationOptions {
        let interstitial: DefaultBaseOptions
        let optIn: DefaultBaseOptions
        let mpu: DefaultBaseOptions
        let banner: DefaultBaseOptions
        let thumbnail: DefaultBaseOptions?
        let url: URL?
    }
    struct DefaultDTFairBidOptions: MediationOptions {
        let interstitial: DefaultBaseOptions
        let optIn: DefaultBaseOptions
        let mpu: DefaultBaseOptions
        let banner: DefaultBaseOptions
        let thumbnail: DefaultBaseOptions?
        let url: URL?
    }
    let options: DefaultOptions
    let maxOptions: DefaultMaxOptions
    let dtFairBidOptions: DefaultDTFairBidOptions
    
    enum CodingKeys: String, CodingKey {
        case max = "maxHeaderBidding"
        case dtFairBid = "DTFairBidHeaderBidding"
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.singleValueContainer()
        options = try rootContainer.decode(DefaultOptions.self)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        maxOptions = try container.decode(DefaultMaxOptions.self, forKey: .max)
        dtFairBidOptions = try container.decode(DefaultDTFairBidOptions.self, forKey: .dtFairBid)
    }
    
    static let shared: Configuration = {
        
        guard let url = Bundle.main.url(forResource: "Default", withExtension: "json"),
              let json = try? Data(contentsOf: url),
              let conf: Configuration = try? JSONDecoder().decode(Configuration.self, from: json) else {
                fatalError("No configuration file found")
        }
        return conf
    } ()
    
    func options<T: AdManager>(for adType: AdType<T>, index: Int?) -> T.Options {
        let settings = SettingsController()
        switch adType {
            case .interstitial:
                return AdManagerOptions(showCampaignId:settings.showCampaignId,
                                        showCreativeId:settings.showCreativeId,
                                        showDspFields: settings.showDspFields,
                                        showSpecificOptions:settings.showSpecificOptions,
                                        viewController: UIViewController(),
                                        adDisplayName: index == nil ? "" : "Card #\(index!)",
                                        adUnitId: options.interstitial.adUnitId,
                                        campaignId: options.interstitial.campaignId,
                                        creativeId: options.interstitial.creativeId,
                                        dspCreativeId: options.interstitial.dspCreativeId, 
                                        dspRegion: options.interstitial.dspRegion,
                                        bulkModeEnabled: settings.bulkModeEnabled) as! T.Options
                
            case .rewarded:
                return AdManagerOptions(showCampaignId:settings.showCampaignId,
                                        showCreativeId:settings.showCreativeId,
                                        showDspFields: settings.showDspFields,
                                        showSpecificOptions:settings.showSpecificOptions,
                                        viewController: UIViewController(),
                                        adDisplayName: index == nil ? "" : "Card #\(index!)",
                                        adUnitId: options.optIn.adUnitId,
                                        campaignId: options.optIn.campaignId,
                                        creativeId: options.optIn.creativeId,
                                        dspCreativeId: options.interstitial.dspCreativeId,
                                        dspRegion: options.interstitial.dspRegion,
                                        bulkModeEnabled: settings.bulkModeEnabled) as! T.Options
                
            case .thumbnail:
                return ThumbnailAdManagerOptions(showCampaignId:settings.showCampaignId,
                                                 showCreativeId:settings.showCreativeId,
                                                 showDspFields: settings.showDspFields,
                                                 showSpecificOptions:settings.showSpecificOptions,
                                                 viewController: UIViewController(),
                                                 thumbnailOptions: ThumbnailOptions(),
                                                 adDisplayName: index == nil ? "" : "Card #\(index!)",
                                                 adUnitId: options.thumbnail?.adUnitId ?? "",
                                                 campaignId: options.thumbnail?.campaignId,
                                                 creativeId: options.thumbnail?.creativeId,
                                                 dspCreativeId: options.interstitial.dspCreativeId,
                                                 dspRegion: options.interstitial.dspRegion,
                                                 bulkModeEnabled: settings.bulkModeEnabled) as! T.Options
                
            case .mpu:
                return BannerAdManagerOptions(showCampaignId:settings.showCampaignId,
                                              showCreativeId:settings.showCreativeId,
                                              showDspFields: settings.showDspFields,
                                              showSpecificOptions:settings.showSpecificOptions,
                                              view: UIView(),
                                              adDisplayName: index == nil ? "" : "Card #\(index!)",
                                              adUnitId: options.mpu.adUnitId,
                                              campaignId: options.mpu.campaignId,
                                              creativeId: options.mpu.creativeId,
                                              dspCreativeId: options.interstitial.dspCreativeId,
                                              dspRegion: options.interstitial.dspRegion,
                                              bulkModeEnabled: settings.bulkModeEnabled) as! T.Options
                
            case .banner:
                return BannerAdManagerOptions(showCampaignId:settings.showCampaignId,
                                              showCreativeId:settings.showCreativeId,
                                              showDspFields: settings.showDspFields,
                                              showSpecificOptions:settings.showSpecificOptions,
                                              view: UIView(),
                                              adDisplayName: index == nil ? "" : "Card #\(index!)",
                                              adUnitId: options.banner.adUnitId,
                                              campaignId: options.banner.campaignId,
                                              creativeId: options.banner.creativeId,
                                              dspCreativeId: options.interstitial.dspCreativeId,
                                              dspRegion: options.interstitial.dspRegion,
                                              bulkModeEnabled: settings.bulkModeEnabled) as! T.Options
                
            case let .maxHeaderBidding(innerType, _):
                switch innerType {
                    case .interstitial:
                        return AdManagerOptions(showCampaignId:settings.showCampaignId,
                                                showCreativeId:settings.showCreativeId,
                                                showDspFields: settings.showDspFields,
                                                showSpecificOptions:settings.showSpecificOptions,
                                                viewController: UIViewController(),
                                                adDisplayName: index == nil ? "" : "Card #\(index!)",
                                                adUnitId: maxOptions.interstitial.adUnitId,
                                                campaignId: maxOptions.interstitial.campaignId,
                                                creativeId: maxOptions.interstitial.creativeId,
                                                bulkModeEnabled: settings.bulkModeEnabled) as! T.Options
                        
                    case .rewarded:
                        return AdManagerOptions(showCampaignId:settings.showCampaignId,
                                                showCreativeId:settings.showCreativeId,
                                                showDspFields: settings.showDspFields,
                                                showSpecificOptions:settings.showSpecificOptions,
                                                viewController: UIViewController(),
                                                adDisplayName: index == nil ? "" : "Card #\(index!)",
                                                adUnitId: maxOptions.optIn.adUnitId,
                                                campaignId: maxOptions.optIn.campaignId,
                                                creativeId: maxOptions.optIn.creativeId,
                                                bulkModeEnabled: settings.bulkModeEnabled) as! T.Options
                        
                    case .mpu:
                        return BannerAdManagerOptions(showCampaignId:settings.showCampaignId,
                                                      showCreativeId:settings.showCreativeId,
                                                      showDspFields: settings.showDspFields,
                                                      showSpecificOptions:settings.showSpecificOptions,
                                                      view: UIView(),
                                                      adDisplayName: index == nil ? "" : "Card #\(index!)",
                                                      adUnitId: maxOptions.mpu.adUnitId,
                                                      campaignId: maxOptions.mpu.campaignId,
                                                      creativeId: maxOptions.mpu.creativeId,
                                                      bulkModeEnabled: settings.bulkModeEnabled) as! T.Options
                        
                    case .banner:
                        return BannerAdManagerOptions(showCampaignId:settings.showCampaignId,
                                                      showCreativeId:settings.showCreativeId,
                                                      showDspFields: settings.showDspFields,
                                                      showSpecificOptions:settings.showSpecificOptions,
                                                      view: UIView(),
                                                      adDisplayName: index == nil ? "" : "Card #\(index!)",
                                                      adUnitId: maxOptions.banner.adUnitId,
                                                      campaignId: maxOptions.banner.campaignId,
                                                      creativeId: maxOptions.banner.creativeId,
                                                      bulkModeEnabled: settings.bulkModeEnabled) as! T.Options
                        
                    default: fatalError("There should not be HB with thumbnail")
                }
           
            case let .dtFairBidHeaderBidding(innerType, _):
               switch innerType {
                   case .interstitial:
                       return AdManagerOptions(showCampaignId:settings.showCampaignId,
                                               showCreativeId:settings.showCreativeId,
                                               showDspFields: settings.showDspFields,
                                               showSpecificOptions:settings.showSpecificOptions,
                                               viewController: UIViewController(),
                                               adDisplayName: index == nil ? "" : "Card #\(index!)",
                                               adUnitId: dtFairBidOptions.interstitial.adUnitId,
                                               campaignId: dtFairBidOptions.interstitial.campaignId,
                                               creativeId: dtFairBidOptions.interstitial.creativeId,
                                               bulkModeEnabled: settings.bulkModeEnabled) as! T.Options
                       
                   case .rewarded:
                       return AdManagerOptions(showCampaignId:settings.showCampaignId,
                                               showCreativeId:settings.showCreativeId,
                                               showDspFields: settings.showDspFields,
                                               showSpecificOptions:settings.showSpecificOptions,
                                               viewController: UIViewController(),
                                               adDisplayName: index == nil ? "" : "Card #\(index!)",
                                               adUnitId: dtFairBidOptions.optIn.adUnitId,
                                               campaignId: dtFairBidOptions.optIn.campaignId,
                                               creativeId: dtFairBidOptions.optIn.creativeId,
                                               bulkModeEnabled: settings.bulkModeEnabled) as! T.Options
                       
                   case .mpu:
                       return BannerAdManagerOptions(showCampaignId:settings.showCampaignId,
                                                     showCreativeId:settings.showCreativeId,
                                                     showDspFields: settings.showDspFields,
                                                     showSpecificOptions:settings.showSpecificOptions,
                                                     view: UIView(),
                                                     adDisplayName: index == nil ? "" : "Card #\(index!)",
                                                     adUnitId: dtFairBidOptions.mpu.adUnitId,
                                                     campaignId: dtFairBidOptions.mpu.campaignId,
                                                     creativeId: dtFairBidOptions.mpu.creativeId,
                                                     bulkModeEnabled: settings.bulkModeEnabled) as! T.Options
                       
                   case .banner:
                       return BannerAdManagerOptions(showCampaignId:settings.showCampaignId,
                                                     showCreativeId:settings.showCreativeId,
                                                     showDspFields: settings.showDspFields,
                                                     showSpecificOptions:settings.showSpecificOptions,
                                                     view: UIView(),
                                                     adDisplayName: index == nil ? "" : "Card #\(index!)",
                                                     adUnitId: dtFairBidOptions.banner.adUnitId,
                                                     campaignId: dtFairBidOptions.banner.campaignId,
                                                     creativeId: dtFairBidOptions.banner.creativeId,
                                                     bulkModeEnabled: settings.bulkModeEnabled) as! T.Options
                       
                   default: fatalError("There should not be HB with thumbnail")
               }
                
            @unknown default:
                fatalError("Options for AdType \"\(adType)\" not handled")
        }
    }
}
