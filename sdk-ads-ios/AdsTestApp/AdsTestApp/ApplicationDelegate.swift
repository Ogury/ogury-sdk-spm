//
//  ApplicationDelegate.swift
//  AdsTestApp
//
//  Created by Jerome TONNELIER on 26/03/2025.
//

import Foundation

protocol ApplicationDelegate {
    // import
    func share(json: String, filename: String)
    func showImportPanel()
    // consent
    func showConsentNotice()
    // test mode
    func enableTestModeForAllCards(_: Bool)
}
