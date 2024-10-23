//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import UIKit

class AdsCollectionCell: UICollectionViewCell, AdCellAction, UITextFieldDelegate {

    // MARK: - Properties

    var estimatedHeight: CGFloat {
        200
    }
    
    var estimatedWidth: CGFloat {
        352
    }

    var configType: AvailableType?
    var adConfig: AdConfig? {
        didSet {
            if adConfig != nil && configType != nil {
                AdConfigController.shared.saveConfig(adConfig!, for: configType!)
            }
        }
    }

    // MARK: - Functions

    func identifierName() -> String {
        return className() + (self.configType?.configName ?? "") + "Identifier"
    }

    func className() -> String {
        return String(describing: type(of: self))
    }

    func updateAdCell(_ type: AvailableType, in viewController: UIViewController) {
        fatalError("should not be call here")
    }

    func register(for collectionView: UICollectionView) {
        let cellNib = UINib(nibName: className(), bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: identifierName())
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        superview?.endEditing(true)
        return false
    }

}
