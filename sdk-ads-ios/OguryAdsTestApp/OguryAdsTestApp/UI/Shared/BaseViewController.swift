//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet weak var headerHeightContraint: NSLayoutConstraint?
    @IBOutlet weak var bannerTopHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var bannerBottomHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var bannerTopView: UIView!
    @IBOutlet weak var bannerBottomView: UIView!

    var banners = [BannerConfig]()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        headerHeightContraint?.constant = (45 + UIApplication.shared.statusBarFrame.height)
    }

    // MARK: - Functions

    func createBanner(adunit: String, campaign: String, type: BannerType, position: Int?, anchor: AnchorType?, width: CGFloat? = nil) {
        let identifier = BannerAdControllerStore.shared.createInstance()

        let bannerConfig = BannerConfig(bannerId: identifier, type: type, controller: self, position: position, anchor: anchor)

        banners.append(bannerConfig)

        if let banner = BannerAdControllerStore.shared.getInstance(for: identifier) {
            banner.load(adUnitId: adunit, campaignId: campaign, maxSize: type.oguryBannerSize, inView: nil, withWidth: width)
        }
    }
}
