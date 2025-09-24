//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import UIKit
import AdsCardLibrary
import Foundation
import PrebidCardAdapter
import AdsCardAdapter

struct SdkLauncher: SdkLaunchable {
    static var rootViewController: UIViewController!
    static var shared: any SdkLaunchable = SdkLauncher()
    let adapter: any AdsCardAdaptable
    lazy var logger: TestAppLogController = { TestAppLogController.shared }()
    
    private init() {
        self.adapter = PrebidAdsCardAdapter(assetKey: Self.assetKey, environment: SdkLauncher.environment.oguryEnvironment)
    }
    
    func launch() async { await startAds() }
    
    func startAds(forceStart: Bool = false) async {
        if SettingsController().startSDKWithApplication || forceStart {
            (0..<SettingsController().numberOfSdkStart).forEach { second in
                Task {
                    try? await Task.sleep(for: .seconds(second))
                    print("🫠 start SDK")
                    await self.adapter.startSdk()
                }
            }
        }
    }
    
    static var assetKey: String {
        guard let asset = Bundle.main.infoDictionary?["AssetKey"] as? String else {
            return "OGY-C2896793E224"
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
