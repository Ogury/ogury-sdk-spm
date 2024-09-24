//
//  AdThumbnailController.swift
//  OguryAdsTestApp
//
//  Created by Pernic on 11/06/2020.
//  Copyright © 2020 co.ogury. All rights reserved.
//

import Foundation
import OguryAds
import RxSwift

class AdsThumbnailController: NSObject, ThumbnailController {

    static let shared = AdsThumbnailController()

    weak var delegate: AdControllerDelegate?

    var showAt: CGPoint?
    var corner: OguryRectCorner?
    var showAfterLoad = false
    var blackListVC = [String]()
    let disposeBag = DisposeBag()

    lazy var thumbnail: OguryThumbnailAd = {
        let instance = OguryThumbnailAd(adUnitId: "")
        instance.delegate = self
        return instance
    }()

    func getThumbnailAd(adUnitId: String) -> OguryThumbnailAd {
        if (thumbnail.adUnitId != adUnitId) {
            let instance = OguryThumbnailAd(adUnitId: adUnitId)
            instance.delegate = self
            thumbnail = instance
        }
        return thumbnail
    }

    override init() {
        super.init()
        self.setupRX()
    }

    func setupRX() {
        RxSettings.shared
                .blacklistCellsObservable
                .subscribe { [weak self] blackListVC in
                    guard let blackListVC = blackListVC.element else {
                        return
                    }

                    self?.blackListVC = blackListVC
                }
                .disposed(by: disposeBag)
    }

    func load(adUnitId: String, campaignId: String? = nil, creativeId: String? = nil, dspCreativeId: String? = nil, dspRegion: String? = nil, maxSize: CGSize? = nil) {
        thumbnail = getThumbnailAd(adUnitId: adUnitId)
        thumbnail.setBlacklistViewControllers(blackListVC)
        DispatchQueue.main.async {
            if let campaignId = campaignId, !campaignId.isEmpty, let creativeId = creativeId, !creativeId.isEmpty, let dspCreativeId = dspCreativeId, !dspCreativeId.isEmpty, let dspRegion = dspRegion, !dspRegion.isEmpty {
                if maxSize != nil {
                    let obj = self.thumbnail
                    let sel = NSSelectorFromString("loadWithCampaignId:creativeId:dspCreativeId:dspRegion:thumbnailSize:")
                    let meth = class_getInstanceMethod(object_getClass(obj), sel)
                    let imp = method_getImplementation(meth!)
                    typealias ClosureType = @convention(c) (AnyObject, Selector, String, String, String, String, CGSize) -> Void
                    let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
                    sayHiTo(obj, sel, campaignId, creativeId, dspCreativeId, dspRegion, maxSize!)
                } else {
                    let obj = self.thumbnail
                    let sel = NSSelectorFromString("loadWithCampaignId:creativeId:dspCreativeId:dspRegion:")
                    let meth = class_getInstanceMethod(object_getClass(obj), sel)
                    let imp = method_getImplementation(meth!)
                    typealias ClosureType = @convention(c) (AnyObject, Selector, String, String, String, String) -> Void
                    let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
                    sayHiTo(obj, sel, campaignId, creativeId,  dspCreativeId, dspRegion)
                }
            } else if let campaignId = campaignId, !campaignId.isEmpty, let creativeId = creativeId, !creativeId.isEmpty {
                if maxSize != nil {
                    let obj = self.thumbnail
                    let sel = NSSelectorFromString("loadWithCampaignId:creativeId:thumbnailSize:")
                    let meth = class_getInstanceMethod(object_getClass(obj), sel)
                    let imp = method_getImplementation(meth!)
                    typealias ClosureType = @convention(c) (AnyObject, Selector, String, String, CGSize) -> Void
                    let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
                    sayHiTo(obj, sel, campaignId,creativeId, maxSize!)
                } else {
                    let obj = self.thumbnail
                    let sel = NSSelectorFromString("loadWithCampaignId:creativeId:")
                    let meth = class_getInstanceMethod(object_getClass(obj), sel)
                    let imp = method_getImplementation(meth!)
                    typealias ClosureType = @convention(c) (AnyObject, Selector, String, String) -> Void
                    let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
                    sayHiTo(obj, sel, campaignId, creativeId)
                }
            } else if let campaignId = campaignId, !campaignId.isEmpty {
                if maxSize != nil {
                    let obj = self.thumbnail
                    let sel = NSSelectorFromString("loadWithCampaignId:thumbnailSize:")
                    let meth = class_getInstanceMethod(object_getClass(obj), sel)
                    let imp = method_getImplementation(meth!)
                    typealias ClosureType = @convention(c) (AnyObject, Selector, String, CGSize) -> Void
                    let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
                    sayHiTo(obj, sel, campaignId, maxSize!)
                } else {
                    let obj = self.thumbnail
                    let sel = NSSelectorFromString("loadWithCampaignId:")
                    let meth = class_getInstanceMethod(object_getClass(obj), sel)
                    let imp = method_getImplementation(meth!)
                    typealias ClosureType = @convention(c) (AnyObject, Selector, String) -> Void
                    let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
                    sayHiTo(obj, sel, campaignId)
                }
            } else {
                if maxSize != nil {
                    self.thumbnail.load(maxSize!)
                } else {
                    self.thumbnail.load()
                }
            }
        }
    }

    func show(at point: CGPoint? = nil, withCorner corner: OguryRectCorner? = nil) {
        if corner != nil && point != nil {
            DispatchQueue.main.async {
                self.thumbnail.show(with: corner!, margin: OguryOffset(x: point!.x, y: point!.y))
            }
            return
        }
        if point != nil {
            DispatchQueue.main.async {
                self.thumbnail.show(point!)
            }
            return
        }
        DispatchQueue.main.async {
            self.thumbnail.show()
        }
    }

    func loadAndShow(adUnitId: String,
                     campaignId: String?,
                     creativeId: String?,
                     dspCreativeId: String?,
                     dspRegion: String?,
                     maxSize: CGSize? = nil,
                     showAt: CGPoint? = nil,
                     withCorner corner: OguryRectCorner? = nil) {
        showAfterLoad = true
        self.showAt = showAt
        self.corner = corner
        load(adUnitId: adUnitId, campaignId: campaignId, creativeId: creativeId,dspCreativeId: dspCreativeId, dspRegion: dspRegion, maxSize: maxSize)
    }

    func isLoaded() -> Bool {
        self.thumbnail.isLoaded()
    }
}

extension AdsThumbnailController: OguryThumbnailAdDelegate {

    func didLoad(_ thumbnail: OguryThumbnailAd) {
        LogsController.shared.addLogs("thumbnail loaded.");
        if (showAfterLoad) {
            show(at: self.showAt, withCorner: self.corner)
            showAt = nil
            corner = nil
            showAfterLoad = false
        }

        LogsController.shared.addLogs("Thumbnail ad is expanded at load ? [\(thumbnail.isExpanded)]")
    }

    func didFailOguryThumbnailAdWithError(_ error: OguryAdError, for thumbnail: OguryThumbnailAd) {
        delegate?.didFail()

        LogsController.shared.addLogs(String(format: "thumbnail failed with error code %ld: %@", error.code, error.localizedDescription));
    }

    func didDisplay(_ thumbnail: OguryThumbnailAd) {
        delegate?.didDisplay()

        LogsController.shared.addLogs("thumbnail displayed.")

        LogsController.shared.addLogs("Thumbnail ad is expanded at display ? [\(thumbnail.isExpanded)]")
    }

    func didClick(_ thumbnail: OguryThumbnailAd) {
        LogsController.shared.addLogs("thumbnail clicked.")

        DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime.now() + 1) { [unowned thumbnail] in
            LogsController.shared.addLogs("Thumbnail ad is expanded after click ? [\(thumbnail.isExpanded)]")
        }
    }

    func didClose(_ thumbnail: OguryThumbnailAd) {
        LogsController.shared.addLogs("thumbnail closed.")

        LogsController.shared.addLogs("Thumbnail ad is expanded at close ? [\(thumbnail.isExpanded)]")
    }
    
    func didTriggerImpressionOguryThumbnailAd(_ thumbnail: OguryThumbnailAd) {
        LogsController.shared.addLogs("thumbnail impression.")
    }
}
