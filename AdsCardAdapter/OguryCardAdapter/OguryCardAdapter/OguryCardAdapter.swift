//
//  OguryCardAdapter.swift
//  OguryCardAdapter
//
//  Created by Jerome TONNELIER on 08/04/2025.
//

import Foundation
import AdsCardAdapter

struct OguryCardAdapter: AdsCardAdaptable {
    var availableAdFormats: [AdAdapterFormatSection] = []
    
    func adManager(for adFormat: any ACLAdapterFormat,
                   options: AdManagerOptions,
                   viewController: UIViewController?,
                   adDelegate: AdLifeCycleDelegate?) throws(ACLAdapterError) -> any AdManager {
        throw .noSuitableAdapterAvailable
    }
    
    func startSdk() {
        
    }
}
