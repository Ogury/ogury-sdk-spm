//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import UIKit
/// used as a passthrough for the banner delegate
public protocol AdLifeCycleDelegate {
    /// Returns the viewController that is hosting the banner ad
    /// - Parameters:
    ///   - banner: the banner ad that needs display
    ///   - adManager: the adManager associated with the banner
    /// - Returns: the viewController that contains the view hosting the banner
    func viewController<T: AdManager>(forBanner banner: T.Ad, adManager: T) -> UIViewController?
    func deleteCard(withId id: UUID)
    // import
    func share(json: String, filename: String)
    func showImportPanel()
    // consent
    func showConsentNotice()
    // test mode
    func enableTestModeForAllCards(_: Bool)
    // log
    func focusLogs(on cardId: String)
}
