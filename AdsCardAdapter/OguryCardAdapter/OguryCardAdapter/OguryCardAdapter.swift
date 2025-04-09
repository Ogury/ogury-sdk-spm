//
//  OguryCardAdapter.swift
//  OguryCardAdapter
//
//  Created by Jerome TONNELIER on 08/04/2025.
//

import UIKit
import AdsCardAdapter
import AdsCardLibrary

public enum OguryEnvironement {
    case devc, staging, prod
}

public struct OguryAdsCardAdapter: AdsCardAdaptable {
    public var assetKey: String
    private let environment: OguryEnvironement
    static var configuration: Configuration!
    public init(assetKey: String, environment: OguryEnvironement) {
        self.assetKey = assetKey
        self.environment = environment
        OguryAdsCardAdapter.configuration = .init(from: assetKey, environment: environment)
    }
    
    public var availableAdFormats: [AdAdapterFormatSection] = []
    
    public func adManager(for adFormat: any AdAdapterFormat,
                   options: AdViewOptions,
                   viewController: UIViewController?,
                   adDelegate: AdLifeCycleDelegate?) throws(AdsCardAdapterError) -> any AdManager {
        throw .noSuitableAdapterAvailable
    }
    
    public func startSdk() {
        
    }
}
