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
    
    func options(at index: Int?) -> AdManagerOptions {
        let settings = SettingsController()
        return AdManagerOptions(showCampaignId:settings.showCampaignId,
                                showCreativeId:settings.showCreativeId,
                                showDspFields: settings.showDspFields,
                                adDisplayName: index == nil ? "" : "Card #\(index!)",
                                adUnitId: options.interstitial.adUnitId,
                                campaignId: options.interstitial.campaignId,
                                creativeId: options.interstitial.creativeId,
                                dspCreativeId: options.interstitial.dspCreativeId,
                                dspRegion: options.interstitial.dspRegion,
                                bulkModeEnabled: settings.bulkModeEnabled)
    }
}
