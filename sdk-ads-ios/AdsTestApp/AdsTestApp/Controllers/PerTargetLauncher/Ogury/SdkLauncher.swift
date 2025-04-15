//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import AdsCardLibrary
import Foundation
import OguryCardAdapter
import AdsCardAdapter

struct SdkLauncher {
    static let shared = SdkLauncher()
    let adapter: OguryAdsCardAdapter
    let logger = TestAppLogController.shared
    
    private init() {
        self.adapter = .init(assetKey: SdkLauncher.assetKey, environment: SdkLauncher.environment.oguryEnvironment)
        self.adapter.forceAdsEnvironment(SdkLauncher.environment)
    }
    
    func launch() { startAds() }
    private func forceAdsEnvironment() { adapter.forceAdsEnvironment(SdkLauncher.environment) }
    
    func startAds(forceStart: Bool = false) {
        if SettingsController().startSDKWithApplication || forceStart {
            forceAdsEnvironment()
            (0..<SettingsController().numberOfSdkStart).forEach { second in
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(second)) {
                    print("🫠 start SDK")
                    self.adapter.startSdk()
                }
            }
        }
    }
    
    static var assetKey: String {
        guard let asset = Bundle.main.infoDictionary?["AssetKey"] as? String else {
            return "OGY-669B2C04F486"
        }
        return asset
    }
    
    static private var environment: String {
        guard let asset = Bundle.main.infoDictionary?["DefaultEnv"] as? String else {
            return "PROD"
        }
        return asset
    }
}

private extension String {
    var oguryEnvironment: OguryEnvironement {
        switch self {
            case "DEVC": return .devc
            case "STAGING": return .staging
            default: return .prod
        }
    }
}
