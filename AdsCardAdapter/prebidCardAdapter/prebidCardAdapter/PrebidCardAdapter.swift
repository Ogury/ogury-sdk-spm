//
//  PrebidCardAdapter.swift
//  PrebidCardAdapter
//
//  Created by Jerome TONNELIER on 12/06/2025.
//

import UIKit
import AdsCardAdapter
import AdsCardLibrary
import OguryCore.Private
import OguryCore
import PrebidMobile

struct PrebidAdsCardAdapter: AdsCardAdaptable {
    var availableAdFormats: [AdAdapterFormatSection] = []
    var sdkVersions: String = {
"""
PreBid: \(Prebid.shared.version),
OguryCore: \(OGCInternal.shared().getVersion())
"""
    }()
    
    var actions: [any AdsCardAdapterAction] = []
    
    func adManager(for adFormat: any AdAdapterFormat, options: AdViewOptions, viewController: UIViewController?, adDelegate: (any AdLifeCycleDelegate)?) throws(AdsCardAdapterError) -> any AdManager {
        throw .noSuitableAdapterAvailable
    }
    
    func adManager(from container: AdCardContainer, viewController: UIViewController?, adDelegate: (any AdLifeCycleDelegate)?) throws(AdsCardAdapterError) -> any AdManager {
        throw .noSuitableAdapterAvailable
    }
    
    func adAdapterFormat(fromRawValue rawValue: Int, fileVersion: FileVersion) throws(AdsCardAdapterError) -> any AdAdapterFormat {
        throw .noSuitableAdapterAvailable
    }
    
    func startSdk() async {
        Prebid.shared.prebidServerAccountId = "0689a263-318d-448b-a3d4-b02e8a709d9d"
        Targeting.shared.setGlobalORTBConfig("{\"ext\":{\"prebid\":{\"storedrequest\": {\"id\":\"ogury-id-123\"}}}}")
        try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            do {
                try Prebid.initializeSDK(serverURL: "https://prebid-server.devc.cloud.ogury.io/") { status, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if status == .succeeded {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: NSError(
                            domain: "PrebidInitialization",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "SDK initialization failed with unknown error"]
                        ))
                    }
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func resetSdk() {
        // n/a
    }
    
    func add(logger: any OguryLogger) {
        // n/a
    }
}

