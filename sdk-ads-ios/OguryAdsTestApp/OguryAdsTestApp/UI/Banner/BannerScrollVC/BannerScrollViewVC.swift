//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import UIKit
import RxSwift
import OguryAds

class ContainerView: UIView {

}

final class BannerScrollViewVC: BaseViewController {

    // MARK: - Constants

    static let skeletonViewHeight = 15
    static let spaceBetweenSkeletonView = 45
    static let topOffset = 260

    // MARK: - Properties

    @IBOutlet weak var scrollView: UIScrollView!

    let viewModel = BannerViewModel(displayType: .scrollView)

    var addbannerObserver: Disposable?
    var loaders = [LoadingPlaceholderView]()
    var topBanner: OguryBannerAd?
    var bottomBanner: OguryBannerAd?
    let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let height = (viewModel.numberOfElementsToDisplay() * Self.skeletonViewHeight) + (viewModel.numberOfElementsToDisplay() * Self.spaceBetweenSkeletonView)

        scrollView.contentSize = CGSize(width: view.frame.width, height: CGFloat(height + Self.topOffset))

        for iterator in 0...viewModel.displayType.numberOfSeletonElements() {
            let view = ContainerView(frame: CGRect(x: 16, y: iterator * Self.spaceBetweenSkeletonView + Self.topOffset, width: Int(self.view.frame.width - Constants.Margins.veryLarge), height: Self.skeletonViewHeight))

            view.addSubview(UILabel(frame: CGRect(x: 0, y: 0, width: Int(self.view.frame.width - Constants.Margins.veryLarge), height: Self.skeletonViewHeight)))

            let loadingView = LoadingPlaceholderView()
            loaders.append(loadingView)

            scrollView.addSubview(view)

            if #available(iOS 11.0, *) {
                loadingView.gradientColor = UIColor(named: "skeletonColor") ?? .lightGray
            } else {
                loadingView.gradientColor = .lightGray
            }

            loadingView.cover(view)
        }
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

                if bannerInfo.anchor != nil {
                    strongSelf.createBanner(adunit: bannerInfo.adConfig.adUnitID ?? "",
                                      campaign: bannerInfo.adConfig.campaignID ?? "",
                                      type: bannerInfo.type!, position: nil,
                                      anchor: bannerInfo.anchor)
                } else {
                    LogsController.shared.addLogs("position are not available on ScrollView")
                }

                strongSelf.updateView()

                AdBannerConfigController.shared.bannerConfig(for: .scrollView, config: strongSelf.banners)
            }

        addbannerObserver?.disposed(by: disposeBag)
    }

    override func viewDidDisappear(_ animated: Bool) {
        addbannerObserver?.dispose()
    }

    // MARK: - Functions

    func addConstraints<T: UIView>(_ banner: T?, for configuration: BannerConfig) {
        guard let banner = banner else {
            return
        }

        let anchorConstraint: NSLayoutConstraint

        switch configuration.anchor {
            case .top:
                anchorConstraint = banner.topAnchor.constraint(equalTo: scrollView.topAnchor)

            case .bottom:
                if let lastScrollViewItem = scrollView.subviews.last(where: { $0 is ContainerView }) {
                    anchorConstraint = banner.topAnchor.constraint(equalTo: lastScrollViewItem.bottomAnchor)
                } else {
                    return
                }

            default:
                return
        }

        scrollView.addConstraints([
            anchorConstraint,
            banner.heightAnchor.constraint(equalToConstant: configuration.type.size.height),
            banner.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            banner.widthAnchor.constraint(equalToConstant: configuration.type.size.width)
        ])
    }

    func updateView() {
        if let topBannerConfig = banners.first(where: { $0.anchor == .top && $0.position == nil }),
           let topBannerController = BannerAdControllerStore.shared.getInstance(for: topBannerConfig.bannerId),
           let topBanner = topBannerController.banner {

            topBanner.removeFromSuperview()
            topBanner.translatesAutoresizingMaskIntoConstraints = false

            scrollView.addSubview(topBanner)

            addConstraints(topBanner, for: topBannerConfig)
            self.topBanner = topBanner
            self.topBanner?.delegate = self
        }

        if
            let bottomBannerConfig = banners.first(where: { $0.anchor == .bottom && $0.position == nil }),
            let bottomBannerController = BannerAdControllerStore.shared.getInstance(for: bottomBannerConfig.bannerId),
            let bottomBanner = bottomBannerController.banner {

            bottomBanner.removeFromSuperview()
            bottomBanner.translatesAutoresizingMaskIntoConstraints = false

            scrollView.addSubview(bottomBanner)

            addConstraints(bottomBanner, for: bottomBannerConfig)
            self.bottomBanner = bottomBanner
            self.bottomBanner?.delegate = self
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

// MARK: - UIPopoverPresentationControllerDelegate

extension BannerScrollViewVC: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - OguryBannerAdDelegate

extension BannerScrollViewVC: OguryBannerAdDelegate {

    func didLoad(_ banner: OguryBannerAd) {
        if let bottomBanner = self.bottomBanner {
            scrollView.addSubview(bottomBanner)
        }

        if let topBanner = self.topBanner {
            scrollView.addSubview(topBanner)
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
