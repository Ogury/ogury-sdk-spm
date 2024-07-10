//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

protocol AdControllerDelegate: AnyObject {

    func didDisplay()

    func didFail()
}

protocol AdController {

    var delegate: AdControllerDelegate? { get set }
}
