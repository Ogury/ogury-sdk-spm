//
//  InterstitialCollectionCell.swift
//  OguryAdsTestApp
//
//  Created by Pernic on 16/03/2020.
//  Copyright © 2020 co.ogury. All rights reserved.
//

import UIKit
import RxSwift

class InterstitialCollectionCell: AdsCollectionCell {

    override var estimatedHeight: CGFloat {
        265
    }
    
    override var estimatedWidth: CGFloat {
        352
    }

    var viewController: UIViewController?
    var observer: [NSKeyValueObservation]?
    
    var regionPickerData: [String] = ["eu-west-1", "us-east-1", "us-west-2", "ap-northeast-1"]
    var selectedValue: String = "eu-west-1"

    @IBOutlet var campaignIdTF: UITextField!
    @IBOutlet var adUnitIdTF: UITextField!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var creativeIdTF: UITextField!
    @IBOutlet weak var dspCreativeIdTF: UITextField!
    @IBOutlet weak var dspRegionPicker: UIPickerView!
    
    @IBOutlet weak var adUnitLabel: UILabel!
    @IBOutlet weak var dspRegionLabel: UILabel!
    @IBOutlet weak var dspCreativeLabel: UILabel!
    @IBOutlet weak var creativeLabel: UILabel!
    @IBOutlet weak var campaignLabel: UILabel!
    
    @IBOutlet weak var loaded: UIButton!
    @IBOutlet var loadBtn: UIButton!
    @IBOutlet var showBtn: UIButton!
    @IBOutlet var loadAndShowBtn: UIButton!

    override var configType: AvailableType?  {
        didSet {
            guard let configType,
                  let loadBtn ,
                  let showBtn else { return }
            switch configType {
                case .headerBidding:
                    loadBtn.isHidden = false
                    showBtn.isHidden = false
                    
                default: ()
            }
        }
    }


    let disposeBag = DisposeBag()

    override func updateAdCell(_ type: AvailableType, in viewController: UIViewController) {
        self.viewController = viewController
        configType = type
        setupRx()
        setupUI()
        
        /*
        if let index = self.regionPickerData.firstIndex(of: self.selectedValue) {
            self.dspRegionPicker.selectRow(index, inComponent: 1, animated: false)
        } else {
            self.selectedValue = "eu-west-1"
        }
         */
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
        
        
        dspRegionPicker.delegate = self
        dspRegionPicker.dataSource = self
        
        nameLabel.text = configType?.displayName

        adUnitIdTF.addTarget(self, action: #selector(textFieldTextChange), for: .editingChanged)
        campaignIdTF.addTarget(self, action: #selector(textFieldTextChange), for: .editingChanged)
        creativeIdTF.addTarget(self, action: #selector(textFieldTextChange), for: .editingChanged)
        dspCreativeIdTF.addTarget(self, action: #selector(textFieldTextChange), for: .editingChanged)

        layer.cornerRadius = 15

        campaignIdTF.delegate = self
        adUnitIdTF.delegate = self
        creativeIdTF.delegate = self
        dspCreativeIdTF.delegate = self
        
        // buttons
        customizeButtonUI(button:loadBtn)
        customizeButtonUI(button:showBtn)
        customizeButtonUI(button:loadAndShowBtn)
        customizeButtonUI(button:loaded)
        
        // text fields
        customizeTextFielduI(textField: adUnitIdTF)
        customizeTextFielduI(textField: campaignIdTF)
        customizeTextFielduI(textField: creativeIdTF)
        customizeTextFielduI(textField: dspCreativeIdTF)
        campaignIdTF.keyboardType = .decimalPad
        creativeIdTF.keyboardType = .decimalPad
        
        // pickerView
        dspRegionPicker.backgroundColor = UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1)
        dspRegionPicker.layer.cornerRadius = 15
        dspRegionPicker.layer.shadowColor = UIColor.black.cgColor
        dspRegionPicker.layer.shadowOffset = CGSize(width: 0, height: 2)
        dspRegionPicker.layer.shadowRadius = 4
        dspRegionPicker.layer.shadowOpacity = 0.3
        
        // label
        customizeLabel(label: nameLabel)
        
        //small label
        customizeSmallLabel(label: dspRegionLabel)
        customizeSmallLabel(label: adUnitLabel)
        customizeSmallLabel(label: dspCreativeLabel)
        customizeSmallLabel(label: creativeLabel)
        customizeSmallLabel(label: campaignLabel)
        
        // view
        layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
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
    
    func customizeTextFielduI(textField: UITextField) {
        textField.borderStyle = .roundedRect
        textField.layer.borderWidth = 1
        textField.textColor = UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1)
        textField.font = UIFont.systemFont(ofSize: 16)
        if (textField.text != nil && textField.text == "") {
            let placeholderText = "Enter text here"
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholderText,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 0.5)]
            )
        }
        
        textField.backgroundColor = UIColor.white
        textField.layer.borderColor = UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1).cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5.0
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonAction))
        
        toolbar.setItems([flexSpace, doneButton], animated: true)
        
        textField.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonAction() {
        self.viewController?.view.endEditing(true)
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
    
    func customizeSmallLabel(label: UILabel) {
        label.textColor = UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 12)
    }

    func setupRx() {
        guard let configType else { return }
        
        AdConfigController.shared
            .adConfigObservable(for: configType)
            .subscribe { [weak self] config in
                guard let config = config.element else {
                    return
                }

                self?.campaignIdTF.text = config.campaignID
                self?.adUnitIdTF.text = config.adUnitID
                self?.creativeIdTF.text = config.creativeID
                self?.dspCreativeIdTF.text = config.dspCreativeId
                if let region = config.dspRegion, !region.isEmpty {
                    self?.selectedValue =  region
                } else {
                    self?.selectedValue = "eu-west-1"
                }
                self?.adConfig = config
            }
            .disposed(by: disposeBag)
    }

    @objc func textFieldTextChange(_ textField: UITextField) {
        if textField == campaignIdTF {
            adConfig?.campaignID = campaignIdTF.text ?? ""
        }

        if textField == adUnitIdTF {
            adConfig?.adUnitID = adUnitIdTF.text ?? ""
        }
        
        if textField == creativeIdTF {
            adConfig?.creativeID = creativeIdTF.text ?? ""
        }
        
        if textField == dspCreativeIdTF {
            adConfig?.dspCreativeId = dspCreativeIdTF.text ?? ""
        }
        
    }

    @IBAction func load() {
        guard let configType,
              let adUnitId = getAdUnitId(),
              let viewController else { return }

        loadBtn.isEnabled = true
        let controller = getController(type: configType)
        
        switch configType {
            case .headerBidding(let nestedType):
                switch nestedType {
                    case .rewarded:
                        (controller as? AdsOptinVideoController)?.loadWithHeaderBidding(adUnitId: adUnitId,
                                                                                        country: SettingsHeaderVC.selectedCountry,
                                                                                        campaignId: campaignIdTF.text,
                                                                                        creativeId: creativeIdTF.text,
                                                                                        dspCreativeId: dspCreativeIdTF.text,
                                                                                        dspRegion: selectedValue,
                                                                                        in: viewController)
                        
                    case .interstitial:
                        (controller as? AdsInterstitialController)?.loadWithHeaderBidding(adUnitId: adUnitId,
                                                                                          country: SettingsHeaderVC.selectedCountry,
                                                                                          campaignId: campaignIdTF.text,
                                                                                          creativeId: creativeIdTF.text,
                                                                                          dspCreativeId: dspCreativeIdTF.text,
                                                                                          dspRegion: selectedValue,
                                                                                          in: viewController)
                        
                        
                    default: ()
                }
                
            default:
            controller.load(adUnitId: adUnitId, campaignId: campaignIdTF.text, creativeId: creativeIdTF.text, dspCreativeId: dspCreativeIdTF.text, dspRegion: selectedValue)
        }
    }

    @IBAction func show() {
        guard let configType else { return }
        
        let controller = getController(type: configType)

        if let viewController = viewController {
            controller.show(in: viewController)
        }
    }
    
    @IBAction func isLoaded() {
        guard let configType else { return }
        
        let controller = getController(type: configType)
        LogsController.shared.addLogs("Ad loaded : \(controller.isLoaded()) ")
    }

    @IBAction func loadAndShow() {
        guard let configType,
              let adUnitId = getAdUnitId() else { return }

        loadBtn.isEnabled = true

        let controller = getController(type: configType)
        switch configType {
            case .headerBidding(let nestedType):
                guard let viewController else { return }
                switch nestedType {
                    case .rewarded:
                        (controller as? AdsOptinVideoController)?.loadWithHeaderBidding(adUnitId: adUnitId,
                                                                                        country: SettingsHeaderVC.selectedCountry,
                                                                                        campaignId: campaignIdTF.text,
                                                                                        creativeId: creativeIdTF.text,
                                                                                        dspCreativeId: dspCreativeIdTF.text,
                                                                                        dspRegion: selectedValue,
                                                                                        in: viewController)
                        
                    case .interstitial:
                        (controller as? AdsInterstitialController)?.loadWithHeaderBidding(adUnitId: adUnitId,
                                                                                          country: SettingsHeaderVC.selectedCountry,
                                                                                          campaignId: campaignIdTF.text,
                                                                                          creativeId: creativeIdTF.text,
                                                                                          dspCreativeId: dspCreativeIdTF.text,
                                                                                          dspRegion: selectedValue,
                                                                                          in: viewController)
                        
                    default: ()
                }
                
            default:
                if let viewController = viewController {
                    controller.loadAndShow(adUnitId: adUnitId, campaignId: campaignIdTF.text, creativeId: creativeIdTF.text, dspCreativeId: dspCreativeIdTF.text, dspRegion: selectedValue, in: viewController)
                }
        }
    }

    func getAdUnitId() -> String? {
        guard let adUnitId = adUnitIdTF.text, !adUnitId.isEmpty else {
            LogsController.shared.addLogs("Ad unit id must be not empty")
            return nil
        }

        return adUnitId
    }

    func getController(type: AvailableType) -> AdsFullscreenController {
        var controller: AdsFullscreenController

        switch type {
            case .interstitial,
                .headerBidding(.interstitial):
                controller = AdsInterstitialController.shared
            case .rewarded,
                 .headerBidding(.rewarded):
                controller = AdsOptinVideoController.shared
            default: fatalError()
        }

        controller.delegate = self
        return controller
    }

    @IBAction
    func adunitChange() {
        let config = adConfig
        config?.adUnitID = adUnitIdTF.text ?? ""
        adConfig = config
    }

    @IBAction
    func campaignChange() {
        let config = adConfig
        config?.campaignID = campaignIdTF.text ?? ""
        adConfig = config
    }
    
    @IBAction
    func creativeChange(_ sender: Any) {
        let config = adConfig
        config?.creativeID = creativeIdTF.text ?? ""
        adConfig = config
    }
    
    @IBAction
    func dspCreativeIdChange(_ sender: Any) {
        let config = adConfig
        config?.dspCreativeId = dspCreativeIdTF.text ?? ""
        adConfig = config
    }
    
}

// MARK: - AdControllerDelegate

extension InterstitialCollectionCell: AdControllerDelegate {

    func didDisplay() {
        loadBtn.isEnabled = true
    }

    func didFail() {
        loadBtn.isEnabled = true
    }
}

// MARK: - UIPickerViewDataSource

extension InterstitialCollectionCell: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return regionPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return regionPickerData[row]
    }
    
}

// MARK: - AdControllerDelegate

extension InterstitialCollectionCell: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedValue = regionPickerData[row]
        let config = adConfig
        config?.dspRegion = selectedValue
        adConfig = config
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel
        if let view = view as? UILabel {
            pickerLabel = view
        } else {
            pickerLabel = UILabel()
        }

        let titleData = regionPickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ])
        
        pickerLabel.attributedText = myTitle
        pickerLabel.adjustsFontSizeToFitWidth = true
        pickerLabel.textAlignment = .center
        pickerLabel.textColor = UIColor.white
        
        return pickerLabel
    }

}
