//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import UIKit
import RxSwift
import OguryAds

final class BannerTableViewVC: BaseViewController {

    // MARK: - Properties

    @IBOutlet weak var tableView: UITableView!

    let viewModel = BannerViewModel(displayType: .tableView)
    
    var addbannerObserver: Disposable?
    var bottomBanner: OguryBannerAdView?
    var topBanner: OguryBannerAdView?
    let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.register(UINib(nibName: "SkeletonTableCell", bundle: nil), forCellReuseIdentifier: "SkeletonTableCell")
        tableView.register(UINib(nibName: "BannerTableCell", bundle: nil), forCellReuseIdentifier: "BannerTableCell")
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

                if let positions = bannerInfo.positions {
                    positions.forEach {
                        strongSelf.createBanner(adunit: adUnitID, campaign: campaignID, type: bannerInfo.type!, position: $0, anchor: nil)
                        strongSelf.viewModel.numberOfAdsDisplayed += 1
                    }
                } else if bannerInfo.anchor != nil {
                    strongSelf.createBanner(adunit: adUnitID, campaign: campaignID, type: bannerInfo.type!, position: nil, anchor: bannerInfo.anchor, width: strongSelf.view.bounds.width)
                }

                strongSelf.updateView()

                AdBannerConfigController.shared.bannerConfig(for: .tableView, config: strongSelf.banners)
            }

        addbannerObserver?.disposed(by: disposeBag)

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

    // MARK: - Functions

    func updateFrame(_ defineWidth: Int? = nil) {
        let width = defineWidth != nil ? defineWidth! : Int(self.bannerTopView.frame.size.width)

        if let topBannerConfig = banners.first(where: { $0.anchor == .top && $0.position == nil }),
           let topBannerController = BannerAdControllerStore.shared.getInstance(for: topBannerConfig.bannerId),
           let topBanner = topBannerController.banner {

            let bannerWidth = Int(topBannerConfig.type.size.width)

            let margin = (width - bannerWidth) / 2

            topBanner.frame = CGRect(x: margin, y: 0, width: bannerWidth, height: Int(topBannerConfig.type.size.height))

            if topBanner.superview == nil {
                bannerTopHeightContraint.constant = topBannerConfig.type.size.height
                bannerTopView.addSubview(topBanner)
                self.topBanner = topBanner
                self.topBanner?.delegate = self
            }
        } else {
            bannerTopHeightContraint?.constant = 0
        }

        if let bottomBannerConfig = banners.first(where: { $0.anchor == .bottom && $0.position == nil }),
           let bottomBannerController = BannerAdControllerStore.shared.getInstance(for: bottomBannerConfig.bannerId),
           let bottomBanner = bottomBannerController.banner {


            let bannerWidth = Int(bottomBannerConfig.type.size.width)

            let margin = (width - bannerWidth) / 2

            bottomBanner.frame = CGRect(x: margin, y: 0, width: bannerWidth, height: Int(bottomBannerConfig.type.size.height))

            if bottomBanner.superview == nil {
                bannerBottomHeightContraint.constant = bottomBannerConfig.type.size.height
                bannerBottomView.addSubview(bottomBanner)
                self.bottomBanner = bottomBanner
                self.bottomBanner?.delegate = self
            }
        } else {
            bannerBottomHeightContraint?.constant = 0
        }
    }

    func updateView() {
        tableView.reloadData() 

        updateFrame()
    }

    func idForBanner(_ bannerAds: OguryBannerAdView) -> Int? {
        let config = banners.first { BannerAdControllerStore.shared.getInstance(for: $0.bannerId)?.banner == bannerAds }

        return config?.bannerId
    }

    func removeBannerFromScreen(_ bannerAds: OguryBannerAdView) {
        banners.removeAll { BannerAdControllerStore.shared.getInstance(for: $0.bannerId)?.banner == bannerAds }

        updateView()
    }
}

// MARK: - UITableViewDataSource

extension BannerTableViewVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfElementsToDisplay()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let config = banners.first(where: { $0.position != nil && $0.position == indexPath.row }),
           let cell = tableView.dequeueReusableCell(withIdentifier: "BannerTableCell") as? BannerTableCell {
            cell.update(With: config)
            return cell
        } else if let skeletonCell = tableView .dequeueReusableCell(withIdentifier: "SkeletonTableCell") as? SkeletonTableCell {
            return skeletonCell
        } else {
            return UITableViewCell()
        }
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension BannerTableViewVC: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - OguryBannerAdDelegate

extension BannerTableViewVC: OguryBannerAdDelegate {

    func didLoad(_ banner: OguryBannerAdView) {
        if let bottomBanner = self.bottomBanner {
            bannerBottomView.addSubview(bottomBanner)
        }

        if let topBanner = self.topBanner {
            bannerTopView.addSubview(topBanner)
        }

        LogsController.shared.addLogs("Banner n°\(idForBanner(banner)) loaded")
    }

    func didDisplay(_ banner: OguryBannerAdView) {
        LogsController.shared.addLogs("Banner n°\(idForBanner(banner)) displayed")
    }


    func didClick(_ banner: OguryBannerAdView) {
        LogsController.shared.addLogs("Banner clicked")
    }

    func didClose(_ banner: OguryBannerAdView) {
        LogsController.shared.addLogs("Banner closed")
        removeBannerFromScreen(banner)
    }

    func didFail(_ banner: OguryBannerAdView, error: OguryAdError) {
        LogsController.shared.addLogs("Banner error : \(error.localizedDescription)")
        if (error.code != 2004) {
            removeBannerFromScreen(banner)
        }
    }
}
