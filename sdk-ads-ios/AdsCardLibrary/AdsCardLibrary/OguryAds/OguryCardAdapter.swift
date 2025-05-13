//
//  OguryCardAdapter.swift
//  AdsCardLibrary
//
//  Created by Jerome TONNELIER on 04/04/2025.
//

import UIKit

struct OguryCardAdapter: AdsCardAdapter {
    var availableAdFormats: [AdAdapterFormatSection] = []
    
    func adManager(for adFormat: any AdAdapterFormat,
                   options: AdManagerOptions,
                   viewController: UIViewController?,
                   adDelegate: AdLifeCycleDelegate?) throws(AdsCardAdapterError) -> any AdManager {
        throw .noSuitableAdapterAvailable
    }
}
