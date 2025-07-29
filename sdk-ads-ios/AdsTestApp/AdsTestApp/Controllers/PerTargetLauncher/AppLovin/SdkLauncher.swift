//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import UIKit
import AdsCardLibrary
import Foundation
import MaxCardAdapter
import AdsCardAdapter
import AppLovinSDK

struct SdkLauncher: SdkLaunchable {
    static var rootViewController: UIViewController!
    static var shared: any SdkLaunchable = SdkLauncher()
    let adapter: any AdsCardAdaptable
    lazy var logger: TestAppLogController = { TestAppLogController.shared }()
    
    private init() {
        self.adapter = MaxAdsCardAdapter()
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
            return "OGY-3D6E42683F56"
        }
        return asset
    }
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake { ALSdk.shared().showMediationDebugger() }
    }
}
