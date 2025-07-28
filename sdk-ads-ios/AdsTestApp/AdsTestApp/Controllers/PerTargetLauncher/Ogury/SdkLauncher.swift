//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import AdsCardLibrary
import Foundation
import OguryCardAdapter
import AdsCardAdapter
import AdSupport
import UIKit

struct SdkLauncher: SdkLaunchable  {
    static var rootViewController: UIViewController!
    static let shared: any SdkLaunchable = SdkLauncher()
    let adapter: any AdsCardAdaptable
    lazy var logger: TestAppLogController = { TestAppLogController.shared }()
    
    private init() {
        self.adapter = OguryAdsCardAdapter(assetKey: SdkLauncher.assetKey, environment: SdkLauncher.environment.oguryEnvironment)
        (adapter as! OguryAdsCardAdapter).forceAdsEnvironment(SdkLauncher.environment)
    }
    
    func launch() async { await startAds() }
    private func forceAdsEnvironment() { (adapter as! OguryAdsCardAdapter).forceAdsEnvironment(SdkLauncher.environment) }
    
    func startAds(forceStart: Bool = false) async {
        if SettingsController().startSDKWithApplication || forceStart {
            forceAdsEnvironment()
            let nbOfStart = SettingsController().numberOfSdkStart
            (0..<nbOfStart).forEach { second in
                Task {
                    try? await Task.sleep(for: .seconds(Double(second) + 0.1))
                    print("🫠 start SDK")
                    await self.adapter.startSdk()
                    await self.adapter.setLogLevel(.all)
                    await self.adapter.setAllowedTypes(["Publisher", "Internal", "Requests", "Mraid", "Monitoring", "SDK Callbacks"])
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
