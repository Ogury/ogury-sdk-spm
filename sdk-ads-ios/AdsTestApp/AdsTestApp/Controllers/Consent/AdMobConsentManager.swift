//
//  AdMobConsentManager.swift
//  AdsTestApp
//
//  Created by Jerome TONNELIER on 26/03/2025.
//

import Foundation
import UserMessagingPlatform
import AppTrackingTransparency

final class AdMobConsentManager {
    
    // MARK: - Initialization
    static let shared = AdMobConsentManager()
    private init() {}
    
    // MARK: - Functions
    func askForUserConsent(viewController: UIViewController) {
        requestConsentInfoUpdate(viewController: viewController)
    }
    
    func showConsent(from viewController: UIViewController) {
        let parameters = RequestParameters()
        parameters.isTaggedForUnderAgeOfConsent = false
        ConsentForm.presentPrivacyOptionsForm(from: viewController) {requestConsentError in
            if let requestConsentError {
                print("Error: \(requestConsentError.localizedDescription)")
                return
            }
            
        }
    }
    
    func resetConsent(viewController: UIViewController) {
        ConsentInformation.shared.reset()
        requestConsentInfoUpdate(viewController: viewController)
    }
    
    private func requestConsentInfoUpdate(viewController: UIViewController) {
        let parameters = RequestParameters()
        parameters.isTaggedForUnderAgeOfConsent = false
        ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { requestConsentError in
            if let requestConsentError {
                print("Error: \(requestConsentError.localizedDescription)")
                return
            }
            ConsentForm.loadAndPresentIfRequired(from: viewController) { loadAndPresentError in
                if let loadAndPresentError {
                    print("Error: \(loadAndPresentError.localizedDescription)")
                    return
                }
            }
        }
    }
}
