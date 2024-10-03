//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

final class MainScreenViewController: BaseViewController {

    // MARK: - Constants

    static let headerHeight: CGFloat = 45

    static var collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumLineSpacing = 10
        collectionViewFlowLayout.minimumInteritemSpacing = 0

        return collectionViewFlowLayout
    }()

    // MARK: - Properties

    let headerView = HeaderView()
    lazy var headerViewHeightConstraint = headerView.heightAnchor.constraint(equalToConstant: Self.headerHeight + UIApplication.shared.statusBarFrame.height)
    lazy var formatsCollectionView: UICollectionView = {
        UICollectionView(frame: .zero, collectionViewLayout: MainScreenViewController.collectionViewFlowLayout)
    }()

    var adsCells: [AdsCollectionCell]!
    let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupLayout()
        setupReactive()
    }

    // MARK: - Functions

    func setupViews() {
        view.addSubview(headerView)
        formatsCollectionView.contentInset = UIEdgeInsets(vertical: 10, horizontal: 0)
        formatsCollectionView.backgroundColor = UIColor(red: 0.90, green: 0.91, blue: 0.92, alpha: 1.0)
        formatsCollectionView.dataSource = self
        formatsCollectionView.delegate = self
        view.addSubview(formatsCollectionView)
        AvailableType.allValues.forEach { $0.instance?.register(for: formatsCollectionView) }
    }

    func setupLayout() {
        headerView.snp.makeConstraints { make in
            make.top.trailing.leading.equalToSuperview()
            make.height.equalTo(Self.headerHeight + UIApplication.shared.statusBarFrame.height)
        }

        formatsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.trailing.bottom.leading.equalToSuperview()
        }
    }

    func setupReactive() {
        NotificationCenter.default.rx
            .notification(UIDevice.orientationDidChangeNotification)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }

                strongSelf.updateHeaderConstraints()
            })
            .disposed(by: disposeBag)

        RxSettings.shared
            .adCellsObservable
            .subscribe { [weak self] cells in
                guard let strongSelf = self, let cells = cells.element else {
                    return
                }

                strongSelf.adsCells = cells.compactMap { $0.instance }
                strongSelf.formatsCollectionView.reloadData()
            }
            .disposed(by: disposeBag)
    }

    func updateHeaderConstraints() {
        var headerHeight = Self.headerHeight

        if #available(iOS 13.0, *) {
            if let keyWindow = UIApplication.shared.keyWindow, let windowScene = keyWindow.windowScene {
                headerHeight += windowScene.interfaceOrientation.isPortrait ? 47 : 0
            }
        } else {
            headerHeight += UIApplication.shared.statusBarOrientation.isPortrait ? 47 : 0
        }

        headerView.snp.updateConstraints { update in
            update.height.equalTo(headerHeight)
        }

        formatsCollectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - UICollectionViewDataSource

extension MainScreenViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return adsCells.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifierName = adsCells[indexPath.row].identifierName()

        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifierName, for: indexPath) as? AdsCollectionCell {
            if adsCells[indexPath.row].configType != nil {
                cell.updateAdCell(adsCells[indexPath.row].configType!, in: self)
            }
            return cell
        }

        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegate

extension MainScreenViewController: UICollectionViewDelegate {

}

// MARK: - UICollectionViewDelegateFlowLayout

extension MainScreenViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: adsCells[indexPath.row].estimatedWidth, height: adsCells[indexPath.row].estimatedHeight)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension MainScreenViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
