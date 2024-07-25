//
//  Copyright © 2020 co.ogury All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class ViewThumbnailVC: UIViewController {

    @IBOutlet var thumbnailView: ThumbnailView!

    @IBOutlet weak var tableView: UITableView!

    let disposeBag = DisposeBag()

    var blackListViewController = [String]()
    var allViewController = [String]()

    var adConfig: AdConfig? {
        didSet {
            if adConfig != nil {
                AdConfigController.shared.saveConfig(adConfig!, for: .thumbnail)
            }
        }
    }

    override func viewDidLoad() {
        thumbnailView.delegate = self

        tableView.delegate = self
        tableView.dataSource = self

        allViewController = [String(describing: ThumbnailVC.self),
                     String(describing: ThumbnailVC2.self),
                     String(describing: ThumbnailVC3.self),
                     String(describing: ThumbnailVC4.self)]
        setupRx()
    }

    func setupRx() {
        RxSettings.shared
                .blacklistCellsObservable
                .take(1)
                .asDriver(onErrorJustReturn: [])
                .drive { [weak self] cells in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.blackListViewController = cells
                    strongSelf.tableView.reloadData()
                }
                .disposed(by: disposeBag)
    }

    @IBAction func loadAndShow() {
        let adUnitID = adConfig?.adUnitID ?? ""
        let campaignID = adConfig?.campaignID ?? ""
        let creativeID = adConfig?.creativeID ?? ""
        let dspCreativeId = adConfig?.dspCreativeId ?? ""
        let dspRegion = adConfig?.dspRegion ?? ""
        guard let xOffset = adConfig?.xOffset,
              let yOffset = adConfig?.yOffset,
              let width = adConfig?.width,
              let height = adConfig?.height
        else {
            AdsThumbnailController.shared.loadAndShow(adUnitId: adUnitID, campaignId: campaignID, creativeId: creativeID, dspCreativeId: dspCreativeId, dspRegion: dspRegion)
            dismiss(animated: true, completion: nil)
            return
        }
        let positionToShow = CGPoint(x: xOffset, y: yOffset)
        let size = CGSize(width: width, height: height)
        guard let corner = adConfig?.corner else {
            AdsThumbnailController.shared.loadAndShow(adUnitId: adUnitID,
                                                      campaignId: campaignID,
                                                      creativeId: creativeID,
                                                      dspCreativeId: dspCreativeId,
                                                      dspRegion: dspRegion,
                                                      maxSize: size,
                                                      showAt: positionToShow)
            dismiss(animated: true, completion: nil)
            return
        }
        AdsThumbnailController.shared.loadAndShow(adUnitId: adUnitID,
                                                  campaignId: campaignID,creativeId: creativeID,
                                                  dspCreativeId: dspCreativeId,
                                                  dspRegion: dspRegion,
                                                  maxSize: size,
                                                  showAt: positionToShow,
                                                  withCorner: corner)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }

}

extension ViewThumbnailVC: ThumbnailViewDelegate {
    func adConfigChange(_ config: AdConfig) {
        adConfig = config
    }
}

extension ViewThumbnailVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewChoice = allViewController[indexPath.row]
        let isChecked = blackListViewController.contains(where: { (type) -> Bool in
            return type == viewChoice
        })
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            if isChecked {
                cell.accessoryType = .none
                blackListViewController.removeAll { (type) -> Bool in
                    return type == viewChoice
                }
            } else {
                cell.accessoryType = .checkmark
                blackListViewController.append(viewChoice)
            }
        }
        let resultChoice = allViewController.filter { (type) -> Bool in
            let isChecked = blackListViewController.contains(where: { (choice) -> Bool in
                return type == choice
            })
            return isChecked
        }
        RxSettings.shared.setBlacklistCells(resultChoice)
    }
}

extension ViewThumbnailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allViewController.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!

        let viewChoice = allViewController[indexPath.row]

        cell.textLabel?.text = viewChoice

        cell.accessoryType = blackListViewController.contains {
            $0 == viewChoice
        } ? .checkmark : .none
        return cell
    }

}
