//
//  ULPBannerAdManager.swift
//  UnityLevelPlayCardAdapter
//
//  Created by Jerome TONNELIER on 07/05/2025.
//

import UIKit
import IronSource
import AdsCardAdapter
import AdsCardLibrary
import SwiftUI

internal class BannerAdManagerSize: AdsCardLibrary.BannerSize {
    let internalSize: LPMAdSize!
    init(internalSize: LPMAdSize!, image: Image) {
        self.internalSize = internalSize
        super.init(size: CGSize(width: internalSize.width, height: internalSize.height), image: image)
    }
}

enum ULPBannerError: Error {
    case failToLoad
}

class ULPBannerAdManager: ULPAdManager {
    var ad: LPMBannerAdView!
    
    override
    public init(adType: AdType,
                adConfiguration: AdConfiguration = .init(adUnitId: ""),
                cardConfiguration: CardConfiguration = .init(),
                viewController: UIViewController?,
                adDelegate: AdLifeCycleDelegate? = nil) {
        super.init(adType: adType,
                   adConfiguration: adConfiguration,
                   cardConfiguration: cardConfiguration,
                   viewController: viewController,
                   adDelegate: adDelegate)
        bannerSizes = [
            BannerAdManagerSize(internalSize: .banner(), image: Image(systemName: "inset.filled.bottomthird.rectangle")),
            BannerAdManagerSize(internalSize: .mediumRectangle(), image: Image(systemName: "inset.filled.rectangle")),
        ]
        actualSize = BannerAdManagerSize.init(internalSize: .banner(), image: Image("max_default_banner"))
    }

    override func updateBannerSize(_ size: AdsCardLibrary.BannerSize) {
        if size != actualSize {
            resetAd()
        }
        super.updateBannerSize(size)
    }
    
    override public var actualSize: AdsCardLibrary.BannerSize? {
        get { internalSize }
        set { internalSize = newValue as! BannerAdManagerSize }
    }
    
    override func resetAd() {
        ad = nil
    }
    
    var internalSize: BannerAdManagerSize!
    
    override func instanciateAd() async {
        guard ad == nil else { return }
        let adConfig = LPMBannerAdViewConfigBuilder()
            .set(adSize: internalSize.internalSize)
            .build()
        await ad = .init(adUnitId: adType.adUnit, config: adConfig)
        await ad.setDelegate(proxy)
    }
    
    override func load() async {
        guard let viewController else {
            append(.adDidFailToLoad(ULPBannerError.failToLoad))
            return
        }
        await super.load()
        await instanciateAd()
        await ad.loadAd(with: viewController)
    }
    
    override public func cardDidAppear() {
        if let ad {
            append(.bannerReady(ad))
        }
    }
    
    override func show() {
        guard let ad else {
            return
        }
        append(.bannerReady(ad))
    }
    
    override func close() {
        ad?.removeFromSuperview()
        ad = nil
        append(.adClosed)
    }
    
    override class func decode(from container: AdCardContainer) throws(AdCardContainerError) -> any AdManager {
        guard let adType = AdType(rawValue: container.adType) else { throw .invalidAdType }
        return ULPBannerAdManager(adType: adType,
                                  adConfiguration: .init(adUnitId: container.adInformations.adUnitId,
                                                         campaignId: container.adInformations.campaignId,
                                                         creativeId: container.adInformations.creativeId,
                                                         dspCreativeId: container.adInformations.dspCreativeId,
                                                         dspRegion: container.adInformations.dspRegion),
                                  cardConfiguration: .init(oguryTestModeEnabled: container.adInformations.settings.oguryTestModeEnabled,
                                                           rtbTestModeEnabled: container.adInformations.settings.rtbTestModeEnabled,
                                                           qaLabel: container.adInformations.settings.qaLabel),
                                  viewController: nil,
                                  adDelegate: nil)
    }
}
