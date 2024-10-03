//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

final class LogsCell: AdsCollectionCell {

    // MARK: - Properties
    // change this
    override var estimatedHeight: CGFloat {
        256
    }

    var cellNameLabel = UILabel()
    var clearLogsButton = UIButton()
    var logsTextView = UITextView()
    let disposeBag = DisposeBag()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        setupLayout()
        setupReactive()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupViews()
        setupLayout()
        setupReactive()
    }

    // MARK: - Functions

    func setupViews() {
        layer.cornerRadius = 15

        cellNameLabel.text = "Logs"
        if let labelText = cellNameLabel.text {
            let attributedString = NSMutableAttributedString(string: labelText)
            let range = NSRange(location: 0, length: attributedString.length)
            attributedString.addAttribute(.underlineColor, value: UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1), range: range)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1), range: range)
            cellNameLabel.attributedText = attributedString
        }
        
        cellNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        cellNameLabel.textColor = UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1)
        cellNameLabel.backgroundColor = UIColor.white
        cellNameLabel.textAlignment = .left
        contentView.addSubview(cellNameLabel)

        clearLogsButton.setTitle("Clear logs", for: .normal)
        clearLogsButton.backgroundColor = UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1)
        clearLogsButton.setTitleColor(.white, for: .normal)
        clearLogsButton.layer.cornerRadius = 5
        clearLogsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        clearLogsButton.layer.shadowColor = UIColor.black.cgColor
        clearLogsButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        clearLogsButton.layer.shadowRadius = 4
        clearLogsButton.layer.shadowOpacity = 0.3
        clearLogsButton.frame = CGRect(x: clearLogsButton.frame.origin.x, y: clearLogsButton.frame.origin.y, width: 100, height: 36)
        contentView.addSubview(clearLogsButton)
        
        logsTextView.isUserInteractionEnabled = false
        logsTextView.layoutManager.allowsNonContiguousLayout = false
        logsTextView.layer.borderWidth = 1
        logsTextView.textColor = UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1)
        logsTextView.font = UIFont.systemFont(ofSize: 10)
        logsTextView.backgroundColor = UIColor.white
        logsTextView.layer.borderColor = UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1).cgColor
        logsTextView.layer.borderWidth = 1.0
        logsTextView.layer.cornerRadius = 5.0
        
        contentView.addSubview(logsTextView)
        layer.backgroundColor = UIColor.white.cgColor
    }

    func setupLayout() {
        cellNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.Margins.small)
            make.leading.equalToSuperview().offset(Constants.Margins.small)
            make.height.equalTo(21)
            make.width.equalTo(64)
        }

        clearLogsButton.snp.makeConstraints { make in
            make.centerY.equalTo(cellNameLabel)
            make.trailing.equalToSuperview().offset(-Constants.Margins.small)
            make.height.equalTo(21)
            make.width.equalTo(96)
        }

        logsTextView.snp.makeConstraints { make in
            make.top.equalTo(cellNameLabel.snp.bottom).offset(Constants.Margins.small)
            make.trailing.bottom.equalToSuperview().offset(-Constants.Margins.small)
            make.leading.equalToSuperview().offset(Constants.Margins.small)
        }
    }

    func setupReactive() {
        clearLogsButton.rx
            .tap
            .asDriver()
            .drive(onNext: { [unowned self] in
                self.clearLogs()
            })
            .disposed(by: disposeBag)


        LogsController.shared
            .logsObserver()
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] logs in
                guard let strongSelf = self else {
                    return
                }

                var text = ""
                logs.forEach {
                    text += "\($0)\n"
                }

                strongSelf.logsTextView.text = text

                let stringLength = strongSelf.logsTextView.text.count
                strongSelf.logsTextView.scrollRangeToVisible(NSRange(location: stringLength - 1, length: 0))
            })
            .disposed(by: disposeBag)
    }

    override func updateAdCell(_ type: AvailableType, in viewController: UIViewController) {
        // Mandatory
    }

    func clearLogs() {
        logsTextView.text = ""

        LogsController.shared.clearLogs()
    }
}
