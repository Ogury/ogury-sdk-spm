//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import UIKit

final class SkeletonCollectionCell: UICollectionViewCell {

    // MARK: - Properties

    let loadingView = LoadingPlaceholderView()

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 15

        loadingView.cover(self)

        if #available(iOS 11.0, *) {
            loadingView.gradientColor = UIColor(named: "skeletonColor") ?? .lightGray
        } else {
            loadingView.gradientColor = .lightGray
        }
    }
}
