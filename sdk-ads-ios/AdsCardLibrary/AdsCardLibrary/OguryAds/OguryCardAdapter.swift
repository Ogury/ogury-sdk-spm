//
//  OguryCardAdapter.swift
//  AdsCardLibrary
//
//  Created by Jerome TONNELIER on 04/04/2025.
//

import UIKit

struct OguryCardAdapter: ACLAdapter {
    var availableAdFormats: [AdAdapterFormatSection] = []
    
    func adManager(for adFormat: any ACLAdapterFormat,
                   options: AdManagerOptions,
                   viewController: UIViewController?,
                   adDelegate: AdLifeCycleDelegate?) throws(ACLAdapterError) -> any AdManager {
        throw .noSuitableAdapterAvailable
    }
}
