//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import UIKit
import AdsCardLibrary

extension Decodable {
    static func loadJsonFromFile(named fileName: String, extension extName: String? = nil) throws -> Self {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: extName),
              let json = try? Data(contentsOf: url) else {
            fatalError("No configuration file found")
        }
        let conf: Self = try JSONDecoder().decode(Self.self, from: json)
        return conf
    }
}

protocol MediationOptions: Codable {
    var interstitial: Configuration.DefaultBaseOptions { get }
    var optIn: Configuration.DefaultBaseOptions { get }
    var mpu: Configuration.DefaultBaseOptions { get }
    var banner: Configuration.DefaultBaseOptions { get }
    var thumbnail: Configuration.DefaultBaseOptions? { get }
    var url: URL? { get }
    var displayManager: String? { get }
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
        var displayManager: String?
    }
    struct DefaultMaxOptions: MediationOptions {
        let interstitial: DefaultBaseOptions
        let optIn: DefaultBaseOptions
        let mpu: DefaultBaseOptions
        let banner: DefaultBaseOptions
        let thumbnail: DefaultBaseOptions?
        let url: URL?
        var displayManager: String? { "max" }
    }
    struct DefaultDTFairBidOptions: MediationOptions {
        let interstitial: DefaultBaseOptions
        let optIn: DefaultBaseOptions
        let mpu: DefaultBaseOptions
        let banner: DefaultBaseOptions
        let thumbnail: DefaultBaseOptions?
        let url: URL?
        var displayManager: String? { "fyber" }
    }
    struct DefaultUnityLevelPlayOptions: MediationOptions {
        let interstitial: DefaultBaseOptions
        let optIn: DefaultBaseOptions
        let mpu: DefaultBaseOptions
        let banner: DefaultBaseOptions
        let thumbnail: DefaultBaseOptions?
        let url: URL?
        var displayManager: String? { "unity levelplay" }
    }
    let options: DefaultOptions
    let maxOptions: DefaultMaxOptions
    let dtFairBidOptions: DefaultDTFairBidOptions
    let unityLevelPlayOptions: DefaultUnityLevelPlayOptions
    
    enum CodingKeys: String, CodingKey {
        case max = "maxHeaderBidding"
        case dtFairBid = "DTFairBidHeaderBidding"
        case unityLevelPlay = "UnityLevelPlayHeaderBidding"
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.singleValueContainer()
        options = try rootContainer.decode(DefaultOptions.self)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        maxOptions = try container.decode(DefaultMaxOptions.self, forKey: .max)
        dtFairBidOptions = try container.decode(DefaultDTFairBidOptions.self, forKey: .dtFairBid)
        unityLevelPlayOptions = try container.decode(DefaultUnityLevelPlayOptions.self, forKey: .unityLevelPlay)
    }
    
    static let shared: Configuration = {
        guard let conf: Configuration = try? Configuration.loadJsonFromFile(named: "Default", extension: "json") else {
                fatalError("No configuration file found")
        }
        return conf
    } ()
    
    func options<T: OguryAdManager>(for adType: AdType<T>, index: Int?) -> T.Options {
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
                
               case let .unityLevelPlayHeaderBidding(innerType, _):
                   switch innerType {
                       case .interstitial:
                           return AdManagerOptions(showCampaignId:settings.showCampaignId,
                                                   showCreativeId:settings.showCreativeId,
                                                   showDspFields: settings.showDspFields,
                                                   showSpecificOptions:settings.showSpecificOptions,
                                                   viewController: UIViewController(),
                                                   adDisplayName: index == nil ? "" : "Card #\(index!)",
                                                   adUnitId: unityLevelPlayOptions.interstitial.adUnitId,
                                                   campaignId: unityLevelPlayOptions.interstitial.campaignId,
                                                   creativeId: unityLevelPlayOptions.interstitial.creativeId,
                                                   bulkModeEnabled: settings.bulkModeEnabled) as! T.Options
                           
                       case .rewarded:
                           return AdManagerOptions(showCampaignId:settings.showCampaignId,
                                                   showCreativeId:settings.showCreativeId,
                                                   showDspFields: settings.showDspFields,
                                                   showSpecificOptions:settings.showSpecificOptions,
                                                   viewController: UIViewController(),
                                                   adDisplayName: index == nil ? "" : "Card #\(index!)",
                                                   adUnitId: unityLevelPlayOptions.optIn.adUnitId,
                                                   campaignId: unityLevelPlayOptions.optIn.campaignId,
                                                   creativeId: unityLevelPlayOptions.optIn.creativeId,
                                                   bulkModeEnabled: settings.bulkModeEnabled) as! T.Options
                           
                       case .mpu:
                           return BannerAdManagerOptions(showCampaignId:settings.showCampaignId,
                                                         showCreativeId:settings.showCreativeId,
                                                         showDspFields: settings.showDspFields,
                                                         showSpecificOptions:settings.showSpecificOptions,
                                                         view: UIView(),
                                                         adDisplayName: index == nil ? "" : "Card #\(index!)",
                                                         adUnitId: unityLevelPlayOptions.mpu.adUnitId,
                                                         campaignId: unityLevelPlayOptions.mpu.campaignId,
                                                         creativeId: unityLevelPlayOptions.mpu.creativeId,
                                                         bulkModeEnabled: settings.bulkModeEnabled) as! T.Options
                           
                       case .banner:
                           return BannerAdManagerOptions(showCampaignId:settings.showCampaignId,
                                                         showCreativeId:settings.showCreativeId,
                                                         showDspFields: settings.showDspFields,
                                                         showSpecificOptions:settings.showSpecificOptions,
                                                         view: UIView(),
                                                         adDisplayName: index == nil ? "" : "Card #\(index!)",
                                                         adUnitId: unityLevelPlayOptions.banner.adUnitId,
                                                         campaignId: unityLevelPlayOptions.banner.campaignId,
                                                         creativeId: unityLevelPlayOptions.banner.creativeId,
                                                         bulkModeEnabled: settings.bulkModeEnabled) as! T.Options
                           
                       default: fatalError("There should not be HB with thumbnail")
                   }
                @unknown default:
                        fatalError("Options for AdType \"\(adType)\" not handled")
                }
    }
}
