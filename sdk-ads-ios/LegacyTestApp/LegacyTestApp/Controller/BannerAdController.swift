//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import Foundation
import OguryAds
import RxSwift

final class BannerAdController: NSObject, BannerFormatController {

    // MARK: - Properties

    var identifier: Int
    var banner: OguryBannerAdView?

    // MARK: - Initialization

    init(identifier: Int) {
        self.identifier = identifier
    }

    // MARK: - Functions

    func getAd(adUnitId: String) -> OguryBannerAdView {
        let instance = OguryBannerAdView(adUnitId: adUnitId, size: .small_banner_320x50())
        instance.delegate = self
        banner = instance
        return instance
    }

    func load(adUnitId: String, campaignId: String? = nil, creativeId:String? = nil, dspCreativeId:String? = nil, dspRegion:String? = nil, maxSize: OguryAdsBannerSize, inView view: UIView?, withWidth width: CGFloat? = nil) {
        let bannerAd = getAd(adUnitId: adUnitId)

        if let campaignId = campaignId, !campaignId.isEmpty, let creativeId = creativeId, !creativeId.isEmpty, let dspCreativeId = dspCreativeId, !dspCreativeId.isEmpty, let dspRegion = dspRegion, !dspRegion.isEmpty {
            let obj = bannerAd
            let sel = NSSelectorFromString("loadWithCampaignId:creativeId:dspCreativeId:dspRegion:size:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String, String, String, String, OguryAdsBannerSize) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId, creativeId, dspCreativeId, dspRegion, maxSize)

            if bannerAd.frame.equalTo(CGRect.zero) {
                bannerAd.frame = CGRect(x: 0, y: 0, width: width ?? maxSize.getSize().width, height: maxSize.getSize().height)
            }

            if let view = view, !view.subviews.contains(bannerAd) {
                view.addSubview(bannerAd)
            }

            view?.bringSubviewToFront(bannerAd)

            banner = bannerAd
        } else if let campaignId = campaignId, !campaignId.isEmpty, let creativeId = creativeId, !creativeId.isEmpty {
            let obj = bannerAd
            let sel = NSSelectorFromString("loadWithCampaignId:creativeId:size:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String, String, OguryAdsBannerSize) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId, creativeId, maxSize)

            if bannerAd.frame.equalTo(CGRect.zero) {
                bannerAd.frame = CGRect(x: 0, y: 0, width: width ?? maxSize.getSize().width, height: maxSize.getSize().height)
            }

            if let view = view, !view.subviews.contains(bannerAd) {
                view.addSubview(bannerAd)
            }

            view?.bringSubviewToFront(bannerAd)

            banner = bannerAd
        } else if let campaignId = campaignId, !campaignId.isEmpty {
            let obj = bannerAd
            let sel = NSSelectorFromString("loadWithCampaignId:size:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, String, OguryAdsBannerSize) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, campaignId, maxSize)

            if bannerAd.frame.equalTo(CGRect.zero) {
                bannerAd.frame = CGRect(x: 0, y: 0, width: width ?? maxSize.getSize().width, height: maxSize.getSize().height)
            }

            if let view = view, !view.subviews.contains(bannerAd) {
                view.addSubview(bannerAd)
            }

            view?.bringSubviewToFront(bannerAd)

            banner = bannerAd
        } else {
            bannerAd.load()
        }
    }

    func destroy() {
        banner?.removeFromSuperview()
        banner?.destroy()
        banner = nil
    }
    
    func isLoaded() -> Bool {
        guard let banner = self.banner else {
            return false
        }

        return banner.isLoaded
    }
}

extension BannerAdController {
    func loadWithHeaderBidding(adUnitId: String,
                               country: String?,
                               campaignId: String?,
                               creativeId: String?,
                               dspCreativeId: String?,
                               dspRegion: String?,
                               maxSize: OguryAdsBannerSize,
                               preferredWidth width: CGFloat? = nil,
                               in view: UIView?) {
        guard let assetKey = AdConfigController.shared.assetKey() else {
            print("FAILED TO RETRIEVE ASSET KEY FOR HB")
            return
        }
        
        HeaderBiddingService.retrieveAdMarkup(assetKey: assetKey, adUnitId: adUnitId, country: country, campaignId: campaignId, creativeId: creativeId, dspCreativeId: dspCreativeId, dspRegion: dspRegion) { result in
            
            DispatchQueue.main.async {
                let bannerAd = self.getAd(adUnitId: adUnitId)
                switch result {
                    case .success(let adMarkup):
                        
                            if bannerAd.frame.equalTo(CGRect.zero) {
                                bannerAd.frame = CGRect(x: 0, y: 0, width: width ?? maxSize.getSize().width, height: maxSize.getSize().height)
                            }
                            
                            if let view = view, !view.subviews.contains(bannerAd) {
                                view.addSubview(bannerAd)
                            }
                            
                            view?.bringSubviewToFront(bannerAd)
                            bannerAd.load(withAdMarkup: adMarkup)
                    
                    case .failure(let error):
                            self.didFail(bannerAd, error: OguryAdError.createOguryError(withCode: -1, localizedDescription: error.localizedDescription))
                                    LogsController.shared.addLogs("Header bidding for Interstitial failed. [\(error.localizedDescription)]")
                }
            }
        }
    }
}

// MARK: - OguryBannerAdDelegate

extension BannerAdController: OguryBannerAdDelegate {

    func didLoad(_ banner: OguryBannerAdView) {
        LogsController.shared.addLogs("Banner ad loaded")

        LogsController.shared.addLogs("Banner ad is expanded at load ? [\(banner.isExpanded)]")
    }

    func didFail(_ banner: OguryBannerAdView, error: OguryAdError) {
        LogsController.shared.addLogs("Banner ad failed with error code \(error.code): \(error.localizedDescription)");
        banner.removeFromSuperview()
    }

    func didDisplay(_ banner: OguryBannerAdView) {
        LogsController.shared.addLogs("Banner ad displayed")
    }

    func didClick(_ banner: OguryBannerAdView) {
        LogsController.shared.addLogs("Banner ad clicked")

        DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime.now() + 1) { [unowned banner] in
            LogsController.shared.addLogs("Banner ad is expanded after click ? [\(banner.isExpanded)]")
        }
    }

    func didClose(_ banner: OguryBannerAdView) {
        LogsController.shared.addLogs("Banner ad closed")
        banner.removeFromSuperview()
    }
    
    func didTriggerImpressionOguryBannerAdView(_ banner: OguryBannerAdView) {
        LogsController.shared.addLogs("Banner ad impression")
    }
    
}
