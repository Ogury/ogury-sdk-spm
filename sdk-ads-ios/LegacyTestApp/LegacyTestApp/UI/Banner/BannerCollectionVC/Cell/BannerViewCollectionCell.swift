//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import UIKit

final class BannerViewCollectionCell: UICollectionViewCell {

    // MARK: - Properties

    @IBOutlet weak var heightBannerConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthBannerConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewOfBanner: UIView!

    // MARK: - Functions

    func update(With config: BannerConfig) {
        heightBannerConstraint.constant = config.type.size.height
        widthBannerConstraint.constant = config.type.size.width

        if let bannerController = BannerAdControllerStore.shared.getInstance(for: config.bannerId), let banner = bannerController.banner {
            viewOfBanner.addSubview(banner)
        }
    }
}
