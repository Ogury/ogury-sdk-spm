//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import Foundation
import OguryAds

class AdsInterstitialController: NSObject, AdsFullscreenController {
    
    static let shared = AdsInterstitialController()

    weak var delegate: AdControllerDelegate?

    var viewController: UIViewController?

    lazy var interstitialAd: OguryInterstitialAd = {
        let instance = OguryInterstitialAd(adUnitId: "")
        instance.delegate = self
        return instance
    }()

    override init() {
    }

    func getInterstitialAd(adUnitId: String) -> OguryInterstitialAd {
        if (interstitialAd.adUnitId != adUnitId) {
            let instance = OguryInterstitialAd(adUnitId: adUnitId)
            instance.delegate = self
            interstitialAd = instance
        }
        return interstitialAd
    }

    func load(adUnitId: String, campaignId: String? = nil, creativeId: String? = nil, dspCreativeId: String? = nil, dspRegion: String? = nil) {
        let interstitialAd = getInterstitialAd(adUnitId: adUnitId)
        if let campaignId = campaignId, !campaignId.isEmpty, let creativeId = creativeId, !creativeId.isEmpty, let dspCreativeId = dspCreativeId, !dspCreativeId.isEmpty, let dspRegion = dspRegion, !dspRegion.isEmpty {
            let obj = self.interstitialAd
            let sel = NSSelectorFromString("loadWithCampaignId:creativeId:dspCreativeId:dspRegion:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String, String, String, String) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId, creativeId, dspCreativeId, dspRegion)
        } else if let campaignId = campaignId, !campaignId.isEmpty, let creativeId = creativeId, !creativeId.isEmpty {
            let obj = self.interstitialAd
            let sel = NSSelectorFromString("loadWithCampaignId:creativeId:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String, String) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId, creativeId)
        } else if let campaignId = campaignId, !campaignId.isEmpty {
            let obj = self.interstitialAd
            let sel = NSSelectorFromString("loadWithCampaignId:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId)
        } else {
            interstitialAd.load()
        }
    }

    func loadWithHeaderBidding(adUnitId: String, country: String?, campaignId: String?, creativeId: String?, dspCreativeId: String? = nil, dspRegion: String? = nil, in viewController: UIViewController) {
        self.viewController = viewController

        guard let assetKey = AdConfigController.shared.assetKey() else {
            print("FAILED TO RETRIEVE ASSET KEY FOR HB")
            return
        }

        HeaderBiddingService.retrieveAdMarkup(assetKey: assetKey, adUnitId: adUnitId, country: country, campaignId: campaignId, creativeId: creativeId, dspCreativeId: dspCreativeId, dspRegion: dspRegion) { result in
            switch result {
                case .success(let adMarkup):
                    let interstitialAd = self.getInterstitialAd(adUnitId: adUnitId)
                    interstitialAd.load(withAdMarkup: adMarkup)
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.delegate?.didFail()
                    }
                    LogsController.shared.addLogs("Header bidding for Interstitial failed. [\(error.localizedDescription)]")
            }
        }
    }

    func show(in viewController: UIViewController) {
        interstitialAd.show(in: viewController)
    }

    func loadAndShow(adUnitId: String, campaignId: String?, creativeId: String?, dspCreativeId: String?, dspRegion: String?, in viewController: UIViewController) {
        self.viewController = viewController
        load(adUnitId: adUnitId, campaignId: campaignId, creativeId: creativeId, dspCreativeId: creativeId, dspRegion: dspRegion)
    }
    
    func isLoaded() -> Bool {
        return interstitialAd.isLoaded()
    }
}

extension AdsInterstitialController: OguryInterstitialAdDelegate {

    func didLoad(_ interstitial: OguryInterstitialAd) {
        if let viewController = viewController {
            show(in: viewController)
        }
        viewController = nil
        LogsController.shared.addLogs("Interstitial ad loaded.")
    }

    func didFailOguryInterstitialAdWithError(_ error: OguryError, for interstitial: OguryInterstitialAd) {
        delegate?.didFail()

        LogsController.shared.addLogs(String(format: "Interstitial ad failed with error code %ld: %@", error.code, error.localizedDescription));
    }

    func didDisplay(_ interstitial: OguryInterstitialAd) {
        delegate?.didDisplay()

        LogsController.shared.addLogs("Interstitial ad displayed.")
    }

    func didClick(_ interstitial: OguryInterstitialAd) {
        LogsController.shared.addLogs("Interstitial ad clicked.")
    }

    func didClose(_ interstitial: OguryInterstitialAd) {
        LogsController.shared.addLogs("Interstitial ad closed.")
    }
    
    func didTriggerImpressionOguryInterstitialAd(_ interstitial: OguryInterstitialAd) {
        LogsController.shared.addLogs("Interstitial ad impression")
    }
}
