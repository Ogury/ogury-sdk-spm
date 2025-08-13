//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import UIKit
import AdsCardLibrary

protocol MediationOptions: Codable {
    var interstitial: Configuration.DefaultBaseOptions { get }
    var standardBanner: Configuration.DefaultBaseOptions { get }
}

struct Configuration: Decodable {
    struct DefaultBaseOptions: Codable {
        let adUnitId: String
        let campaignId: String?
        let creativeId: String?
    }
    struct DefaultOptions: MediationOptions {
        let interstitial: DefaultBaseOptions
        let standardBanner: DefaultBaseOptions
    }
    let url: String
    let assetKey: String
    let options: DefaultOptions
    
    
    enum CodingKeys: String, CodingKey {
        case options
        case url
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        options = try rootContainer.decode(DefaultOptions.self, forKey: .options)
        url = try rootContainer.decode(String.self, forKey: .url)
        assetKey = ""
    }
    
    init(from assetKey: String, environment: OguryEnvironement) {
        guard let conf: Configuration = try? Configuration.loadJsonFromFile(bundle: Bundle(for: PrebidAdManager.self),
                                                                            named: environment.fileName,
                                                                            extension: "json") else {
            fatalError("No configuration file found")
        }
        self.assetKey = assetKey
        options = conf.options
        url = conf.url
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
