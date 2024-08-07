//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import OguryAds
import DDPopoverBackgroundView

@IBDesignable
final class HeaderView: UIView {

    // MARK: - Properties

    let thePicker = UIPickerView()
    let settingButton = UIButton(type: .custom)
    let viewChoicesButton = UIButton(type: .custom)
    let environmentTextField = UITextField()
    let disposeBag = DisposeBag()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        setupLayout()
        setupReactive()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
//
    func setupViews() {
        backgroundColor =  UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1)
        

        AdConfigController.shared.updateEnvironment()

        environmentTextField.backgroundColor = .white
        environmentTextField.textColor = UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1)
        
        environmentTextField.layer.cornerRadius = 5
        environmentTextField.text = Environment.allCases[0].configName
        environmentTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 32))
        environmentTextField.leftViewMode = .always
        addSubview(environmentTextField)

        thePicker.delegate = self
        thePicker.dataSource = self
        environmentTextField.inputView = thePicker
        // pickerView
        thePicker.backgroundColor = UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1)
        thePicker.layer.cornerRadius = 15
        thePicker.layer.shadowColor = UIColor.black.cgColor
        thePicker.layer.shadowOffset = CGSize(width: 0, height: 2)
        thePicker.layer.shadowRadius = 4
        thePicker.layer.shadowOpacity = 0.3

        RxSettings.shared.setEnv(Environment.allCases[0])

        thePicker.selectRow(0, inComponent: 0, animated: false)

        settingButton.setImage(UIImage(named: "gear"), for: .normal)
        settingButton.tintColor = .white
        addSubview(settingButton)

        viewChoicesButton.setTitle("...", for: .normal)
        viewChoicesButton.titleLabel?.font = UIFont.systemFont(ofSize: 22.0, weight: .bold)
        viewChoicesButton.tintColor = .white
        addSubview(viewChoicesButton)
    }

    func setupLayout() {
        environmentTextField.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-8)

            if #available(iOS 11, *) {
                make.leading.equalTo(safeAreaLayoutGuide.snp.leading).offset(24)
            } else {
                make.leading.equalToSuperview().offset(32)
            }

            make.height.equalTo(32)
            make.width.equalTo(192)
        }

        settingButton.snp.makeConstraints { make in
            make.centerY.equalTo(environmentTextField.snp.centerY)
            make.leading.equalTo(environmentTextField.snp.trailing).offset(8)
            make.size.equalTo(32)
        }

        viewChoicesButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-8)

            if #available(iOS 11, *) {
                make.trailing.equalTo(safeAreaLayoutGuide.snp.trailing).offset(-24)
            } else {
                make.trailing.equalToSuperview().offset(-32)
            }

            make.size.equalTo(32)
        }
    }

    func setupReactive() {
        settingButton.rx.tap
            .asDriver()
            .drive(onNext: { [unowned self] in
                self.openPopover(for: "settingVC", target: self.settingButton)
            })
            .disposed(by: disposeBag)

        viewChoicesButton.rx.tap
            .asDriver()
            .drive(onNext: { [unowned self] in
                self.openPopover(for: "viewChoiceVC", target: self.viewChoicesButton)
            })
            .disposed(by: disposeBag)
    }

    func openPopover(for viewControllerIdentifier: String, target: UIView) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier)
        viewController.modalPresentationStyle = .popover

        guard let topController = UIApplication.topViewController() else {
            return
        }

        let controller = viewController.popoverPresentationController
        controller?.sourceView = topController.view
        controller?.sourceRect = target.frame
        controller?.delegate = topController as? UIPopoverPresentationControllerDelegate
        controller?.popoverBackgroundViewClass = DDPopoverBackgroundView.self
        DDPopoverBackgroundView.setContentInset(1)
        DDPopoverBackgroundView.setBackgroundImageCornerRadius(13)
        DDPopoverBackgroundView.setArrowBase(20)
        DDPopoverBackgroundView.setArrowHeight(13)
        DDPopoverBackgroundView.setTintColor(UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1))
        controller?.permittedArrowDirections = .up

        topController.present(viewController, animated: true, completion: nil)
    }
}

// MARK: - UIPickerViewDataSource

extension HeaderView: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        Environment.allCases.count
    }
}

// MARK: - UIPickerViewDelegate

extension HeaderView: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        Environment.allCases[row].configName
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        environmentTextField.resignFirstResponder()

        let environment = Environment.allCases[row]

        RxSettings.shared.setEnv(environment)

        environmentTextField.text = environment.configName

        AdConfigController.shared.updateEnvironment()
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel
        if let view = view as? UILabel {
            pickerLabel = view
        } else {
            pickerLabel = UILabel()
        }

        let titleData = Environment.allCases[row].configName
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
