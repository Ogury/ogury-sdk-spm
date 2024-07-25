//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import UIKit
import RxSwift
import OguryAds

final class BannerCollectionViewVC: BaseViewController {

    // MARK: - Properties

    @IBOutlet weak var collectionView: UICollectionView!

    let viewModel = BannerViewModel(displayType: .collectionView)

    var addbannerObserver: Disposable?
    var bottomBanner: OguryBannerAd?
    var topBanner: OguryBannerAd?
    let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "SkeletonCollectionCell", bundle: nil), forCellWithReuseIdentifier: "SkeletonCollectionCell")
        collectionView.register(UINib(nibName: "BannerViewCollectionCell", bundle: nil), forCellWithReuseIdentifier: "BannerViewCollectionCell")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        addbannerObserver?.dispose()

        addbannerObserver = AdBannerConfigController.shared
            .addBannerObservable()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [weak self] bannerInfo in
                guard let bannerInfo = bannerInfo.element, let strongSelf = self else {
                    return
                }

                let adUnitID = bannerInfo.adConfig.adUnitID ?? ""
                let campaignID = bannerInfo.adConfig.campaignID ?? ""

                if bannerInfo.positions != nil {
                    for position in bannerInfo.positions! {
                        strongSelf.createBanner(adunit: adUnitID, campaign: campaignID, type: bannerInfo.type!, position: position, anchor: nil)
                        strongSelf.viewModel.numberOfAdsDisplayed += 1
                    }
                } else if bannerInfo.anchor != nil {
                    strongSelf.createBanner(adunit: adUnitID, campaign: campaignID, type: bannerInfo.type!, position: nil, anchor: bannerInfo.anchor, width: strongSelf.view.bounds.width)
                }

                strongSelf.updateView()

                AdBannerConfigController.shared.bannerConfig(for: .collectionView, config: strongSelf.banners)
            }

        addbannerObserver?.disposed(by: disposeBag)

        updateFrame()
    }

    // MARK: - Functions

    func updateView() {
        collectionView.reloadData()

        updateFrame()
    }

    override func viewDidDisappear(_ animated: Bool) {
        addbannerObserver?.dispose()

        super.viewDidDisappear(animated)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        updateFrame(Int(size.width))
    }

    func updateFrame(_ defineWidth: Int? = nil) {
        let width = defineWidth != nil ? defineWidth! : Int(bannerTopView.frame.size.width)

        if let topBannerConfig = banners.first(where: { $0.anchor == .top && $0.position == nil }), let bannerController = BannerAdControllerStore.shared.getInstance(for: topBannerConfig.bannerId) {
            let bannerWidth = Int(topBannerConfig.type.size.width)

            let margin = (width - bannerWidth) / 2

            bannerController.banner?.frame = CGRect(x: margin, y: 0, width: bannerWidth, height: Int(topBannerConfig.type.size.height))

            if let topBanner = bannerController.banner, topBanner.superview == nil {
                bannerTopHeightContraint.constant = topBannerConfig.type.size.height
                bannerTopView.addSubview(topBanner)
                self.topBanner = topBanner
                self.topBanner?.delegate = self
            }
        } else {
            bannerTopHeightContraint?.constant = 0
        }

        if
            let bottomBannerConfig = banners.first(where: { $0.anchor == .bottom && $0.position == nil }),
            let bottomBannerController = BannerAdControllerStore.shared.getInstance(for: bottomBannerConfig.bannerId) {

            let bannerWidth = Int(bottomBannerConfig.type.size.width)

            let margin = (width - bannerWidth) / 2

            bottomBannerController.banner?.frame = CGRect(x: margin, y: 0, width: bannerWidth, height: Int(bottomBannerConfig.type.size.height))

            if let bottomBanner = bottomBannerController.banner, bottomBanner.superview == nil {
                bannerBottomHeightContraint.constant = bottomBannerConfig.type.size.height
                bannerBottomView.addSubview(bottomBanner)
                self.bottomBanner = bottomBanner
                self.bottomBanner?.delegate = self
            }
        } else {
            bannerBottomHeightContraint?.constant = 0
        }
    }

    func idForBanner(_ bannerAds: OguryBannerAd) -> Int? {
        let config = banners.first { BannerAdControllerStore.shared.getInstance(for: $0.bannerId)?.banner == bannerAds }

        return config?.bannerId
    }

    func removeBannerFromScreen(_ bannerAds: OguryBannerAd) {
        banners.removeAll { BannerAdControllerStore.shared.getInstance(for: $0.bannerId)?.banner == bannerAds }

        updateView()
    }
}

// MARK: - UICollectionViewDataSource

extension BannerCollectionViewVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfElementsToDisplay()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let config = banners.first { (config) -> Bool in
            return config.position != nil && config.position == indexPath.row
        }

        if config == nil, let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "SkeletonCollectionCell",
                                 for: indexPath) as? SkeletonCollectionCell {
            return cell
        }

        if let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "BannerViewCollectionCell", for: indexPath) as? BannerViewCollectionCell {
            cell.update(With: config!)
            return cell
        }

        return UICollectionViewCell()
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension BannerCollectionViewVC: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - OguryBannerAdDelegate

extension BannerCollectionViewVC: OguryBannerAdDelegate {

    func didLoad(_ banner: OguryBannerAd) {
        if let bottomBanner = self.bottomBanner {
            bannerBottomView.addSubview(bottomBanner)
        }

        if let topBanner = self.topBanner {
            bannerTopView.addSubview(topBanner)
        }

        LogsController.shared.addLogs("Banner n°\(idForBanner(banner)) loaded")
    }

    func didDisplay(_ banner: OguryBannerAd) {
        LogsController.shared.addLogs("Banner n°\(idForBanner(banner)) displayed")
    }


    func didClick(_ banner: OguryBannerAd) {
        LogsController.shared.addLogs("Banner n°\(idForBanner(banner)) clicked")
    }

    func didClose(_ banner: OguryBannerAd) {
        LogsController.shared.addLogs("Banner n°\(idForBanner(banner)) closed")
        removeBannerFromScreen(banner)
    }

    func didFailOguryBannerAdWithError(_ error: OguryError, for banner: OguryBannerAd) {
        LogsController.shared.addLogs("Banner n°\(idForBanner(banner)) error : \(error.localizedDescription)")

        if (error.code != 2004) {
            removeBannerFromScreen(banner)
        }
    }
}
