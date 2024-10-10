//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import AdsCardLibrary
import Foundation

struct AdSdkLauncher {
    static let shared = AdSdkLauncher()
    let launcher = OguryAdsPrivateLauncher()
    
    private init() {}
    
    func launch() {
        startAds()
    }
    
    func startAds(forceStart: Bool = false) {
        if SettingsController().startSDKWithApplication || forceStart {
            forceAdsEnvironment()
            launcher.start(with: assetKey)
        }
    }
    
    var assetKey: String {
        guard let asset = Bundle.main.infoDictionary?["AssetKey"] as? String else {
            return "OGY-669B2C04F486"
        }
        return asset
    }
    
    private var environment: String {
        guard let asset = Bundle.main.infoDictionary?["DefaultEnv"] as? String else {
            return "PROD"
        }
        return asset
    }
    
    private var environmentRawValue: Int {
        guard let asset = Bundle.main.infoDictionary?["DefaultEnv"] as? String else {
            return 0
        }
        switch asset {
            case "PROD": return 0
            case "STAGING": return 1
            case "DEVC": return 2
            default: return 0
        }
    }
    
    private func forceAdsEnvironment() {
        let sel = NSSelectorFromString("changeServerEnvironment:")
        launcher.changeEnvironment(to: environment)
    }
}
