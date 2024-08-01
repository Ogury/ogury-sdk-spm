//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import UIKit
import RxSwift

final class BannerViewChoiceVC: UIViewController {

    // MARK: - Properties

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var segmentType: UISegmentedControl!
    @IBOutlet weak var campaign: UITextField!
    @IBOutlet weak var adunitid: UITextField!
    @IBOutlet weak var position: UITextField!
    @IBOutlet weak var anchor: UISegmentedControl!
    @IBOutlet weak var bannerList: UITableView!
    @IBOutlet weak var creativeId: UITextField!
    
    var adConfig: AdConfig!
    var observer: [NSKeyValueObservation]?
    var currentTab = ScreenBannerType.collectionView
    var bannersObserver: Disposable?
    var bannerType: BannerType = .mpu
    var subscription: Disposable?
    var banners: [BannerConfig]!
    let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        setupRx()

        campaign.delegate = self
        adunitid.delegate = self
        position.delegate = self
        creativeId.delegate = self
        bannerList.dataSource = self
        bannerList.delegate = self

        bannerList.register(UINib(nibName: "BannerListTableViewCell", bundle: nil), forCellReuseIdentifier: "BannerListTableViewCell")

        segmentType.replaceSegments(segments: BannerType.allCases.map { $0.name })

        segmentType.selectedSegmentIndex = 0

        campaign.addTarget(self, action: #selector(textFieldTextChange), for: .editingChanged)
        adunitid.addTarget(self, action: #selector(textFieldTextChange), for: .editingChanged)
        creativeId.addTarget(self, action: #selector(textFieldTextChange), for: .editingChanged)
    }

    // MARK: - Functions

    func setupRx() {
        AdBannerConfigController.shared
            .currentBannerObserver()
            .subscribe { [weak self] tab in
                guard let tab = tab.element, let strongSelf = self else {
                    return
                }

                switch tab {
                case .collectionView: strongSelf.name.text = "Banner : CollectionView"
                case .tableView: strongSelf.name.text = "Banner : TableView"
                case .scrollView: strongSelf.name.text = "Banner : ScrollView"
                }

                strongSelf.currentTab = tab

                strongSelf.updateTab()
            }
            .disposed(by: disposeBag)

        subscription?.dispose()

        subscription = AdConfigController.shared
            .adConfigObservable(for: .banner(type: bannerType))
            .subscribe { [weak self] config in
                guard let config = config.element else {
                    return
                }

                self?.campaign.text = config.campaignID
                self?.adunitid.text = config.adUnitID
                self?.adConfig = config
            }

        subscription?.disposed(by: disposeBag)
    }

    func updateTab() {
        bannersObserver?.dispose()

        bannersObserver = AdBannerConfigController.shared
            .bannerConfigObservable(for: currentTab)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe { [weak self] banners in
                guard let banners = banners.element, let strongSelf = self else {
                    return
                }

                strongSelf.banners = banners
                strongSelf.bannerList.reloadData()
            }

        bannersObserver?.disposed(by: disposeBag)
    }

    @IBAction
    func segmentBannerTypeChange() {
        bannerType = BannerType.allCases[segmentType.selectedSegmentIndex]

        setupRx()
    }

    @IBAction
    func addBanner() {
        let banner = BannerPosition(adConfig: AdConfig(adUnitID: adunitid.text, campaignID: campaign.text), type: bannerType)

        if position.text != nil && position.text != "" {
            banner.positions = position.text?.split(separator: ",").map({ (indexString) -> Int in
                return (Int(String(indexString)) ?? 0)
            })
        } else {
            banner.anchor = anchor.selectedSegmentIndex == 0 ? .top : .bottom
        }

        AdBannerConfigController.shared.addBanner(banner)

        dismiss(animated: true, completion: nil)
    }

    @objc
    func destroyBanner(sender: UIButton) {
        let config = banners[sender.tag]

        let bannerAdController = BannerAdControllerStore.shared.getInstance(for: config.bannerId)

        bannerAdController?.destroy()

        banners.remove(at: sender.tag)

        AdBannerConfigController.shared.bannerConfig(for: currentTab, config: banners)
    }

    @IBAction
    func close() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate

extension BannerViewChoiceVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)

        return false
    }

    @objc
    func textFieldTextChange(_ texfield: UITextField) {
        if texfield == campaign {
            adConfig?.campaignID = campaign.text ?? ""
            AdConfigController.shared.saveConfig(adConfig, for: .banner(type: bannerType))
        }

        if texfield == adunitid {
            adConfig?.adUnitID = adunitid.text ?? ""
            AdConfigController.shared.saveConfig(adConfig, for: .banner(type: bannerType))
        }
        
        if texfield == creativeId {
            adConfig?.creativeID = creativeId.text ?? ""
            AdConfigController.shared.saveConfig(adConfig, for: .banner(type: bannerType))
        }
    }
}

// MARK: - UITableViewDataSource

extension BannerViewChoiceVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return banners.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView .dequeueReusableCell(withIdentifier: "BannerListTableViewCell") as? BannerListTableViewCell {
            let config = banners[indexPath.row]
            cell.updateCell(config: config)
            cell.deletebutton.tag = indexPath.row
            cell.deletebutton.addTarget(self, action: #selector(destroyBanner), for: .touchUpInside)
            cell.contentView.isUserInteractionEnabled = false

            return cell
        }

        return UITableViewCell()
    }
}

// MARK: - UITableViewDelegate

extension BannerViewChoiceVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
}
