//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation

public protocol HeaderBidable {
    func adMarkUp(adUnitId: String,
                  campaignId: String?,
                  creativeId: String?,
                  dspCreative: String?,
                  dspRegion: DspRegion?,
                  rtbTestModeEnabled: Bool) async throws -> String?
    func description(for error: Error) -> String
}
