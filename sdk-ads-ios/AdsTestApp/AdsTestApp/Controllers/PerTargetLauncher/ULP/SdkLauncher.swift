//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import UIKit
import AdsCardLibrary
import Foundation
import UnityLevelPlayCardAdapter
import AdsCardAdapter

struct SdkLauncher: SdkLaunchable {
    static var rootViewController: UIViewController!
    static var shared: any SdkLaunchable = SdkLauncher()
    let adapter: any AdsCardAdaptable
    lazy var logger: TestAppLogController = { TestAppLogController.shared }()
    
    private init() {
        self.adapter = UnityLevelPlayAdsCardAdapter(testSuiteViewController:SdkLauncher.rootViewController)
    }
    
    func launch() async { await startAds() }
    
    func startAds(forceStart: Bool = false) async {
        if SettingsController().startSDKWithApplication || forceStart {
            (0..<SettingsController().numberOfSdkStart).forEach { second in
                Task {
                    try? await Task.sleep(for: .seconds(second))
                    print("🫠 start SDK")
                    await self.adapter.startSdk()
                    self.adapter.setLogLevel(.all)
                    self.adapter.setAllowedTypes(["Publisher", "Internal", "Requests", "Mraid", "Monitoring", "SDK Callbacks"])
                }
            }
        }
    }
    
    static var assetKey: String {
        guard let asset = Bundle.main.infoDictionary?["AssetKey"] as? String else {
            return "OGY-98FE43C36168"
        }
        return asset
    }
}
