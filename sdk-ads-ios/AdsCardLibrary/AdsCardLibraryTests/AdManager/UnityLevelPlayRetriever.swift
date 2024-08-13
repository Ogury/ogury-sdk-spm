//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation
import AdsCardLibrary

struct UnityLevelPlayRetriever: UnityLevelPlayBidable {
    let adMarkUpToReturn: String?
    var asyncDeadline = 0.2
   func adMarkUp(adUnitId: String,
                 campaignId: String?,
                 creativeId: String?,
                 dspCreative: String?,
                 dspRegion: DspRegion?) async -> String? {
        await withCheckedContinuation { check in
            DispatchQueue.main.asyncAfter(deadline: .now() + asyncDeadline) {
                check.resume(returning: self.adMarkUpToReturn)
            }
        }
    }
    
    func description(for error: Error) -> String {
       "Unity LevelPlay AdMarkup retriever failed :\(error.localizedDescription)"
    }
}
