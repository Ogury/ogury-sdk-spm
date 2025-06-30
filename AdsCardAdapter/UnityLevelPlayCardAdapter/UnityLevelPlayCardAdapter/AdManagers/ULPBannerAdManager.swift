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
        actualSize = self.bannerSizes?.first!
        if let bannerSize = self.bannerSizes?[adConfiguration.bannerSize] {
            actualSize = bannerSize
        }
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
        guard let adType: AdType = AdType(rawValue: container.adType, fileVersion: container.version) else {
            throw .invalidAdType
        }
        
        let adManager = ULPBannerAdManager(adType: adType,
                                           adConfiguration: .init(adUnitId: container.adInformations.adUnitId,
                                                                  campaignId: container.adInformations.campaignId,
                                                                  creativeId: container.adInformations.creativeId,
                                                                  dspCreativeId: container.adInformations.dspCreativeId,
                                                                  dspRegion: container.adInformations.dspRegion,
                                                                  bannerSize: container.adInformations.bannerSize),
                                           cardConfiguration: .init(oguryTestModeEnabled: container.adInformations.settings.oguryTestModeEnabled,
                                                                    rtbTestModeEnabled: container.adInformations.settings.rtbTestModeEnabled,
                                                                    qaLabel: container.adInformations.settings.qaLabel),
                                           viewController: nil,
                                           adDelegate: nil)
        if container.version != AdCardContainer.currentVersion {
            adManager.migrate(from: container)
        }
        return adManager
    }
    
    private func migrate(from container: AdCardContainer) {
        switch (container.version, AdCardContainer.currentVersion) {
            case (.preVersion, .one) where [303, 313].contains(container.adType):
                // it's a Mrec, use rightful size
                actualSize = bannerSizes![1]
                
            default: ()
        }
    }
}
