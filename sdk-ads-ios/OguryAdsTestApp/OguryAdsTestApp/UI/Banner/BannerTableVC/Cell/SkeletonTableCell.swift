//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import UIKit

final class SkeletonTableCell: UITableViewCell {

    // MARK: - Properties

    let loadingView = LoadingPlaceholderView()

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        loadingView.cover(self)
        
        if #available(iOS 11.0, *) {
            loadingView.gradientColor = UIColor(named: "skeletonColor") ?? .lightGray
        } else {
            loadingView.gradientColor = .lightGray
        }
    }
}
