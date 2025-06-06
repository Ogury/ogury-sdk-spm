//
//  AdMobIntertstitialManager.swift
//  AdMobCardAdapter
//
//  Created by Jerome TONNELIER on 28/04/2025.
//

import GoogleMobileAds
import AdsCardAdapter
import AdsCardLibrary
import SwiftUI

internal class BannerAdManagerSize: BannerSize {
    let internalSize: AdSize!
    init(internalSize: AdSize!, image: Image) {
        self.internalSize = internalSize
        super.init(size: internalSize.size, image: image)
    }
}

class AdMobBannerManager: AdMobManager {
    var ad: BannerView?
    
    override
    public init(adType: AdMobAdType,
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
            BannerAdManagerSize(internalSize: AdSizeBanner, image: Image(systemName: "inset.filled.bottomthird.rectangle")),
            BannerAdManagerSize(internalSize: AdSizeMediumRectangle, image: Image(systemName: "inset.filled.rectangle")),
        ]
        actualSize = BannerAdManagerSize.init(internalSize: AdSizeBanner, image: Image("max_default_banner"))
    }
    override func updateBannerSize(_ size: BannerSize) {
        if size != actualSize {
            resetAd()
        }
        super.updateBannerSize(size)
    }
    
    var internalSize: BannerAdManagerSize!
    override public var actualSize: BannerSize? {
        get { internalSize }
        set { internalSize = newValue as! BannerAdManagerSize }
    }
    
    override func instanciateAd() async {
        Task { @MainActor in
            guard ad == nil else { return }
            ad = .init(adSize: internalSize.internalSize)
            ad?.delegate = proxy
            ad?.adUnitID = adType.adUnit
            ad?.rootViewController = viewController
        }
    }
    
    override func resetAd() {
        ad = nil
    }
    
    override func close() {
        ad = nil
        append(.adClosed)
    }
    
    override public func cardDidAppear() {
        if let ad {
            append(.bannerReady(ad))
        }
    }
    
    override func load() async {
        await super.load()
        await instanciateAd()
        await ad?.load(.init())
    }
    
    override func show() {
        guard let ad else { return }
        append(.bannerReady(ad))
    }
    
    override class func decode(from container: AdCardContainer) throws(AdCardContainerError) -> any AdManager {
        guard let adType = AdMobAdType(rawValue: container.adType) else { throw .invalidAdType }
        return AdMobBannerManager(adType: adType,
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
