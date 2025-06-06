//
//  MaxBannerAdManager.swift
//  MaxCardAdapter
//
//  Created by Jerome TONNELIER on 22/04/2025.
//

import AdsCardLibrary
import AdsCardAdapter
import SwiftUI
import Combine
import AppLovinSDK

internal class BannerAdManagerSize: BannerSize {
    let internalSize: MAAdFormat!
    init(internalSize: MAAdFormat!, image: Image) {
        self.internalSize = internalSize
        super.init(size: internalSize.size, image: image)
    }
}

class MaxBannerAdManager: MaxAdManager {
    var ad: MAAdView!
    
    override
    public init(adType: MaxAdType,
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
            BannerAdManagerSize(internalSize: .banner, image: Image(systemName: "inset.filled.bottomthird.rectangle")),
            BannerAdManagerSize(internalSize: .mrec, image: Image(systemName: "inset.filled.rectangle")),
        ]
        actualSize = BannerAdManagerSize.init(internalSize: .banner, image: Image("max_default_banner"))
    }
    override func updateBannerSize(_ size: BannerSize) {
        if size != actualSize {
            resetAd()
        }
        super.updateBannerSize(size)
    }
    
    override public var actualSize: BannerSize? {
        get { internalSize }
        set { internalSize = newValue as! BannerAdManagerSize }
    }
    
    override func resetAd() {
        ad = nil
    }
    
    var internalSize: BannerAdManagerSize!
    override func instanciateAd() async {
        guard ad == nil else { return }
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.ad = .init(adUnitIdentifier: self.adConfiguration.adUnitId, adFormat: internalSize.internalSize)
            self.ad.delegate = self.proxy
            self.ad.frame = .init(origin: .zero, size: internalSize.size)
        }
    }
    
    override public func cardDidAppear() {
        if let ad {
            append(.bannerReady(ad))
        }
    }
    
    override func load() async {
        await super.load()
        Task { @MainActor [weak self] in
            await self?.instanciateAd()
            self?.ad.loadAd()
        }
    }
    
    override func show() {
        super.show()
        Task { @MainActor [weak self] in
            guard let self else { return }
            await self.instanciateAd()
            self.append(.bannerReady(self.ad))
        }
    }
    
    override func close() {
        ad?.removeFromSuperview()
        ad.delegate = nil
        ad = nil
        append(.adClosed)
    }
    
    override class func decode(from container: AdCardContainer) throws(AdCardContainerError) -> any AdManager {
        guard let adType = MaxAdType(rawValue: container.adType) else { throw .invalidAdType }
        return MaxBannerAdManager(adType: adType,
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
