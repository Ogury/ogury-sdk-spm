//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import Foundation
import UIKit

final class BannerMainTab: UITabBarController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        delegate = self
    }
}

// MARK: - UITabBarControllerDelegate

extension BannerMainTab: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if (viewController as? BannerCollectionViewVC) != nil {
            AdBannerConfigController.shared.setCurrentTab(.collectionView)
        }

        if (viewController as? BannerScrollViewVC) != nil {
            AdBannerConfigController.shared.setCurrentTab(.scrollView)
        }

        if (viewController as? BannerTableViewVC) != nil {
            AdBannerConfigController.shared.setCurrentTab(.tableView)
        }
    }
}
