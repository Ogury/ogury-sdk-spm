//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import AdsCardLibrary
import Foundation 
import OguryChoiceManager
import OguryAds.Private

struct AdSdkLauncher {
    static let shared = AdSdkLauncher()
    let persistentBus = OguryPersistentEventBus()
    let broadcastBus = OguryEventBus()
    
    private init() {}
    
    func launch() {
        startCMP()
        startAds()
    }
    
    func startAds(forceStart: Bool = false) {
        if SettingsController().startSDKWithApplication || forceStart {
            forceAdsEnvironment()
            startModule(from: "OGAInternal")
        }
    }
    
    private func startCMP() {
        forceCMPEnvironment()
        startModule(from: "OGYInternal")
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
    
    private func forceCMPEnvironment() {
        let obj = OguryChoiceManager.shared()
        let sel = NSSelectorFromString("forceEnvironment:")
        let meth = class_getInstanceMethod(object_getClass(obj), sel)
        let imp = method_getImplementation(meth!)
        typealias ClosureType = @convention(c) (AnyObject, Selector, Int) -> Void
        let sayHiTo = unsafeBitCast(imp, to: ClosureType.self)
        sayHiTo(obj, sel, environmentRawValue)
    }
    
    private func forceAdsEnvironment() {
        let sel = NSSelectorFromString("changeServerEnvironment:")
        OGAInternal.shared().perform(sel, with: environment)
    }
    
    private func startModule(from moduleClass: String) {
        let module = OGYModule(className: moduleClass)
        module.start(withAssetKey: assetKey, persistentEventBus: persistentBus, broadcast: broadcastBus)
    }
}
