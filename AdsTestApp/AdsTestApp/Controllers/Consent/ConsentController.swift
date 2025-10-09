//
//  ConsentManager.swift
//  AdsTestApp
//
//  Created by Jerome TONNELIER on 14/08/2025.
//

import UIKit

struct ConsentController {
    static func resetConsent(viewController: UIViewController) {
        switch SettingsController().consentManager {
            case .inMobi: InmobiConsentManager.shared.resetConsent(viewController: viewController)
            case .adMob: AdMobConsentManager.shared.resetConsent(viewController: viewController)
        }
    }
}
