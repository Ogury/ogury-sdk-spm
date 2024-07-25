//
//  Copyright © 2020 co.ogury All rights reserved.
//

import Foundation
import OguryAds

class AdsOptinVideoController: NSObject, AdsFullscreenController {

    static let shared = AdsOptinVideoController()

    weak var delegate: AdControllerDelegate?

    var viewController: UIViewController?

    lazy var optInVideoAd: OguryOptinVideoAd = {
        let instance = OguryOptinVideoAd(adUnitId: "")
        instance.delegate = self
        return instance
    }()

    override init() {
    }

    func getOptinVideoAd(adUnitId: String) -> OguryOptinVideoAd {
        if (optInVideoAd.adUnitId != adUnitId) {
            let instance = OguryOptinVideoAd(adUnitId: adUnitId)
            instance.delegate = self
            optInVideoAd = instance
        }
        return optInVideoAd
    }
    
    func load(adUnitId: String, campaignId: String? = nil, creativeId: String? = nil, dspCreativeId: String? = nil, dspRegion: String? = nil) {
        let optInVideoAd = getOptinVideoAd(adUnitId: adUnitId)
        if let campaignId = campaignId, !campaignId.isEmpty, let creativeId = creativeId, !creativeId.isEmpty, let dspCreativeId = dspCreativeId, !dspCreativeId.isEmpty, let dspRegion = dspRegion, !dspRegion.isEmpty {
            let obj = self.optInVideoAd
            let sel = NSSelectorFromString("loadWithCampaignId:creativeId:dspCreativeId:dspRegion:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String, String, String, String) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId, creativeId, dspCreativeId, dspRegion)
        } else if let campaignId = campaignId, !campaignId.isEmpty, let creativeId = creativeId, !creativeId.isEmpty {
            let obj = self.optInVideoAd
            let sel = NSSelectorFromString("loadWithCampaignId:creativeId:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String, String) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId, creativeId)
        } else if let campaignId = campaignId, !campaignId.isEmpty {
            let obj = self.optInVideoAd
            let sel = NSSelectorFromString("loadWithCampaignId:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId)
        } else {
            optInVideoAd.load()
        }
    }

    func show(in viewController: UIViewController) {
        optInVideoAd.show(in: viewController)
    }

    func loadAndShow(adUnitId: String, campaignId: String?, creativeId: String?, dspCreativeId: String?, dspRegion: String?, in viewController: UIViewController) {
        self.viewController = viewController
        load(adUnitId: adUnitId, campaignId: campaignId, creativeId: creativeId, dspCreativeId: creativeId, dspRegion: dspRegion)
    }
    
    func isLoaded() -> Bool {
        optInVideoAd.isLoaded()
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
                    let optInAd = self.getOptinVideoAd(adUnitId: adUnitId)
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

extension AdsOptinVideoController: OguryOptinVideoAdDelegate {

    func didLoad(_ optinVideo: OguryOptinVideoAd) {
        if let viewController = viewController {
            show(in: viewController)
        }
        viewController = nil
        LogsController.shared.addLogs("Opt-in video ad loaded.");
    }

    func didFailOguryOptinVideoAdWithError(_ error: OguryError, for optinVideo: OguryOptinVideoAd) {
        delegate?.didFail()

        LogsController.shared.addLogs(String(format: "Opt-in video ad failed with error code %ld: %@", error.code, error.localizedDescription));
    }

    func didDisplay(_ optinVideo: OguryOptinVideoAd) {
        delegate?.didDisplay()

        LogsController.shared.addLogs("Opt-in video ad displayed.")
    }

    func didClick(_ optinVideo: OguryOptinVideoAd) {
        LogsController.shared.addLogs("Opt-in video ad clicked.")
    }

    func didClose(_ optinVideo: OguryOptinVideoAd) {
        LogsController.shared.addLogs("Opt-in video ad closed.")
    }

    func didRewardOguryOptinVideoAd(with item: OGARewardItem, for optinVideo: OguryOptinVideoAd) {
        LogsController.shared.addLogs("Opt-in video ad rewarded with \(item.rewardName) - value : \(item.rewardValue).")
    }
    
    func didTriggerImpressionOguryOptinVideoAd(_ optinVideo: OguryOptinVideoAd) {
        LogsController.shared.addLogs("Opt-in impression")
    }
}
