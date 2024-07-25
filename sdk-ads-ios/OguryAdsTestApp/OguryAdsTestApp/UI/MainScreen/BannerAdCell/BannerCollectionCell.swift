//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import OguryAds

final class BannerCollectionCell: AdsCollectionCell {

    // MARK: - Constants

    enum BannerAdsType {
        case banner(identifier: Int, type: BannerType)
        case headerBiddingBanner(identifier: Int, type: BannerType)
        
        init(identifier: Int, specifiedType: AvailableType) {
            switch specifiedType {
                case .banner(let bannerType): self = BannerAdsType.banner(identifier: identifier, type: bannerType)
                default:
                    fatalError("Type has no associated interstitial type.")
            }
        }
    }

    // MARK: - Properties

    override var estimatedHeight: CGFloat {
        600
    }

    @IBOutlet var campaignIdTextField: UITextField!
    @IBOutlet var adUnitIdTextField: UITextField!
    @IBOutlet weak var creativeIDTextField: UITextField!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var segmentType: UISegmentedControl!
    @IBOutlet var containerView: UIView?
    @IBOutlet var bannerView: UIView?
    @IBOutlet var loadButton: UIButton!
    @IBOutlet weak var adUnitL: UILabel!
    @IBOutlet weak var campaignL: UILabel!
    @IBOutlet weak var creativeL: UILabel!
    @IBOutlet weak var destroyButton: UIButton!
    @IBOutlet weak var bannerTypeSegment: UISegmentedControl!
    @IBOutlet weak var heightBannerViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var dspCreativeL: UILabel!
    @IBOutlet weak var widthBannerViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var dspRegionPicker: UIPickerView!
    @IBOutlet weak var dspCreativeTF: UITextField!
    @IBOutlet weak var dspRegionL: UILabel!
    var bannerAdsType: BannerAdsType = .banner(identifier: -1, type: .mpu)
    var bannerType: BannerType = .mpu
    var bannerInstanceId: Int?
    var subscription: Disposable?

    var adConfigurationBehaviourSubject = BehaviorSubject<AdConfig?>(value: nil)
    let disposeBag = DisposeBag()
    
    var regionPickerData: [String] = ["eu-west-1", "us-east-1", "us-west-2", "ap-northeast-1"]
    var selectedValue: String = "eu-west-1"

    // MARK: - Lifecycle

    override func updateAdCell(_ type: AvailableType, in viewController: UIViewController) {
        configType = type

        switch type {
            case .headerBidding(.banner(let bannerType)): bannerAdsType = .headerBiddingBanner(identifier: -1, type: bannerType)
            default: bannerAdsType = .banner(identifier: -1, type: .mpu)
        }

        setupUI()
        
        customizeTextFielduI(textField:dspCreativeTF)
        customizeTextFielduI(textField:campaignIdTextField)
        customizeTextFielduI(textField:adUnitIdTextField)
        customizeTextFielduI(textField:creativeIDTextField)
        campaignIdTextField.keyboardType = .decimalPad
        creativeIDTextField.keyboardType = .decimalPad
        
        customizeLabel(label: nameLabel)
        
        customizeSmallLabel(label: adUnitL)
        customizeSmallLabel(label: campaignL)
        customizeSmallLabel(label: creativeL)
        customizeSmallLabel(label: dspCreativeL)
        customizeSmallLabel(label: dspRegionL)
        
        customizeButtonUI(button: destroyButton)
        customizeButtonUI(button: loadButton)
        
        // pickerView
        dspRegionPicker.backgroundColor = UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1)
        dspRegionPicker.layer.cornerRadius = 15
        dspRegionPicker.layer.shadowColor = UIColor.black.cgColor
        dspRegionPicker.layer.shadowOffset = CGSize(width: 0, height: 2)
        dspRegionPicker.layer.shadowRadius = 4
        dspRegionPicker.layer.shadowOpacity = 0.3
        
        layer.backgroundColor = UIColor.white.cgColor

        segmentType.backgroundColor = UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1)
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1)]
        segmentType.setTitleTextAttributes(titleTextAttributes, for: .selected)
        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentType.setTitleTextAttributes(normalTextAttributes, for: .normal)
        segmentType.tintColor = UIColor.white
        segmentType.layer.cornerRadius = 5.0
        segmentType.clipsToBounds = true
        let font = UIFont.boldSystemFont(ofSize: 16)
        segmentType.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        segmentType.frame = CGRect(x: 20, y: 100, width: 200, height: 36)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width - 40).isActive = true

        setupReactive()
    }

    // MARK: - Functions

    func setupUI() {
        isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = false
        contentView.superview?.sendSubviewToBack(contentView)
        
        dspRegionPicker.delegate = self
        dspRegionPicker.dataSource = self
        
        layer.cornerRadius = 15

        nameLabel.text = configType?.displayName

        segmentType.replaceSegments(segments: BannerType.allCases.map { $0.name })

        // add this so that the set selectedSegmentIndex is triggered after updateAdCell
        // and the good configuration is set
        segmentType
            .rx
            .selectedSegmentIndex
            .flatMap{ _ in self.currentAdConfig() }
                .subscribe(onNext: { [weak self] configuration in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    strongSelf.adConfigurationBehaviourSubject.onNext(configuration)
                })
            .disposed(by: disposeBag)
        segmentType.selectedSegmentIndex = 0

        campaignIdTextField.delegate = self
        adUnitIdTextField.delegate = self
        creativeIDTextField.delegate = self
        dspCreativeTF.delegate = self
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
        UIApplication.shared.keyWindow?.rootViewController?.view.endEditing(true)
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
    
    private func currentAdConfig() -> Observable<AdConfig> {
        switch self.configType ?? .banner(type: bannerType) {
            case .headerBidding:
                return AdConfigController.shared.adConfigObservable(for: .headerBidding(.banner(type: bannerType)))
            default:
                return AdConfigController.shared.adConfigObservable(for: .banner(type: bannerType))
        }
    }

    func setupReactive() {
        segmentType.rx
            .value
            .distinctUntilChanged()
            .map { BannerType.allCases[$0] }
            .do(onNext: { bannerType in
                self.bannerType = bannerType
            })
            .flatMap { _ in self.currentAdConfig() }
            .subscribe(onNext: { [weak self] configuration in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.adConfigurationBehaviourSubject.onNext(configuration)
            })
            .disposed(by: disposeBag)

        adConfigurationBehaviourSubject
            .debug("adConfigurationBehaviourSubject")
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] configuration in
                guard let strongSelf = self, let configuration = configuration else {
                    return
                }

                strongSelf.adUnitIdTextField.text = configuration.adUnitID
                strongSelf.campaignIdTextField.text = configuration.campaignID
                strongSelf.creativeIDTextField.text = configuration.creativeID
                strongSelf.dspCreativeTF.text = configuration.dspCreativeId
                if let region = configuration.dspRegion, !region.isEmpty {
                    self?.selectedValue =  region
                } else {
                    self?.selectedValue = "eu-west-1"
                }
            })
            .disposed(by: disposeBag)

        loadButton.rx
            .tap
            .asDriver()
            .debounce(.milliseconds(300))
            .drive(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }

                strongSelf.load()
            })
            .disposed(by: disposeBag)
    }

    func load() {
        destroy()

        let size = bannerType == .mpu ? OguryAdsBannerSize.mpu_300x250() : OguryAdsBannerSize.small_banner_320x50()

        updateSizeBannerView(height: size.getSize().height, width: size.getSize().width)

        var bannerInstanceID = -1
        switch bannerAdsType {
            case .banner, .headerBiddingBanner: bannerInstanceID = BannerAdControllerStore.shared.createInstance()
        }

        self.bannerInstanceId = bannerInstanceID

        let bannerFormatController = getController(type: bannerAdsType, for: bannerInstanceID)
        switch configType {
            case .headerBidding:
                (bannerFormatController as? BannerAdController)?.loadWithHeaderBidding(adUnitId: adUnitIdTextField.text ?? "",
                                                                                       country: SettingsHeaderVC.selectedCountry,
                                                                                       campaignId: campaignIdTextField.text ?? "",
                                                                                       creativeId: creativeIDTextField.text ?? "",
                                                                                       dspCreativeId: dspCreativeTF.text ?? "",
                                                                                       dspRegion: selectedValue,
                                                                                       maxSize: size,
                                                                                       in: bannerView)
                
            default:
                bannerFormatController?.load(adUnitId: adUnitIdTextField.text ?? "",
                                             campaignId: campaignIdTextField.text ?? "",
                                             creativeId:creativeIDTextField.text ?? "",
                                             dspCreativeId: dspCreativeTF.text ?? "",
                                             dspRegion: selectedValue,
                                             maxSize: size,
                                             inView: bannerView,
                                             withWidth: nil)
        }
    }

    @IBAction func destroy() {
        updateSizeBannerView(height: 0, width: 0)

        if let bannerId = bannerInstanceId {
            BannerAdControllerStore.shared.destroyInstance(for: bannerId)
            bannerInstanceId = nil
        }
    }

    @IBAction func adunitChange() {
        let config = adConfig
        config?.adUnitID = adUnitIdTextField.text ?? ""
        adConfig = config
    }

    @IBAction func campaignChange() {
        let config = adConfig
        config?.campaignID = campaignIdTextField.text ?? ""
        adConfig = config
    }
    
    @IBAction func creativeChanged(_ sender: Any) {
        let config = adConfig
        config?.creativeID = creativeIDTextField.text ?? ""
        adConfig = adConfig
    }

    @IBAction func dspCreativeChanged(_ sender: Any) {
        let config = adConfig
        config?.dspCreativeId = dspCreativeTF.text ?? ""
        adConfig = adConfig
    }
    
    func updateSizeBannerView(height: CGFloat, width: CGFloat) {
        heightBannerViewConstraint.constant = height
        widthBannerViewConstraint.constant = width

        UIView.animate(withDuration: 0.01) {
            self.containerView?.setNeedsLayout()
        }
    }

    func getController(type: BannerAdsType, for identifier: Int) -> BannerFormatController? {
        switch type {
        case .banner, .headerBiddingBanner: return BannerAdControllerStore.shared.getInstance(for: identifier)
        }
    }
}

// MARK: - UIPickerViewDataSource

extension BannerCollectionCell: UIPickerViewDataSource {
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

extension BannerCollectionCell: UIPickerViewDelegate {
    
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

