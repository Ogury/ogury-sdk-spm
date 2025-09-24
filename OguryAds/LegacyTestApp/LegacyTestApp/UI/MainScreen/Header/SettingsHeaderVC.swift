//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import UIKit
import WebKit

final class SettingsHeaderVC: UIViewController {

    // MARK: - Properties
    private static let countries =  ["USA", "FRA", "JPN", "SRB"]
    private static let countryKey = "country"
    @IBOutlet var assetKeyTF: UITextField!
    @IBOutlet weak var assetKeyLabel: UILabel!
    @IBOutlet weak var hbRegionLAbel: UILabel!
    @IBOutlet weak var flushCache: UIButton!
    @IBOutlet var countryPickerTextField: UITextField!  {
        didSet {
            countryPickerTextField.delegate = self
        }
    }
    static var selectedCountry: String { UserDefaults.standard.value(forKey: SettingsHeaderVC.countryKey) as? String ?? SettingsHeaderVC.countries[0] }

    @IBOutlet var resetDefaultValueButton: UIButton!
    @IBOutlet weak var setupAssetKeyButton: UIButton!
    
    static var state: Bool = false
    

    // MARK: - Lifecycle

    override func viewDidLoad() {
        
        customizeButtonUI(button:setupAssetKeyButton)
        customizeButtonUI(button:resetDefaultValueButton)
        customizeButtonUI(button:flushCache)
        customizeTextFielduI(textField:assetKeyTF)
        customizeTextFielduI(textField:countryPickerTextField)
        customizeLabel(label:assetKeyLabel)
        customizeLabel(label:hbRegionLAbel)
        assetKeyTF.text = AdConfigController.shared.assetKey()
        attachPicketToCountryTextfield()
        countryPickerTextField.text = SettingsHeaderVC.selectedCountry
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
        // Dismiss the keyboard when the Done button is tapped
        self.view.endEditing(true)
    }
    
    private func attachPicketToCountryTextfield() {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        
        // pickerView
        picker.backgroundColor = UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1)
        picker.layer.shadowColor = UIColor.black.cgColor
        picker.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        countryPickerTextField.inputView = picker
        let dismissView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: self.view.bounds.width, height: 50)))
        
        dismissView.backgroundColor = UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1)
        let closeButton = UIButton()
        closeButton.tintColor = UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1)
        closeButton.addTarget(self, action: #selector(dismissPicker), for: .touchUpInside)
        [.normal, .focused, .selected].forEach({ closeButton.setTitle("Close", for: $0) })
        dismissView.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.bottomMargin.rightMargin.topMargin.equalToSuperview()
        }
        countryPickerTextField.inputAccessoryView = dismissView
    }
    
    @objc
    private func dismissPicker() {
        view.endEditing(true)
    }
    
    @IBAction func setupAssetKey(_ sender: Any) {
        let assetKey = assetKeyTF.text ?? ""
        if(!assetKey.isEmpty) {
            AdConfigController.shared.saveAssetKey(assetKey)
            AdConfigController.shared.updateEnvironment()
        }
    }
    
    @IBAction func resetDefaultValue() {
        AvailableType.allValues.forEach {
            AdConfigController.shared.saveConfig(AdConfigController.shared.defaultAdConfig(for: $0)!, for: $0)
            AdConfigController.shared.saveAssetKey(AdConfigController.shared.defaultAssetKey() ?? "")
            AdConfigController.shared.updateRxConfig()
            assetKeyTF.text = AdConfigController.shared.assetKey()
        }
    }
    
    @IBAction func flushCacheWebview() {
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache], modifiedSince: Date(timeIntervalSince1970: 0), completionHandler:{ })
    }

    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension SettingsHeaderVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        false
    }
}

extension SettingsHeaderVC: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let country = SettingsHeaderVC.countries[row]
        UserDefaults.standard.setValue(country, forKey: SettingsHeaderVC.countryKey)
        countryPickerTextField.text = country
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel
        if let view = view as? UILabel {
            pickerLabel = view
        } else {
            pickerLabel = UILabel()
        }

        let titleData = SettingsHeaderVC.countries[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .medium)
        ])
        
        pickerLabel.attributedText = myTitle
        pickerLabel.adjustsFontSizeToFitWidth = true
        pickerLabel.textAlignment = .center
        pickerLabel.textColor = UIColor.white
        
        return pickerLabel
    }
    
}

extension SettingsHeaderVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { SettingsHeaderVC.countries.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { SettingsHeaderVC.countries[row] }
}
