//
//  Copyright © 2020 co.ogury All rights reserved.
//

import UIKit
import RxSwift
import OguryAds

@IBDesignable
class ThumbnailView: UIView {
    
    var segmentType: UISegmentedControl!
    
    var adUnitIDLabel: UILabel!
    var adUnitIDTextField: UITextField!
    var campaignIDLabel: UILabel!
    var campaignIDField: UITextField!
    var creativeIDLabel: UILabel!
    var creativeIDField: UITextField!
    var dspCreativeIDLabel: UILabel!
    var dspCreativeIDField: UITextField!
    var dspRegionLabel: UILabel!
    var dspRegionPicker: UIPickerView!
    
    var xLabel: UILabel!
    var xTextField: UITextField!
    var yLabel: UILabel!
    var yTextField: UITextField!
    
    var widthLabel: UILabel!
    var widthTextField: UITextField!
    var heightLabel: UILabel!
    var heightTextField: UITextField!
    
    var segmentCorner: UISegmentedControl!
    
    var defaultView: UIView!
    var titleDefaultView: UILabel!
    
    var cornerView: UIView!
    var positionView: UIView!
    
    
    var regionPickerData: [String] = ["eu-west-1", "us-east-1", "us-west-2", "ap-northeast-1"]
    var selectedValue: String = "eu-west-1"
    
    var adConfig: AdConfig!
    let disposeBag = DisposeBag()
    
    weak var delegate: ThumbnailViewDelegate? {
        didSet {
            delegate?.adConfigChange(self.adConfig)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func setupRx() {
        
        AdConfigController.shared.adConfigObservable(for: .thumbnail).subscribe({ [weak self] config in
            guard let config = config.element, let strongSelf = self else {
                return
            }
            strongSelf.adConfig = config
            strongSelf.campaignIDField.text = config.campaignID
            strongSelf.creativeIDField.text = config.creativeID
            strongSelf.adUnitIDTextField.text = config.adUnitID
            strongSelf.dspCreativeIDField.text = config.dspCreativeId
            if let region = config.dspRegion, !region.isEmpty {
                self?.selectedValue =  region
            } else {
                self?.selectedValue = "eu-west-1"
            }
            strongSelf.adUnitIDTextField.text = config.adUnitID
            strongSelf.xTextField.text = "\(config.xOffset ?? 0)"
            strongSelf.yTextField.text = "\(config.yOffset ?? 0)"
            strongSelf.widthTextField.text = "\(config.width ?? 0)"
            strongSelf.heightTextField.text = "\(config.height ?? 0)"
            strongSelf.segmentCorner.selectedSegmentIndex = config.corner?.rawValue ?? 0
            strongSelf.segmentType.selectedSegmentIndex = strongSelf.getSelectedSegmentTypeIndex(config: config)
            strongSelf.selectView()
        }).disposed(by: disposeBag)
    }
    
    func customizeSmallLabel(label: UILabel) {
        label.textColor = UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 12)
    }
    
    func customizeSegment(segment: UISegmentedControl) {
        segment.backgroundColor = UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1)
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1)]
        segment.setTitleTextAttributes(titleTextAttributes, for: .selected)
        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segment.setTitleTextAttributes(normalTextAttributes, for: .normal)
        segment.tintColor = UIColor.white
        segment.layer.cornerRadius = 5.0
        segment.clipsToBounds = true
        let font = UIFont.boldSystemFont(ofSize: 16)
        segment.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        segment.frame = CGRect(x: 20, y: 100, width: 200, height: 36)
    }
    
    
    func getSelectedSegmentTypeIndex(config: AdConfig) -> Int {
        guard let thumbnailPositionType = config.thumbnailPositionType else {
            return 0
        }
        return thumbnailPositionType.rawValue
    }
    
    func initCommonUI() {
        segmentType = UISegmentedControl(items: ThumbnailPositionType.allCases.map {$0.name})
        segmentType.addTarget(self, action: #selector(self.selectView), for: .valueChanged)
        segmentType.tintColor = .black
        
        customizeSegment(segment: segmentType)
        
        segmentCorner = UISegmentedControl(items: ["Top Right", "Top Left", "Bot. Left", "Bot. Right"])
        segmentCorner.addTarget(self, action: #selector(self.selectCorner), for: .valueChanged)
        segmentCorner.tintColor = .black
        
        customizeSegment(segment: segmentCorner)
        
        layer.cornerRadius = 5
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        backgroundColor = .clear
        
        adUnitIDLabel = UILabel()
        adUnitIDLabel.text = "Ad unit"
        
        campaignIDLabel = UILabel()
        campaignIDLabel.text = "Campaign"
        
        creativeIDLabel = UILabel()
        creativeIDLabel.text = "Creative"
        
        xLabel = UILabel()
        yLabel = UILabel()
        
        widthLabel = UILabel()
        widthLabel.text = "Width"
        
        heightLabel = UILabel()
        heightLabel.text = "Height"
        
        dspRegionLabel = UILabel()
        dspRegionLabel.text = "Dsp region"
        
        dspCreativeIDLabel = UILabel()
        dspCreativeIDLabel.text = "Dsp creative"
        
        customizeSmallLabel(label: adUnitIDLabel)
        customizeSmallLabel(label: campaignIDLabel)
        customizeSmallLabel(label: creativeIDLabel)
        customizeSmallLabel(label: xLabel)
        customizeSmallLabel(label: yLabel)
        customizeSmallLabel(label: widthLabel)
        customizeSmallLabel(label: heightLabel)
        customizeSmallLabel(label: dspRegionLabel)
        customizeSmallLabel(label: dspCreativeIDLabel)
        
        dspCreativeIDField = UITextField()
        dspCreativeIDField.backgroundColor = .clear
        applyTextFieldUI(on: dspCreativeIDField)
        dspCreativeIDField.addTarget(self, action: #selector(self.dspCreativeIdChanged), for: .editingChanged)
        
        adUnitIDTextField = UITextField()
        adUnitIDTextField.backgroundColor = .clear
        applyTextFieldUI(on: adUnitIDTextField)
        adUnitIDTextField.addTarget(self, action: #selector(self.adUnitChanged), for: .editingChanged)
        
        campaignIDField = UITextField()
        campaignIDField.backgroundColor = .clear
        applyTextFieldUI(on: campaignIDField)
        campaignIDField.addTarget(self, action: #selector(self.campaignChanged), for: .editingChanged)
        
        creativeIDField = UITextField()
        creativeIDField.backgroundColor = .clear
        applyTextFieldUI(on: creativeIDField)
        creativeIDField.addTarget(self, action: #selector(self.creativeChanged), for: .editingChanged)
        
        xTextField = UITextField()
        applyTextFieldUI(on: xTextField)
        xTextField.addTarget(self, action: #selector(self.xChanged), for: .editingChanged)
        
        yTextField = UITextField()
        applyTextFieldUI(on: yTextField)
        yTextField.addTarget(self, action: #selector(self.yChanged), for: .editingChanged)
        
        widthTextField = UITextField()
        applyTextFieldUI(on: widthTextField)
        widthTextField.addTarget(self, action: #selector(self.widthChanged), for: .editingChanged)
        
        heightTextField = UITextField()
        applyTextFieldUI(on: heightTextField)
        heightTextField.addTarget(self, action: #selector(self.heightChanged), for: .editingChanged)
        
        // pickerView
        dspRegionPicker = UIPickerView()
        dspRegionPicker.backgroundColor = UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1)
        dspRegionPicker.layer.cornerRadius = 15
        dspRegionPicker.layer.shadowColor = UIColor.black.cgColor
        dspRegionPicker.layer.shadowOffset = CGSize(width: 0, height: 2)
        dspRegionPicker.layer.shadowRadius = 4
        dspRegionPicker.layer.shadowOpacity = 0.3
        
        dspRegionPicker.delegate = self
        dspRegionPicker.dataSource = self
    }
    
    func applyTextFieldUI(on textField: UITextField) {
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
        UIApplication.shared.keyWindow?.rootViewController?.view.endEditing(true)
    }
    
    func commonInit() {
        initCommonUI()
        initDefaultView()
        initPositionView()
        initCornerView()
        
        addSubview(segmentType)
        
        defaultView.isHidden = true
        cornerView.isHidden = true
        positionView.isHidden = true
        
        setupRx()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        segmentType.frame = CGRect(x: 0, y: 0, width: frame.width, height: 30)
        updateFrameForCurrentPanel()
    }
    
    @objc func selectView() {
        updateLayoutForCurrentPanel()
        updateFrameForCurrentPanel()
        adConfig.thumbnailPositionType = ThumbnailPositionType.init(rawValue: segmentType.selectedSegmentIndex)
        delegate?.adConfigChange(adConfig)
    }
    
    @objc func selectCorner() {
        adConfig.corner = OguryRectCorner(rawValue: segmentCorner.selectedSegmentIndex)
        delegate?.adConfigChange(adConfig)
    }
    
    @objc func adUnitChanged() {
        adConfig.adUnitID = adUnitIDTextField.text
        delegate?.adConfigChange(adConfig)
    }
    
    @objc func dspCreativeIdChanged() {
        adConfig.dspCreativeId = dspCreativeIDField.text
        delegate?.adConfigChange(adConfig)
    }
    
    @objc func campaignChanged() {
        adConfig.campaignID = campaignIDField.text
        delegate?.adConfigChange(adConfig)
    }
    
    @objc func creativeChanged() {
        adConfig.creativeID = creativeIDField.text
        delegate?.adConfigChange(adConfig)
    }
    
    @objc func xChanged() {
        adConfig.xOffset = Int(self.xTextField.text ?? "")
        delegate?.adConfigChange(adConfig)
    }
    
    @objc func yChanged() {
        adConfig.yOffset = Int(self.yTextField.text ?? "")
        delegate?.adConfigChange(adConfig)
    }
    
    @objc func widthChanged() {
        adConfig.width = Int(self.widthTextField.text ?? "")
        delegate?.adConfigChange(adConfig)
    }
    
    @objc func heightChanged() {
        adConfig.height = Int(self.heightTextField.text ?? "")
        delegate?.adConfigChange(adConfig)
    }
    
}
    
// MARK: - UIPickerViewDataSource
extension ThumbnailView: UIPickerViewDataSource {
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
extension ThumbnailView: UIPickerViewDelegate {
        
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
