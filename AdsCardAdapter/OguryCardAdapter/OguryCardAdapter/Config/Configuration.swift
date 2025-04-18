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
    let assetKey: String
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
        assetKey = ""
    }
    
    init(from assetKey: String, environment: OguryEnvironement) {
        guard let conf: Configuration = try? Configuration.loadJsonFromFile(bundle: Bundle(for: InterstitialAdManager.self),
                                                                            named: environment.fileName,
                                                                            extension: "json") else {
            fatalError("No configuration file found")
        }
        self.assetKey = assetKey
        options = conf.options
        maxOptions = conf.maxOptions
        dtFairBidOptions = conf.dtFairBidOptions
        unityLevelPlayOptions = conf.unityLevelPlayOptions
    }
}

extension OguryEnvironement {
    var fileName: String {
        switch self {
            case .devc: return "Default.devc"
            case .staging: return "Default.staging"
            case .prod: return "Default.prod"
        }
    }
}
