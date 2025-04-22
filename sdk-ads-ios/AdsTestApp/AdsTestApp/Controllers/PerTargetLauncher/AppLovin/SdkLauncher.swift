//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import AdsCardLibrary
import Foundation
import MaxCardAdapter
import AdsCardAdapter

struct SdkLauncher {
    static let shared = SdkLauncher()
    let adapter: MaxAdsCardAdapter
    lazy var logger: TestAppLogController = { TestAppLogController.shared }()
    
    private init() {
        self.adapter = .init()
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
            return "OGY-3D6E42683F56"
        }
        return asset
    }
}
