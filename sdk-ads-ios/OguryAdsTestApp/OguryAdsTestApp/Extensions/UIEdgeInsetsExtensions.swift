//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

import UIKit

extension UIEdgeInsets {

    init(vertical: CGFloat, horizontal: CGFloat) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }

    init(value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }
}
