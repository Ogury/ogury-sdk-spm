//
//  Copyright © 2020 co.ogury All rights reserved.
//

import Foundation
import OguryAds

class AdsOptinVideoController: NSObject, AdsFullscreenController {

    static let shared = AdsOptinVideoController()

    weak var delegate: AdControllerDelegate?

    var viewController: UIViewController?

    lazy var RewardedAd: OguryRewardedAd = {
        let instance = OguryRewardedAd(adUnitId: "")
        instance.delegate = self
        return instance
    }()

    override init() {
    }

    func getRewardedAd(adUnitId: String) -> OguryRewardedAd {
        if (RewardedAd.adUnitId != adUnitId) {
            let instance = OguryRewardedAd(adUnitId: adUnitId)
            instance.delegate = self
            RewardedAd = instance
        }
        return RewardedAd
    }
    
    func load(adUnitId: String, campaignId: String? = nil, creativeId: String? = nil, dspCreativeId: String? = nil, dspRegion: String? = nil) {
        let RewardedAd = getRewardedAd(adUnitId: adUnitId)
        if let campaignId = campaignId, !campaignId.isEmpty, let creativeId = creativeId, !creativeId.isEmpty, let dspCreativeId = dspCreativeId, !dspCreativeId.isEmpty, let dspRegion = dspRegion, !dspRegion.isEmpty {
            let obj = self.RewardedAd
            let sel = NSSelectorFromString("loadWithCampaignId:creativeId:dspCreativeId:dspRegion:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String, String, String, String) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId, creativeId, dspCreativeId, dspRegion)
        } else if let campaignId = campaignId, !campaignId.isEmpty, let creativeId = creativeId, !creativeId.isEmpty {
            let obj = self.RewardedAd
            let sel = NSSelectorFromString("loadWithCampaignId:creativeId:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String, String) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId, creativeId)
        } else if let campaignId = campaignId, !campaignId.isEmpty {
            let obj = self.RewardedAd
            let sel = NSSelectorFromString("loadWithCampaignId:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId)
        } else {
            RewardedAd.load()
        }
    }

    func show(in viewController: UIViewController) {
        RewardedAd.show(in: viewController)
    }

    func loadAndShow(adUnitId: String, campaignId: String?, creativeId: String?, dspCreativeId: String?, dspRegion: String?, in viewController: UIViewController) {
        self.viewController = viewController
        load(adUnitId: adUnitId, campaignId: campaignId, creativeId: creativeId, dspCreativeId: creativeId, dspRegion: dspRegion)
    }
    
    func isLoaded() -> Bool {
        RewardedAd.isLoaded()
    }
}

extension AdsOptinVideoController {
    func loadWithHeaderBidding(adUnitId: String, country: String?, campaignId: String?, creativeId: String?, dspCreativeId: String? = nil, dspRegion: String? = nil, in viewController: UIViewController) {
        self.viewController = viewController
        
        guard let assetKey = AdConfigController.shared.assetKey() else {
            print("FAILED TO RETRIEVE ASSET KEY FOR HB")
            return
        }
        
        HeaderBiddingService.retrieveAdMarkup(assetKey: assetKey, adUnitId: adUnitId, country: country, campaignId: campaignId, creativeId: creativeId, dspCreativeId: dspCreativeId, dspRegion: dspRegion) { result in
            switch result {
                case .success(let adMarkup):
                    let optInAd = self.getRewardedAd(adUnitId: adUnitId)
                    optInAd.load(withAdMarkup: adMarkup)
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.delegate?.didFail()
                    }
                    LogsController.shared.addLogs("Header bidding for Interstitial failed. [\(error.localizedDescription)]")
            }
        }
    }
}

extension AdsOptinVideoController: OguryRewardedAdDelegate {
    func rewardedAdDidLoad(_ rewardedAd: OguryRewardedAd) {
        if let viewController = viewController {
                show(in: viewController)
        }
        viewController = nil
        LogsController.shared.addLogs("Opt-in video ad loaded.");
    }

    func rewardedAd(_ rewardedAd: OguryRewardedAd, didFailWithError error: OguryAdError) {
        delegate?.didFail()

        LogsController.shared.addLogs(String(format: "Opt-in video ad failed with error code %ld: %@", error.code, error.localizedDescription));
    }

    func rewardedAdDidClick(_ rewardedAd: OguryRewardedAd) {
        LogsController.shared.addLogs("Opt-in video ad clicked.")
    }

    func rewardedAdDidClose(_ rewardedAd: OguryRewardedAd) {
        LogsController.shared.addLogs("Opt-in video ad closed.")
    }

    func rewardedAd(_ rewardedAd: OguryRewardedAd, didReceive item: OguryRewardItem) {
        LogsController.shared.addLogs("Opt-in video ad rewarded with \(item.rewardName) - value : \(item.rewardValue).")
    }
    
    func rewardedAdDidTriggerImpression(_ rewardedAd: OguryRewardedAd) {
        LogsController.shared.addLogs("Opt-in impression")
    }
}
