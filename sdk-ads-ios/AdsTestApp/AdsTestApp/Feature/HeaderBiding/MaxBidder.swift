//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import AdsCardLibrary
import OguryAds

struct MaxBidder: MaxHeaderBidable {
   
   func description(for error: Error) -> String {
      RTBBidder().description(for: error)
   }
    // MARK: - Functions
    
   func adMarkUp(adUnitId: String, 
                 campaignId: String?,
                 creativeId: String?,
                 dspCreative: String?,
                 dspRegion: DspRegion?) async throws -> String? {
        try await withUnsafeThrowingContinuation { continuation in
           RTBBidder().retrieveAdMarkup(assetKey: AdSdkLauncher.shared.assetKey,
                             adUnitId: adUnitId,
                             country: "FRA",
                             campaignId: campaignId,
                             creativeId: creativeId,
                             dspCreative: dspCreative,
                             dspRegion: dspRegion,
                             displayManager: Configuration.shared.maxOptions.displayManager,
                             url: Configuration.shared.maxOptions.url) { result in
                print("👀 \(result)")
                switch result {
                    case let .success(adMarkUp): continuation.resume(returning: adMarkUp)
                    case let .failure(error): continuation.resume(throwing: error)
                }
            }
        }
    }
    
    init() {
        print("init")
    }
}
