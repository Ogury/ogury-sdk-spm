//
//  OguryCardAdapter.swift
//  OguryCardAdapter
//
//  Created by Jerome TONNELIER on 08/04/2025.
//

import Foundation
import AdsCardAdapter

public enum OguryEnvironement {
    case devc, staging, prod
}

public struct OguryCardAdapter: AdsCardAdaptable {
    var environment: OguryEnvironement = .prod
    public init(environment: OguryEnvironement) {
        self.environment = environment
        Configuration.shared.load(from: environment)
    }
    
    public var availableAdFormats: [AdAdapterFormatSection] = []
    
    public func adManager(for adFormat: any ACLAdapterFormat,
                   options: AdManagerOptions,
                   viewController: UIViewController?,
                   adDelegate: AdLifeCycleDelegate?) throws(ACLAdapterError) -> any AdManager {
        throw .noSuitableAdapterAvailable
    }
    
    public func startSdk() {
        
    }
}
