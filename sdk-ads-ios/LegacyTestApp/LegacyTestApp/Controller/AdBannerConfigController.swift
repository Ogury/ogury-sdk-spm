//
//  AdBannerConfigController.swift
//  OguryAdsTestApp
//
//  Created by Pernic on 06/07/2020.
//  Copyright © 2020 co.ogury. All rights reserved.
//

import Foundation
import RxSwift

class AdBannerConfigController {

    static var shared = AdBannerConfigController()

    let disposeBag = DisposeBag()

    private var currentBannerTab = BehaviorSubject(value: ScreenBannerType.scrollView)

    private var scrollBannerConfig = BehaviorSubject(value: [BannerConfig]())
    private var tableBannerConfig = BehaviorSubject(value: [BannerConfig]())
    private var collectionBannerConfig = BehaviorSubject(value: [BannerConfig]())

    private var addBannerConfig = PublishSubject<BannerPosition>()

    init() {
    }

    func bannerConfigObservable(for type: ScreenBannerType) -> Observable<[BannerConfig]> {
        switch type {
        case .scrollView:
            return scrollBannerConfig.asObserver()
        case .tableView:
            return tableBannerConfig.asObserver()
        case .collectionView:
            return collectionBannerConfig.asObserver()
        }
    }

    func bannerConfig(for type: ScreenBannerType, config: [BannerConfig]) {
        switch type {
        case .scrollView:
            scrollBannerConfig.on(.next(config))
        case .tableView:
            tableBannerConfig.on(.next(config))
        case .collectionView:
            collectionBannerConfig.on(.next(config))
        }
    }

    func addBannerObservable() -> Observable<BannerPosition> {
        return addBannerConfig.asObserver()
    }

    func currentBannerObserver() -> Observable<ScreenBannerType> {
        return currentBannerTab.asObserver()
    }

    func setCurrentTab(_ type: ScreenBannerType) {
        currentBannerTab.on(.next(type))
    }

    func addBanner(_ banners: BannerPosition) {
        addBannerConfig.on(.next(banners))
    }

}
