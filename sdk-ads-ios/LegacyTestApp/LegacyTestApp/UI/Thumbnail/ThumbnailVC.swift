//
//  Copyright © 2020 co.ogury All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import DDPopoverBackgroundView

class ThumbnailVC: UIViewController {

    let disposeBag = DisposeBag()
    var adConfig: AdConfig!

    @IBOutlet var thumbnailViewButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
    }

    func setupRx() {
        AdConfigController.shared.adConfigObservable(for: .thumbnail).subscribe({ [weak self] config in

            guard let config = config.element else {
                return
            }
            self?.adConfig = config

        }).disposed(by: disposeBag)
    }

    @IBAction func close() {
        let viewController = UIStoryboard.init(name: "Main",
                                               bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "mainVC")

        UIApplication.shared.keyWindow?.rootViewController = viewController
    }

    @IBAction func settings() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "viewThumbnailVC")
        viewController.modalPresentationStyle = .popover

        let topController = UIApplication.topViewController()!

        let controller = viewController.popoverPresentationController
        controller?.sourceView = topController.view
        controller?.sourceRect = thumbnailViewButton.frame
        controller?.delegate = topController as? UIPopoverPresentationControllerDelegate
        controller?.popoverBackgroundViewClass = DDPopoverBackgroundView.self
        DDPopoverBackgroundView.setContentInset(1)
        DDPopoverBackgroundView.setBackgroundImageCornerRadius(13)
        DDPopoverBackgroundView.setArrowBase(20)
        DDPopoverBackgroundView.setArrowHeight(13)
        DDPopoverBackgroundView.setTintColor(.gray)
        controller?.permittedArrowDirections = .up

        topController.present(viewController, animated: true, completion: nil)
    }

}

extension ThumbnailVC: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

}
