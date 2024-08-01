//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

import Foundation

class BannerViewModel {

    // MARK: - Constants

    enum BannerDisplayType {
        case scrollView
        case tableView
        case collectionView

        func numberOfSeletonElements() -> Int {
            switch self {
                case .collectionView: return 25
                case .scrollView: return 25
                case .tableView: return 25
            }
        }
    }

    // MARK: - Properties

    let displayType: BannerDisplayType

    var numberOfAdsDisplayed = 0

    // MARK: - Initialization

    init(displayType: BannerDisplayType) {
        self.displayType = displayType
    }

    // MARK: - Functions

    func numberOfElementsToDisplay() -> Int {
        return displayType.numberOfSeletonElements() + numberOfAdsDisplayed
    }
}
