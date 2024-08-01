//
//  InterstitialCollectionCell.swift
//  OguryAdsTestApp
//
//  Created by Pernic on 16/03/2020.
//  Copyright © 2020 co.ogury. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class ThumbnailCollectionCell: AdsCollectionCell {

    override var estimatedHeight: CGFloat {
        500
    }
    
    override var estimatedWidth: CGFloat {
        352
    }

    var viewController: UIViewController?
    var observer: [NSKeyValueObservation]?

    @IBOutlet var nameLabel: UILabel!

    @IBOutlet var loadBtn: UIButton!
    @IBOutlet var showBtn: UIButton!
    @IBOutlet var loadAndShowBtn: UIButton!
    @IBOutlet var thumbnailView: ThumbnailView!
    
    let disposeBag = DisposeBag()

    override func updateAdCell(_ type: AvailableType, in viewController: UIViewController) {
        self.viewController = viewController
        configType = type
        setupRx()
        setupUI()
        
        customizeButtonUI(button:loadBtn)
        customizeButtonUI(button:loadAndShowBtn)
        customizeButtonUI(button:showBtn)
        customizeLabel(label:nameLabel)
        
        layer.backgroundColor = UIColor.white.cgColor
        
        return
    }
    
    func customizeLabel(label: UILabel) {
    
        if let labelText = label.text {
            let attributedString = NSMutableAttributedString(string: labelText)
            let range = NSRange(location: 0, length: attributedString.length)
            attributedString.addAttribute(.underlineColor, value: UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1), range: range)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1), range: range)
            label.attributedText = attributedString
        }
        
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1)
        label.backgroundColor = UIColor.white
        label.textAlignment = .left
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width - 40).isActive = true
        heightAnchor.constraint(equalToConstant: bounds.size.height).isActive = true
    }

    func setupUI() {
        isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = false

        if (configType == .thumbnail) {
            nameLabel.text = "Thumbnail"
        } else {
            nameLabel.text = "Thumbnail (deprecated)"
        }

        layer.cornerRadius = 15

        thumbnailView.delegate = self
        layer.backgroundColor = configType?.backgroundColor?.cgColor
    }

    func customizeButtonUI(button: UIButton) {
        button.backgroundColor = UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        button.frame = CGRect(x: button.frame.origin.x, y: button.frame.origin.y, width: 100, height: 36)
    }
    
    func setupRx() {

        AdConfigController.shared.adConfigObservable(for: configType ?? .thumbnail).subscribe({ [weak self] config in
            guard let config = config.element else {
                return
            }
            self?.adConfig = config
        }).disposed(by: disposeBag)
    }

    @IBAction func load() {
        loadBtn.isEnabled = false

        let adUnitId = adConfig?.adUnitID ?? ""
        let campaignId = adConfig?.campaignID ?? ""
        let creativeId = adConfig?.creativeID ?? ""
        let dspCreativeId = adConfig?.dspCreativeId ?? ""
        let dspRegion = adConfig?.dspRegion ?? ""
        let maxSize = CGSize(
            width: adConfig?.width ?? 0,
            height: adConfig?.height ?? 0
        )
        switch (adConfig?.thumbnailPositionType ?? ThumbnailPositionType.byDefault) {
        case .byDefault:
            self.getController(type: configType ?? .thumbnail)?.load(adUnitId: adUnitId, campaignId: campaignId, creativeId: creativeId, dspCreativeId: dspCreativeId, dspRegion: dspRegion, maxSize: maxSize)
        case .byCorner, .byPosition:
            self.getController(type: configType ?? .thumbnail)?.load(adUnitId: adUnitId, campaignId: campaignId, creativeId: creativeId, dspCreativeId: dspCreativeId, dspRegion: dspRegion, maxSize: maxSize)
        }
    }

    @IBAction func show() {
        let thumbnailPositionType = adConfig?.thumbnailPositionType ?? ThumbnailPositionType.byDefault
        if (thumbnailPositionType == .byPosition || thumbnailPositionType == .byCorner) {
            let position = CGPoint(
                x: adConfig?.xOffset ?? 0,
                y: adConfig?.yOffset ?? 0
            )
            if (thumbnailPositionType == .byPosition) {
                self.getController(type: configType ?? .thumbnail)?.show(at: position)
            } else {
                let corner = adConfig?.corner ?? .bottomRight
                self.getController(type: configType ?? .thumbnail)?.show(at: position, withCorner: corner)
            }
        } else {
            self.getController(type: configType ?? .thumbnail)?.show()
        }
    }

    @IBAction func loadAndShow() {
        loadBtn.isEnabled = false
        
        let adUnitID = adConfig?.adUnitID ?? ""
        let campaignID = adConfig?.campaignID ?? ""
        let creativeID = adConfig?.creativeID ?? ""
        let dspCreativeId = adConfig?.dspCreativeId ?? ""
        let dspRegion = adConfig?.dspRegion ?? ""
        let maxSize = CGSize(
            width: adConfig?.width ?? 0,
            height: adConfig?.height ?? 0
        )
        let thumbnailPositionType = adConfig?.thumbnailPositionType ?? ThumbnailPositionType.byDefault
        if (thumbnailPositionType == .byPosition || thumbnailPositionType == .byCorner) {
            let position = CGPoint(
                x: adConfig?.xOffset ?? 0,
                y: adConfig?.yOffset ?? 0
            )
            if (thumbnailPositionType == .byPosition) {
                self.getController(type: configType ?? .thumbnail)?.loadAndShow(adUnitId: adUnitID,
                                                          campaignId: campaignID,
                                                          creativeId: creativeID,
                                                          dspCreativeId: dspCreativeId,
                                                          dspRegion: dspRegion,
                                                          maxSize: maxSize,
                                                          showAt: position)
            } else {
                let corner = adConfig?.corner ?? .bottomRight
                self.getController(type: configType ?? .thumbnail)?.loadAndShow(adUnitId: adUnitID,
                                                                                campaignId: campaignID,
                                                                                creativeId: creativeID,
                                                                                dspCreativeId: dspCreativeId,
                                                                                dspRegion: dspRegion,
                                                                                maxSize: maxSize,
                                                                                showAt: position,
                                                                                withCorner: corner)
            }
        } else {
            self.getController(type: configType ?? .thumbnail)?.loadAndShow(adUnitId: adUnitID, campaignId: campaignID, creativeId:creativeID, dspCreativeId: dspCreativeId, dspRegion: dspRegion)
        }
    }
    
    func getController(type: AvailableType) -> ThumbnailController? {
        var controller: ThumbnailController?

        switch type {
            case .thumbnail:
                controller = AdsThumbnailController.shared
            default:
                controller = nil
        }

        controller?.delegate = self

        return controller
    }
}

extension ThumbnailCollectionCell: ThumbnailViewDelegate {
    func adConfigChange(_ config: AdConfig) {
        adConfig = config
    }
}

// MARK: - AdControllerDelegate

extension ThumbnailCollectionCell: AdControllerDelegate {

    func didDisplay() {
        loadBtn.isEnabled = true
    }

    func didFail() {
        loadBtn.isEnabled = true
    }
}
