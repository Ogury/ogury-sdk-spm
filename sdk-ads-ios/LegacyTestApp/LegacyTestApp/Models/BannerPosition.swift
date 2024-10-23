//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

enum AnchorType {
    case top
    case bottom
}

enum ScreenBannerType {
    case scrollView
    case tableView
    case collectionView
}

final class BannerPosition {

    // MARK: - Properties

    var adConfig: AdConfig!
    var type: BannerType!
    var anchor: AnchorType?
    var positions: [Int]?

    // MARK: - Initialization

    init(adConfig: AdConfig, type: BannerType, anchor: AnchorType? = nil, positions: [Int]? = nil) {
        self.type = type
        self.adConfig = adConfig
        self.anchor = anchor
        self.positions = positions
    }
}

final class BannerConfig {

    // MARK: - Properties

    var bannerId: Int
    var type: BannerType!
    var controller: BaseViewController?
    var position: Int?
    var anchor: AnchorType?

    // MARK: - Initialization

    init(bannerId: Int, type: BannerType, controller: BaseViewController? = nil, position: Int? = nil, anchor: AnchorType? = nil) {
        self.bannerId = bannerId
        self.type = type
        self.controller = controller
        self.position = position
        self.anchor = anchor
    }
}
