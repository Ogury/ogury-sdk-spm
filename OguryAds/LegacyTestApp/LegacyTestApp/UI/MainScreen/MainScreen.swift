//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import UIKit
import RxSwift

final class MainScreenViewController: BaseViewController {

    // MARK: - Constants

    static var collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.estimatedItemSize = CGSize(width: 280, height: 100)

        return collectionViewFlowLayout
    }()

    // MARK: - Properties

    @IBOutlet var adsCollectionView: UICollectionView!

    var formatsCollectionView: UICollectionView = {
        UICollectionView(frame: .zero, collectionViewLayout: MainScreenViewController.collectionViewFlowLayout)
    }()

    var adsCells: [AdsCollectionCell]!
    let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupLayout()

        setupRx()

//        AvailableType.allValues.forEach { $0.instance.register(for: adsCollectionView) }

//        adsCollectionView.dataSource = self
//        adsCollectionView.delegate = self
//        adsCollectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 250, right: 0)
//
//        if let flowLayout = adsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            flowLayout.estimatedItemSize = CGSize(width: 280, height: 100)
//        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        formatsCollectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Functions

    func setupViews() {
        view.backgroundColor = .white

        formatsCollectionView.dataSource = self
        formatsCollectionView.delegate = self
        view.addSubview(formatsCollectionView)

        AvailableType.allValues.forEach { $0.instance.register(for: formatsCollectionView) }
    }

    func setupLayout() {
        formatsCollectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            formatsCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            formatsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            formatsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            formatsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
    }

    func setupReactive() {

    }

    func setupRx() {
        RxSettings.shared
            .adCellsObservable
            .subscribe { [weak self] cells in
                guard let cells = cells.element else {
                    return
                }

                self?.adsCells = cells.map { $0.instance }
                self?.adsCollectionView.reloadData()
            }
            .disposed(by: disposeBag)
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

// MARK: - UIPopoverPresentationControllerDelegate

extension MainScreenViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
