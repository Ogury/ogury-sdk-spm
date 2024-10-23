//
//  UIApplication+TopVC.swift
//  OguryAdsTestApp
//
//  Created by Pernic on 02/06/2020.
//  Copyright © 2020 co.ogury. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    class func topViewController() -> UIViewController? {
        let windows = UIApplication.shared.windows
        for window in windows {
            if (NSStringFromClass(window.classForCoder) != "OGAThumbnailWindow") {
                return self.topViewController(controller: window.rootViewController)
            }
        }
        return nil
    }

    class func topViewController(controller: UIViewController?) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
