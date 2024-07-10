//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import UIKit

final class BannerListTableViewCell: UITableViewCell {

    // MARK: - Properties

    @IBOutlet weak var bannerIdLabel: UILabel!
    @IBOutlet weak var insertbutton: UIButton!
    @IBOutlet weak var removebutton: UIButton!
    @IBOutlet weak var deletebutton: UIButton!

    var bannerId: Int!
    var controller: BaseViewController?

    // MARK: - Functions

    func updateCell(config: BannerConfig) {
        bannerId = config.bannerId
        controller = config.controller

        bannerIdLabel.text = "Banner \(bannerId)"

        insertbutton.imageView?.contentMode = .scaleAspectFit
        removebutton.imageView?.contentMode = .scaleAspectFit
        deletebutton.imageView?.contentMode = .scaleAspectFit
    }

    @IBAction
    func insertInView() {

    }

    @IBAction
    func removefromView() {

    }

    @IBAction
    func delete() {
        controller?.banners.removeAll { $0.bannerId == bannerId }
    }
}
