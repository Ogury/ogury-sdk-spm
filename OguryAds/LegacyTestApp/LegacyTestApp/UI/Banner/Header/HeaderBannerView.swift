//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import UIKit
import OguryAds
import DDPopoverBackgroundView

@IBDesignable
final class HeaderBannerView: UIView {

    // MARK: - Properties

    let thePicker = UIPickerView()
    var backBtn: UIButton!
    var settingBtn: UIButton!
    var viewChoiceBtn: UIButton!
    var environmentTextField: UITextField!

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!

        configure()
    }

    // MARK: - Functions

    fileprivate func addButton(_ width: CGFloat, _ topMargin: Double, _ heightTF: Int) {
        backBtn = UIButton(type: .custom)
        backBtn.setTitle("<-", for: .normal)
        backBtn.frame = CGRect(x: 8, y: Int(topMargin), width: heightTF, height: heightTF)
        backBtn.titleLabel?.font = UIFont.systemFont(ofSize: 22.0, weight: .bold)
        backBtn.tintColor = .white
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        addSubview(backBtn)

        settingBtn = UIButton(type: .custom)
        settingBtn.setImage(UIImage(named: "gear"), for: .normal)
        settingBtn.frame = CGRect(x: Int(width * 0.5),
                                  y: Int(topMargin) + Int(Double(heightTF) * 0.1),
                                  width: Int(Double(heightTF) * 0.8),
                                  height: Int(Double(heightTF) * 0.8))
        settingBtn.tintColor = .white
        settingBtn.addTarget(self, action: #selector(gotoBannerChoice), for: .touchUpInside)
        addSubview(settingBtn)

        viewChoiceBtn = UIButton(type: .custom)
        viewChoiceBtn.setTitle("...", for: .normal)
        viewChoiceBtn.frame = CGRect(x: Int(width) - Int(width * 0.1),
                                     y: Int(topMargin),
                                     width: heightTF,
                                     height: heightTF)
        viewChoiceBtn.titleLabel?.font = UIFont.systemFont(ofSize: 22.0, weight: .bold)
        viewChoiceBtn.tintColor = .white
        viewChoiceBtn.addTarget(self, action: #selector(gotoSettings), for: .touchUpInside)
        addSubview(viewChoiceBtn)
    }

    func configure() {
        environmentTextField = UITextField()
        var heightHeader: CGFloat = 45
        heightHeader += UIApplication.shared.statusBarFrame.height

        let heightTF = 32
        let topMargin = Double(Int(heightHeader) - heightTF - 8)
        let width = UIScreen.main.bounds.width

        environmentTextField.frame = CGRect(x: 16 + heightTF, y: Int(topMargin), width: Int(width * 0.3), height: heightTF)
        environmentTextField.backgroundColor = .white
        environmentTextField.layer.cornerRadius = 5
        addSubview(environmentTextField)

        thePicker.delegate = self
        thePicker.dataSource = self
        let defaultIndex = 1
        environmentTextField.text = Environment.allCases[defaultIndex].configName
        AdConfigController.shared.updateEnvironment()
        RxSettings.shared.setEnv(Environment.allCases[defaultIndex])
        thePicker.selectRow(defaultIndex, inComponent: 0, animated: false)
        environmentTextField.inputView = thePicker

        if #available(iOS 11.0, *) {
            backgroundColor = UIColor(named: "topBarColor")
        } else {
            backgroundColor = .red
        }

        addButton(width, topMargin, heightTF)
    }

    @objc
    func back() {
        let viewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "mainVC")

        UIApplication.shared.keyWindow?.rootViewController = viewController
    }

    @objc
    func gotoSettings() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "settingVC")
        viewController.modalPresentationStyle = .popover

        let topController = UIApplication.topViewController()!

        let controller = viewController.popoverPresentationController
        controller?.sourceView = topController.view
        controller?.sourceRect = viewChoiceBtn.frame
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

    @objc
    func gotoBannerChoice() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "bannerChoiceVC")
        viewController.modalPresentationStyle = .popover

        let topController = UIApplication.topViewController()!

        let controller = viewController.popoverPresentationController
        controller?.sourceView = topController.view
        controller?.sourceRect = settingBtn.frame
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

// MARK: - UIPickerViewDataSource

extension HeaderBannerView: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Environment.allCases.count
    }
}

// MARK: - UIPickerViewDelegate

extension HeaderBannerView: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Environment.allCases[row].configName
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        environmentTextField.resignFirstResponder()

        RxSettings.shared.setEnv(Environment.allCases[row])

        environmentTextField.text = Environment.allCases[row].configName

        AdConfigController.shared.updateEnvironment()
    }
}
