//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ViewChoicesHeaderVC: UIViewController {

    // MARK: - Properties

    @IBOutlet weak var tableView: UITableView!

    var allViewChoices = [AvailableType]()
    var viewChoices = [AvailableType]()

    let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        allViewChoices = AvailableType.allValues

        tableView.tintColor = UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1)
        
        setupRx()
    }

    // MARK: - Functions

    func setupRx() {
        RxSettings.shared
            .adCellsObservable
            .take(1)
            .asDriver(onErrorJustReturn: [])
            .drive { [weak self] cells in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.viewChoices = cells
                strongSelf.tableView.reloadData()
            }
            .disposed(by: disposeBag)
    }

    @IBAction
    func close() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension ViewChoicesHeaderVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allViewChoices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!

        let viewChoice = allViewChoices[indexPath.row]

        cell.textLabel?.text = viewChoice.displayName

        let isChecked = viewChoices.contains(where: { (type) -> Bool in
            return type == viewChoice
        })
        if isChecked {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

}

// MARK: - UITableViewDelegate

extension ViewChoicesHeaderVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let viewChoice = allViewChoices[indexPath.row]

        let isChecked = viewChoices.contains { $0 == viewChoice }

        if let cell = tableView.cellForRow(at: indexPath) {
            if isChecked {
                cell.accessoryType = .none
                viewChoices.removeAll { $0 == viewChoice }
            } else {
                cell.accessoryType = .checkmark
                viewChoices.append(viewChoice)
            }
        }

        let resultChoice = allViewChoices.filter { type in
            return viewChoices.contains { type == $0 }
        }

        RxSettings.shared.setAdCells(resultChoice)
    }
}
