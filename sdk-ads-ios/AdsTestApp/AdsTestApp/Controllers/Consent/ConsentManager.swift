//
//  Copyright © 2020-present Ogury. All rights reserved.
//

import Foundation
import UserMessagingPlatform
import AppTrackingTransparency
import OguryChoiceManager

final class ConsentManager {

    // MARK: - Initialization
    static let shared = ConsentManager()
    private init() {}

    // MARK: - Functions
    func askForUserConsent(viewController: UIViewController) {
        requestConsentInfoUpdate(viewController: viewController)
    }
    
    func showConsent(from viewController: UIViewController) {
        let parameters = UMPRequestParameters()
        parameters.tagForUnderAgeOfConsent = false
        UMPConsentForm.presentPrivacyOptionsForm(from: viewController) {requestConsentError in
            if let requestConsentError {
                print("Error: \(requestConsentError.localizedDescription)")
                return
            }
            
        }
    }

    func resetConsent(viewController: UIViewController) {
        UMPConsentInformation.sharedInstance.reset()
        requestConsentInfoUpdate(viewController: viewController)
    }

    private func requestConsentInfoUpdate(viewController: UIViewController) {
        let parameters = UMPRequestParameters()
        parameters.tagForUnderAgeOfConsent = false
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) { requestConsentError in
            if let requestConsentError {
                print("Error: \(requestConsentError.localizedDescription)")
                return
            }
            UMPConsentForm.loadAndPresentIfRequired(from: viewController) { loadAndPresentError in
                if let loadAndPresentError {
                    print("Error: \(loadAndPresentError.localizedDescription)")
                    return
                }
            }
        }
    }
}
